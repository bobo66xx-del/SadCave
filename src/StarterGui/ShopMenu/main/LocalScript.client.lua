local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local screenGui = script.Parent.Parent
local shopRemotes = ReplicatedStorage:WaitForChild("ShopRemotes")
local titleEffectPreview = require(ReplicatedStorage:WaitForChild("TitleEffectPreview"))

local mainframe = script.Parent:WaitForChild("mainframe")
local scrollingFrame = mainframe:WaitForChild("ScrollingFrame")
local template = scrollingFrame:WaitForChild("template")
local layout = scrollingFrame:WaitForChild("UIListLayout")
local balanceLabel = mainframe:FindFirstChild("CurrentTitle")

if balanceLabel then
    balanceLabel.Visible = false
end

local getShopData = shopRemotes:WaitForChild("GetShopData")
local buyShopItem = shopRemotes:WaitForChild("BuyShopItem")
local shopDataUpdated = shopRemotes:WaitForChild("ShopDataUpdated")

template.Visible = false

local refreshToken = 0

local function updateCanvasSize()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

local function clearRows()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child ~= template and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            titleEffectPreview.ClearContainer(child)
            child:Destroy()
        end
    end
end

local function applyPayload(payload)
    clearRows()

    if not payload or type(payload) ~= "table" then
        updateCanvasSize()
        return
    end

    if type(payload.Items) ~= "table" then
        updateCanvasSize()
        return
    end

    for _, entry in ipairs(payload.Items) do
        local rowData = entry
        local row = template:Clone()
        row.Name = rowData.Id
        row.Visible = true
        row.AutoButtonColor = rowData.CanBuy == true
        row.Active = rowData.CanBuy == true
        row.Parent = scrollingFrame

        local titleName = row:FindFirstChild("TitleName")
        local priceLabel = row:FindFirstChild("TitleRequiredLevel")
        local statusLabel = row:FindFirstChild("EquipedLabel")

        if titleName then
            titleName.Text = rowData.Name
            titleEffectPreview.Apply(titleName, rowData.LinkedTitleId or rowData.Id)
        end
        if priceLabel then
            priceLabel.Text = string.format("%d shards", rowData.PriceShards or 0)
        end
        if statusLabel then
            statusLabel.Text = rowData.StatusText or ""
        end

        row.MouseButton1Click:Connect(function()
            if rowData.CanBuy ~= true then
                return
            end

            local buySuccess, response = pcall(function()
                return buyShopItem:InvokeServer(rowData.Id)
            end)
            if buySuccess and type(response) == "table" and type(response.Payload) == "table" then
                applyPayload(response.Payload)
            end
        end)
    end

    updateCanvasSize()
end

local function refreshUI()
    refreshToken += 1
    local token = refreshToken

    local success, payload = pcall(function()
        return getShopData:InvokeServer()
    end)

    if token ~= refreshToken then
        return
    end

    if success and type(payload) == "table" then
        applyPayload(payload)
    else
        applyPayload(nil)
    end
end

screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if screenGui.Enabled then
        refreshUI()
    else
        titleEffectPreview.ClearContainer(scrollingFrame)
    end
end)

shopDataUpdated.OnClientEvent:Connect(function(payload)
    if screenGui.Enabled and type(payload) == "table" then
        applyPayload(payload)
    elseif screenGui.Enabled then
        refreshUI()
    else
        titleEffectPreview.ClearContainer(scrollingFrame)
    end
end)

refreshUI()
