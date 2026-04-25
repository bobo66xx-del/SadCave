local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local ShopCatalog = require(ReplicatedStorage:WaitForChild("ShopCatalog"))

local ShopInventoryStore = DataStoreService:GetDataStore("ShopInventory_v1")

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

local shopRemotes = ensureChild(ReplicatedStorage, "Folder", "ShopRemotes")
local getShopDataRemote = ensureChild(shopRemotes, "RemoteFunction", "GetShopData")
local buyShopItemRemote = ensureChild(shopRemotes, "RemoteFunction", "BuyShopItem")
local shopDataUpdatedRemote = ensureChild(shopRemotes, "RemoteEvent", "ShopDataUpdated")

local playerStates = {}

local function getState(player)
    local state = playerStates[player]
    if not state then
        state = {
            loaded = false,
            ownedItems = {},
        }
        playerStates[player] = state
    end
    return state
end

local function ensureOwnershipFolders(player)
    local ownedItemsFolder = ensureChild(player, "Folder", "ShopOwnedItems")
    local ownedTitlesFolder = ensureChild(player, "Folder", "ShopOwnedTitles")
    return ownedItemsFolder, ownedTitlesFolder
end

local function clearChildren(folder)
    for _, child in ipairs(folder:GetChildren()) do
        child:Destroy()
    end
end

local function syncOwnershipFolders(player)
    local state = getState(player)
    local ownedItemsFolder, ownedTitlesFolder = ensureOwnershipFolders(player)

    clearChildren(ownedItemsFolder)
    clearChildren(ownedTitlesFolder)

    for itemId, owned in pairs(state.ownedItems) do
        if owned == true then
            local item = ShopCatalog.GetItemById(itemId)
            if item then
                local itemValue = Instance.new("BoolValue")
                itemValue.Name = itemId
                itemValue.Value = true
                itemValue.Parent = ownedItemsFolder

                if item.category == "title" and item.linkedTitleId then
                    local titleValue = Instance.new("BoolValue")
                    titleValue.Name = item.linkedTitleId
                    titleValue.Value = true
                    titleValue.Parent = ownedTitlesFolder
                end
            end
        end
    end
end

local function serializeState(state)
    return {
        OwnedItems = state.ownedItems,
    }
end

local function saveState(player)
    local state = getState(player)
    local success, err = pcall(function()
        ShopInventoryStore:SetAsync(player.UserId, serializeState(state))
    end)
    if not success then
        warn("[ShopService] Failed to save shop inventory for", player.UserId, err)
    end
    return success
end

local function loadState(player)
    local state = getState(player)
    player:SetAttribute("ShopOwnershipLoaded", false)
    ensureOwnershipFolders(player)

    local loadedData = nil
    local success, err = pcall(function()
        loadedData = ShopInventoryStore:GetAsync(player.UserId)
    end)

    if not success then
        warn("[ShopService] Failed to load shop inventory for", player.UserId, err)
        loadedData = nil
    end

    local ownedItems = {}
    if type(loadedData) == "table" and type(loadedData.OwnedItems) == "table" then
        for itemId, owned in pairs(loadedData.OwnedItems) do
            if owned == true and ShopCatalog.GetItemById(itemId) then
                ownedItems[itemId] = true
            end
        end
    end

    state.ownedItems = ownedItems
    state.loaded = true
    syncOwnershipFolders(player)
    player:SetAttribute("ShopOwnershipLoaded", true)
end

local function getTitleDataUpdatedRemote()
    local titleRemotes = ReplicatedStorage:FindFirstChild("TitleRemotes")
    return titleRemotes and titleRemotes:FindFirstChild("TitleDataUpdated") or nil
end

local function buildPayload(player)
    local state = getState(player)
    local shards = player:FindFirstChild("Shards")
    local balance = shards and shards:IsA("IntValue") and shards.Value or 0
    local items = {}

    for _, item in ipairs(ShopCatalog.GetOrderedItems()) do
        if item.visible ~= false then
            local owned = state.ownedItems[item.id] == true
            local canAfford = balance >= (item.priceShards or 0)
            local statusText
            if owned then
                statusText = "owned"
            elseif canAfford then
                statusText = "buy"
            else
                statusText = "need more"
            end

            table.insert(items, {
                Id = item.id,
                Name = item.displayName,
                Description = item.description,
                Category = item.category,
                PriceShards = item.priceShards,
                LinkedTitleId = item.linkedTitleId,
                Owned = owned,
                CanBuy = not owned and canAfford and state.loaded,
                StatusText = statusText,
            })
        end
    end

    return {
        Loaded = state.loaded,
        Balance = balance,
        Items = items,
    }
end

local function pushUpdates(player)
    if not player.Parent then
        return
    end
    shopDataUpdatedRemote:FireClient(player, buildPayload(player))
    local titleDataUpdatedRemote = getTitleDataUpdatedRemote()
    if titleDataUpdatedRemote and titleDataUpdatedRemote:IsA("RemoteEvent") then
        titleDataUpdatedRemote:FireClient(player)
    end
end

local function purchaseItem(player, itemId)
    local state = getState(player)
    if not state.loaded then
        return {
            Success = false,
            Error = "Shop is still loading.",
            Payload = buildPayload(player),
        }
    end

    local item = ShopCatalog.GetItemById(itemId)
    if not item or item.visible == false then
        return {
            Success = false,
            Error = "That item is unavailable.",
            Payload = buildPayload(player),
        }
    end

    if state.ownedItems[item.id] == true then
        return {
            Success = false,
            Error = "You already own that item.",
            Payload = buildPayload(player),
        }
    end

    local shards = player:FindFirstChild("Shards")
    if not shards or not shards:IsA("IntValue") then
        return {
            Success = false,
            Error = "Shards are unavailable right now.",
            Payload = buildPayload(player),
        }
    end

    local price = item.priceShards or 0
    if shards.Value < price then
        return {
            Success = false,
            Error = "You need more Shards.",
            Payload = buildPayload(player),
        }
    end

    shards.Value -= price
    state.ownedItems[item.id] = true
    syncOwnershipFolders(player)

    if not saveState(player) then
        state.ownedItems[item.id] = nil
        syncOwnershipFolders(player)
        shards.Value += price
        return {
            Success = false,
            Error = "Purchase failed to save. Your Shards were refunded.",
            Payload = buildPayload(player),
        }
    end

    pushUpdates(player)
    return {
        Success = true,
        PurchasedItemId = item.id,
        Payload = buildPayload(player),
    }
end

getShopDataRemote.OnServerInvoke = function(player)
    return buildPayload(player)
end

buyShopItemRemote.OnServerInvoke = function(player, itemId)
    return purchaseItem(player, itemId)
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(function()
        loadState(player)
        pushUpdates(player)
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        loadState(player)
        pushUpdates(player)
    end)
end

Players.PlayerRemoving:Connect(function(player)
    local state = playerStates[player]
    if state and state.loaded then
        saveState(player)
    end
    playerStates[player] = nil
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        local state = playerStates[player]
        if state and state.loaded then
            saveState(player)
        end
    end
end)
