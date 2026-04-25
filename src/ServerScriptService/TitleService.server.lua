local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

local TitleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))
local EquippedTitleStore = DataStoreService:GetDataStore("EquippedTitleV1")

local OWNERSHIP_CACHE_SECONDS = 10
local INITIAL_LEVEL_WAIT_SECONDS = 10
local SHOP_OWNERSHIP_WAIT_SECONDS = 10
local TITLE_PACK_PURCHASE_GRACE_SECONDS = 20

local UNIVERSAL_TITLE_ACCESS_USER_IDS = {
    [1132193781] = true,
}

local function HasUniversalTitleAccess(playerOrUserId)
    local userId = nil
    if typeof(playerOrUserId) == "Instance" and playerOrUserId:IsA("Player") then
        userId = playerOrUserId.UserId
    else
        userId = tonumber(playerOrUserId)
    end

    return userId ~= nil and UNIVERSAL_TITLE_ACCESS_USER_IDS[userId] == true or false
end

local function ensureChild(parent, className, name)
    local child = parent:FindFirstChild(name)
    if child and child.ClassName ~= className then
        child:Destroy()
        child = nil
    end
    if not child then
        child = Instance.new(className)
        child.Name = name
        child.Parent = parent
    end
    return child
end

local titleRemotes = ensureChild(ReplicatedStorage, "Folder", "TitleRemotes")
local getTitleDataRemote = ensureChild(titleRemotes, "RemoteFunction", "GetTitleData")
local equipTitleRemote = ensureChild(titleRemotes, "RemoteFunction", "EquipTitle")
local titleDataUpdatedRemote = ensureChild(titleRemotes, "RemoteEvent", "TitleDataUpdated")

local playerStates = {}

local function getState(player)
    local state = playerStates[player]
    if not state then
        state = {
            savedTitleId = nil,
            currentTitleId = nil,
            lastSavedTitleId = nil,
            titlePackOwned = false,
            lastOwnershipCheck = 0,
            titlePackGrantedUntil = 0,
            levelConnections = {},
            specialConnections = {},
            shopLoadedConnection = nil,
        }
        playerStates[player] = state
    end
    return state
end

local function isLevelLoaded(player)
    local loadedAttribute = player:GetAttribute("LevelLoaded")
    if loadedAttribute == nil then
        return player:FindFirstChild("Level") ~= nil
    end
    return loadedAttribute == true
end

local function waitForLevelLoaded(player, timeoutSeconds)
    if isLevelLoaded(player) then
        return true
    end

    local deadline = os.clock() + (timeoutSeconds or 0)
    while player.Parent and os.clock() < deadline do
        if isLevelLoaded(player) then
            return true
        end
        task.wait(0.1)
    end

    return isLevelLoaded(player)
end

local function isShopOwnershipLoaded(player)
    return player:GetAttribute("ShopOwnershipLoaded") == true
end

local function waitForShopOwnershipLoaded(player, timeoutSeconds)
    if isShopOwnershipLoaded(player) then
        return true
    end

    local deadline = os.clock() + (timeoutSeconds or 0)
    while player.Parent and os.clock() < deadline do
        if isShopOwnershipLoaded(player) then
            return true
        end
        task.wait(0.1)
    end

    return isShopOwnershipLoaded(player)
end

local function getLevel(player)
    local levelValue = player:FindFirstChild("Level")
    if levelValue and levelValue:IsA("IntValue") then
        return levelValue.Value
    end

    local leaderstats = player:FindFirstChild("leaderstats")
    local leaderstatsLevel = leaderstats and leaderstats:FindFirstChild("Level")
    if leaderstatsLevel and leaderstatsLevel:IsA("IntValue") then
        return leaderstatsLevel.Value
    end

    return 0
end

local function ensureEquippedValue(player)
    local value = player:FindFirstChild("EquippedTitle")
    if value and not value:IsA("StringValue") then
        value:Destroy()
        value = nil
    end
    if not value then
        value = Instance.new("StringValue")
        value.Name = "EquippedTitle"
        value.Value = ""
        value.Parent = player
    end
    return value
end

