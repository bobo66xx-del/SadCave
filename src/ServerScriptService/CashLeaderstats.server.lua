local DataStoreService = game:GetService("DataStoreService")

local ShardsSave = DataStoreService:GetDataStore("ShardsSave")
local CashSave = DataStoreService:GetDataStore("CashSave")
local MigratedFlag = DataStoreService:GetDataStore("ShardsMigration_v1")

local players = game.Players
local shardLoadState = {}
local sessionMilestoneState = {}

local SESSION_MILESTONES = {
    { key = "10m", seconds = 10 * 60, reward = 10 },
    { key = "20m", seconds = 20 * 60, reward = 15 },
    { key = "30m", seconds = 30 * 60, reward = 25 },
}

local function markShardLoadState(player, state)
    shardLoadState[player] = state
end

local function canSaveShards(player)
    return shardLoadState[player] == "loaded"
end

local function getMilestoneState(player)
    local state = sessionMilestoneState[player]
    if not state then
        state = { claimed = {} }
        sessionMilestoneState[player] = state
    end
    return state
end

local function checkSessionMilestones(player, timePlayedValue, shardsValue)
    if not canSaveShards(player) then
        return
    end

    local state = getMilestoneState(player)
    for _, milestone in ipairs(SESSION_MILESTONES) do
        if timePlayedValue.Value >= milestone.seconds and state.claimed[milestone.key] ~= true then
            state.claimed[milestone.key] = true
            if shardsValue and shardsValue.Parent == player then
                shardsValue.Value += milestone.reward
            end
        end
    end
end

local TotalTimePlayedSave = DataStoreService:GetDataStore("TotalTimePlayedSave")
local RevisitsSave = DataStoreService:GetDataStore("RevisitsSave")

players.PlayerAdded:Connect(function(player)
    sessionMilestoneState[player] = { claimed = {} }

    local Shards = Instance.new("IntValue", player)
    Shards.Name = "Shards"

    local TimePlayed = Instance.new("IntValue")
    TimePlayed.Name = "TimePlayed"
    TimePlayed.Parent = player
    TimePlayed.Value = 0

    local TotalTimePlayed = Instance.new("IntValue")
    TotalTimePlayed.Name = "TotalTimePlayed"
    TotalTimePlayed.Parent = player
    local loadedTotalTime = 0
    pcall(function()
        loadedTotalTime = TotalTimePlayedSave:GetAsync(player.UserId) or 0
    end)
    TotalTimePlayed.Value = loadedTotalTime

    local Revisits = Instance.new("IntValue")
    Revisits.Name = "Revisits"
    Revisits.Parent = player
    local loadedRevisits = 0
    pcall(function()
        loadedRevisits = RevisitsSave:GetAsync(player.UserId) or 0
    end)
    Revisits.Value = (loadedRevisits or 0) + 1
    pcall(function()
        RevisitsSave:SetAsync(player.UserId, Revisits.Value)
    end)

    task.spawn(function()
        while player.Parent do
            task.wait(1)
            TimePlayed.Value += 1
            TotalTimePlayed.Value += 1
            checkSessionMilestones(player, TimePlayed, Shards)
        end
    end)

    local TIME_AUTOSAVE_SECONDS = 60
    task.spawn(function()
        while player.Parent and task.wait(TIME_AUTOSAVE_SECONDS) do
            pcall(function()
                TotalTimePlayedSave:SetAsync(player.UserId, TotalTimePlayed.Value)
            end)
        end
    end)

    markShardLoadState(player, "loading")
    local loadedShards = nil
    local shardsLoadOk, shardsLoadErr = pcall(function()
        loadedShards = ShardsSave:GetAsync(player.UserId)
    end)

    if not shardsLoadOk then
        warn("[CashLeaderstats] Shards load failed for", player.UserId, shardsLoadErr)
        markShardLoadState(player, "failed")
        return
    end

    if loadedShards == nil then
        local migratedAlready = false
        local migratedFlagOk, migratedFlagErr = pcall(function()
            migratedAlready = (MigratedFlag:GetAsync(player.UserId) == true)
        end)

        if not migratedFlagOk then
            warn("[CashLeaderstats] Migration flag load failed for", player.UserId, migratedFlagErr)
            markShardLoadState(player, "failed")
            return
        end

        if not migratedAlready then
            local oldCash = 0
            local oldCashOk, oldCashErr = pcall(function()
                oldCash = CashSave:GetAsync(player.UserId) or 0
            end)

            if not oldCashOk then
                warn("[CashLeaderstats] Cash migration load failed for", player.UserId, oldCashErr)
                markShardLoadState(player, "failed")
                return
            end

            loadedShards = oldCash

            local migrateSaveOk, migrateSaveErr = pcall(function()
                ShardsSave:SetAsync(player.UserId, loadedShards)
                MigratedFlag:SetAsync(player.UserId, true)
            end)

            if not migrateSaveOk then
                warn("[CashLeaderstats] Shards migration save failed for", player.UserId, migrateSaveErr)
                markShardLoadState(player, "failed")
                return
            end
        else
            warn("[CashLeaderstats] Shard data missing after migration for", player.UserId, "- skipping shard saves this session")
            markShardLoadState(player, "failed")
            return
        end
    end

    Shards.Value = loadedShards or 0
    markShardLoadState(player, "loaded")

    local AUTOSAVE_SECONDS = 120
    task.spawn(function()
        while player.Parent and task.wait(AUTOSAVE_SECONDS) do
            if canSaveShards(player) then
                pcall(function()
                    ShardsSave:SetAsync(player.UserId, Shards.Value)
                end)
            end
        end
    end)

    while player.Parent do
        task.wait(60)
        Shards.Value += 5
    end
end)

players.PlayerRemoving:Connect(function(player)
    local shards = player:FindFirstChild("Shards")
    if shards and shards:IsA("IntValue") and canSaveShards(player) then
        pcall(function()
            ShardsSave:SetAsync(player.UserId, shards.Value)
        end)
    elseif shards and shards:IsA("IntValue") then
        warn("[CashLeaderstats] Skipping shard save on PlayerRemoving for", player.UserId, "because shard load was not confirmed")
    end

    local ttp = player:FindFirstChild("TotalTimePlayed")
    if ttp and ttp:IsA("IntValue") then
        pcall(function()
            TotalTimePlayedSave:SetAsync(player.UserId, ttp.Value)
        end)
    end

    local rv = player:FindFirstChild("Revisits")
    if rv and rv:IsA("IntValue") then
        pcall(function()
            RevisitsSave:SetAsync(player.UserId, rv.Value)
        end)
    end
    shardLoadState[player] = nil
    sessionMilestoneState[player] = nil
end)

game:BindToClose(function()
    for _, player in game:GetService("Players"):GetPlayers() do
        local shards = player:FindFirstChild("Shards")
        if shards and shards:IsA("IntValue") and canSaveShards(player) then
            pcall(function()
                ShardsSave:SetAsync(player.UserId, shards.Value)
            end)
        elseif shards and shards:IsA("IntValue") then
            warn("[CashLeaderstats] Skipping shard save on BindToClose for", player.UserId, "because shard load was not confirmed")
        end

        local ttp = player:FindFirstChild("TotalTimePlayed")
        if ttp and ttp:IsA("IntValue") then
            pcall(function()
                TotalTimePlayedSave:SetAsync(player.UserId, ttp.Value)
            end)
        end

        local rv = player:FindFirstChild("Revisits")
        if rv and rv:IsA("IntValue") then
            pcall(function()
                RevisitsSave:SetAsync(player.UserId, rv.Value)
            end)
        end
    end
    task.wait(2)
end)
