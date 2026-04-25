local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local LevelSave = DataStoreService:GetDataStore("LevelSave")
local GamepassId = 2110249546

local runningLoops = {}

local function onPlayerAdded(player)
    if runningLoops[player] then
        return
    end

    runningLoops[player] = true
    player:SetAttribute("LevelLoaded", false)

    local Level = player:FindFirstChild("Level")
    if Level and not Level:IsA("IntValue") then
        Level:Destroy()
        Level = nil
    end
    if not Level then
        Level = Instance.new("IntValue")
        Level.Name = "Level"
        Level.Parent = player
    end

    local ok, savedOrErr = pcall(function()
        return LevelSave:GetAsync(player.UserId)
    end)
    if ok then
        Level.Value = savedOrErr or 0
    else
        warn("[LevelLeaderstats] GetAsync failed for", player.UserId, savedOrErr)
        Level.Value = 0
    end

    player:SetAttribute("LevelLoaded", true)

    local AUTOSAVE_SECONDS = 120
    task.spawn(function()
        while runningLoops[player] and task.wait(AUTOSAVE_SECONDS) do
            if not player.Parent then
                break
            end
            local ok2, err2 = pcall(function()
                LevelSave:SetAsync(player.UserId, Level.Value)
            end)
            if not ok2 then
                warn("[LevelLeaderstats] Autosave SetAsync failed for", player.UserId, err2)
            end
        end
    end)

    task.spawn(function()
        while runningLoops[player] and task.wait(60) do
            if not player.Parent then
                break
            end

            local owns = false
            local ownsSuccess, ownsResult = pcall(function()
                return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GamepassId)
            end)
            if ownsSuccess then
                owns = ownsResult
            else
                warn("[LevelLeaderstats] UserOwnsGamePassAsync failed for", player.UserId, ownsResult)
            end

            if owns then
                Level.Value += 2
            else
                Level.Value += 1
            end
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in Players:GetPlayers() do
    onPlayerAdded(player)
end

Players.PlayerRemoving:Connect(function(player)
    runningLoops[player] = nil

    local level = player:FindFirstChild("Level")
    if level and level:IsA("IntValue") then
        local ok, err = pcall(function()
            LevelSave:SetAsync(player.UserId, level.Value)
        end)
        if not ok then
            warn("[LevelLeaderstats] SetAsync on removing failed for", player.UserId, err)
        end
    end
end)