local function refreshTitlePackOwnership(player, forceRefresh)
    if HasUniversalTitleAccess(player) then
        local state = getState(player)
        state.titlePackOwned = true
        state.titlePackGrantedUntil = math.huge
        return true
    end

    local state = getState(player)
    local now = os.clock()

    if state.titlePackOwned and now < state.titlePackGrantedUntil then
        return true
    end

    if not forceRefresh and (now - state.lastOwnershipCheck) < OWNERSHIP_CACHE_SECONDS then
        return state.titlePackOwned == true
    end

    state.lastOwnershipCheck = now

    local success, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, TitleConfig.TITLE_PACK_GAMEPASS_ID)
    end)

    if success then
        state.titlePackOwned = owns == true
        if state.titlePackOwned then
            state.titlePackGrantedUntil = math.max(state.titlePackGrantedUntil, now + TITLE_PACK_PURCHASE_GRACE_SECONDS)
        else
            state.titlePackGrantedUntil = 0
        end
    else
        warn("[TitleService] UserOwnsGamePassAsync failed for", player.UserId, owns)
    end

    return state.titlePackOwned == true
end

local function playerOwnsShopTitle(player, titleId)
    local ownedTitlesFolder = player:FindFirstChild("ShopOwnedTitles")
    local ownedValue = ownedTitlesFolder and ownedTitlesFolder:FindFirstChild(titleId)
    return ownedValue and ownedValue:IsA("BoolValue") and ownedValue.Value == true or false
end

local function ownsTitle(player, title, titlePackOwned)
    if not title then
        return false
    end

    if HasUniversalTitleAccess(player) then
        return true
    end

    local category = TitleConfig.GetCategory(title)
    if category == "level" then
        return getLevel(player) >= (title.requiredLevel or 0)
    end

    if category == "gamepass" then
        return titlePackOwned == true
    end

    if category == "shop" then
        return playerOwnsShopTitle(player, title.id)
    end

    if category == "special" then
        return TitleConfig.PlayerHasSpecialAccess(player, title.id)
    end

    return false
end

local function buildOwnedMap(player, forceRefreshOwnership)
    local titlePackOwned = refreshTitlePackOwnership(player, forceRefreshOwnership)
    local ownedMap = {}

    for _, title in ipairs(TitleConfig.GetOrderedTitles()) do
        ownedMap[title.id] = ownsTitle(player, title, titlePackOwned)
    end

    return ownedMap, titlePackOwned
end

local function resolveDefaultTitleId(player)
    return TitleConfig.GetBestLevelTitleId(getLevel(player))
end

local function resolveRequestedTitleId(player, requestedTitleId, ownedMap)
    local normalizedRequestedId = TitleConfig.NormalizeTitleId(requestedTitleId)
    if normalizedRequestedId and ownedMap[normalizedRequestedId] then
        return normalizedRequestedId
    end

    return resolveDefaultTitleId(player)
end

local function resolveCurrentTitle(player, forceRefreshOwnership)
    local state = getState(player)
    local equippedValue = ensureEquippedValue(player)
    local ownedMap, titlePackOwned = buildOwnedMap(player, forceRefreshOwnership)

    local requestedTitleId = equippedValue.Value
    if requestedTitleId == "" then
        requestedTitleId = state.savedTitleId
    end

    local normalizedRequestedId = TitleConfig.NormalizeTitleId(requestedTitleId)
    local resolvedTitleId = resolveRequestedTitleId(player, normalizedRequestedId, ownedMap)

    if equippedValue.Value ~= resolvedTitleId then
        equippedValue.Value = resolvedTitleId
    end

    state.currentTitleId = resolvedTitleId
    if normalizedRequestedId and ownedMap[normalizedRequestedId] then
        state.savedTitleId = normalizedRequestedId
    else
        state.savedTitleId = resolvedTitleId
    end

    return resolvedTitleId, ownedMap, titlePackOwned
end

local function buildPayload(player, forceRefreshOwnership)
    local resolvedTitleId, ownedMap, titlePackOwned = resolveCurrentTitle(player, forceRefreshOwnership)
    local titles = {}

    for _, title in ipairs(TitleConfig.GetOrderedTitles()) do
        local category = TitleConfig.GetCategory(title)
        local owned = ownedMap[title.id] == true
        local equipped = resolvedTitleId == title.id
        local action
        local statusText

        if equipped then
            action = "equipped"
            statusText = "equipped"
        elseif owned then
            action = "equip"
            statusText = "equip"
        elseif category == "gamepass" then
            action = "buy"
            statusText = "click to buy"
        elseif category == "shop" then
            action = "locked"
            statusText = "buy in shop"
        else
            action = "locked"
            statusText = "locked"
        end

        table.insert(titles, {
            Id = title.id,
            Name = title.displayName,
            RequirementText = TitleConfig.GetRequirementText(title),
            Category = category,
            Owned = owned,
            Equipped = equipped,
            Action = action,
            StatusText = statusText,
        })
    end

    return {
        EquippedTitleId = resolvedTitleId,
        EquippedTitleName = TitleConfig.GetDisplayName(resolvedTitleId),
        TitlePackOwned = titlePackOwned,
        Titles = titles,
    }
end

local function fireTitleUpdate(player)
    if player.Parent then
        titleDataUpdatedRemote:FireClient(player)
    end
end

local function savePlayerTitle(player)
    local state = getState(player)
    local equippedValue = player:FindFirstChild("EquippedTitle")
    local titleId = state.currentTitleId

    if not titleId and equippedValue and equippedValue:IsA("StringValue") then
        titleId = equippedValue.Value
    end

    titleId = TitleConfig.NormalizeTitleId(titleId) or resolveDefaultTitleId(player)
    if state.lastSavedTitleId == titleId then
        return
    end

    local success, err = pcall(function()
        EquippedTitleStore:SetAsync(player.UserId, titleId)
    end)

    if success then
        state.savedTitleId = titleId
        state.lastSavedTitleId = titleId
    else
        warn("[TitleService] Failed to save equipped title for", player.UserId, err)
    end
end

local function connectLevelValue(player, valueObject)
    local state = getState(player)
    if state.levelConnections[valueObject] then
        return
    end

    state.levelConnections[valueObject] = valueObject:GetPropertyChangedSignal("Value"):Connect(function()
        local previousTitleId = state.currentTitleId
        local resolvedTitleId = resolveCurrentTitle(player, false)
        if resolvedTitleId ~= previousTitleId then
            task.spawn(savePlayerTitle, player)
        end
        fireTitleUpdate(player)
    end)
end

local function hookLevelSources(player)
    local directLevel = player:FindFirstChild("Level")
    if directLevel and directLevel:IsA("IntValue") then
        connectLevelValue(player, directLevel)
    end

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:IsA("Folder") then
        local leaderstatsLevel = leaderstats:FindFirstChild("Level")
        if leaderstatsLevel and leaderstatsLevel:IsA("IntValue") then
            connectLevelValue(player, leaderstatsLevel)
        end

        leaderstats.ChildAdded:Connect(function(child)
            if child.Name == "Level" and child:IsA("IntValue") then
                connectLevelValue(player, child)
                resolveCurrentTitle(player, false)
                fireTitleUpdate(player)
            end
        end)
    end

    player.ChildAdded:Connect(function(child)
        if child.Name == "Level" and child:IsA("IntValue") then
            connectLevelValue(player, child)
            resolveCurrentTitle(player, false)
            fireTitleUpdate(player)
        elseif child.Name == "leaderstats" and child:IsA("Folder") then
            local innerLevel = child:FindFirstChild("Level")
            if innerLevel and innerLevel:IsA("IntValue") then
                connectLevelValue(player, innerLevel)
            end

            child.ChildAdded:Connect(function(grandChild)
                if grandChild.Name == "Level" and grandChild:IsA("IntValue") then
                    connectLevelValue(player, grandChild)
                    resolveCurrentTitle(player, false)
                    fireTitleUpdate(player)
                end
            end)
        end
    end)
end

local function hookSpecialAssignments(player)
    local state = getState(player)

    for _, assignment in pairs(TitleConfig.SpecialAssignments) do
        local attributeName = assignment.attributeName
        if attributeName and not state.specialConnections[attributeName] then
            state.specialConnections[attributeName] = player:GetAttributeChangedSignal(attributeName):Connect(function()
                local previousTitleId = state.currentTitleId
                local resolvedTitleId = resolveCurrentTitle(player, false)
                if resolvedTitleId ~= previousTitleId then
                    task.spawn(savePlayerTitle, player)
                end
                fireTitleUpdate(player)
            end)
        end
    end
end

local function hookShopOwnership(player)
    local state = getState(player)
    if state.shopLoadedConnection then
        return
    end

    state.shopLoadedConnection = player:GetAttributeChangedSignal("ShopOwnershipLoaded"):Connect(function()
        local previousTitleId = state.currentTitleId
        local resolvedTitleId = resolveCurrentTitle(player, false)
        if resolvedTitleId ~= previousTitleId then
            task.spawn(savePlayerTitle, player)
        end
        fireTitleUpdate(player)
    end)
end

local function initializePlayerTitle(player)
    local state = getState(player)
    ensureEquippedValue(player)

    local success, savedTitleId = pcall(function()
        return EquippedTitleStore:GetAsync(player.UserId)
    end)

    if success then
        state.savedTitleId = TitleConfig.NormalizeTitleId(savedTitleId)
        state.lastSavedTitleId = state.savedTitleId
    else
        warn("[TitleService] Failed to load equipped title for", player.UserId, savedTitleId)
        state.savedTitleId = nil
        state.lastSavedTitleId = nil
    end

    task.spawn(function()
        waitForLevelLoaded(player, INITIAL_LEVEL_WAIT_SECONDS)
        waitForShopOwnershipLoaded(player, SHOP_OWNERSHIP_WAIT_SECONDS)
        local resolvedTitleId = resolveCurrentTitle(player, true)
        if state.lastSavedTitleId ~= resolvedTitleId then
            task.spawn(savePlayerTitle, player)
        end
        fireTitleUpdate(player)
    end)
end

local function cleanupPlayerState(player)
    local state = playerStates[player]
    if not state then
        return
    end

    for _, connection in pairs(state.levelConnections) do
        if connection then
            connection:Disconnect()
        end
    end

    for _, connection in pairs(state.specialConnections) do
        if connection then
            connection:Disconnect()
        end
    end

    if state.shopLoadedConnection then
        state.shopLoadedConnection:Disconnect()
    end

    playerStates[player] = nil
end

getTitleDataRemote.OnServerInvoke = function(player)
    waitForLevelLoaded(player, 5)
    waitForShopOwnershipLoaded(player, 5)
    return buildPayload(player, true)
end

equipTitleRemote.OnServerInvoke = function(player, requestedTitleId)
    waitForLevelLoaded(player, 5)
    waitForShopOwnershipLoaded(player, 5)

    local normalizedRequestedId = TitleConfig.NormalizeTitleId(requestedTitleId)
    if not normalizedRequestedId then
        return buildPayload(player, true)
    end

    local ownedMap = buildOwnedMap(player, true)
    if not ownedMap[normalizedRequestedId] then
        return buildPayload(player, false)
    end

    local equippedValue = ensureEquippedValue(player)
    equippedValue.Value = normalizedRequestedId

    local state = getState(player)
    state.currentTitleId = normalizedRequestedId
    state.savedTitleId = normalizedRequestedId

    fireTitleUpdate(player)
    task.spawn(savePlayerTitle, player)
    return buildPayload(player, false)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    if gamePassId ~= TitleConfig.TITLE_PACK_GAMEPASS_ID or not player then
        return
    end

    local state = getState(player)
    state.lastOwnershipCheck = 0

    if wasPurchased then
        local now = os.clock()
        state.titlePackOwned = true
        state.titlePackGrantedUntil = now + TITLE_PACK_PURCHASE_GRACE_SECONDS

        task.delay(0.25, function()
            if not player.Parent then
                return
            end
            resolveCurrentTitle(player, false)
            fireTitleUpdate(player)
        end)
    else
        fireTitleUpdate(player)
    end
end)

Players.PlayerAdded:Connect(function(player)
    initializePlayerTitle(player)
    hookLevelSources(player)
    hookSpecialAssignments(player)
    hookShopOwnership(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    initializePlayerTitle(player)
    hookLevelSources(player)
    hookSpecialAssignments(player)
    hookShopOwnership(player)
end

Players.PlayerRemoving:Connect(function(player)
    savePlayerTitle(player)
    cleanupPlayerState(player)
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        savePlayerTitle(player)
    end
end)
