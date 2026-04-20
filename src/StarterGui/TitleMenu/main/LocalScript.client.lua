local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local screenGui = script.Parent.Parent
local titleRemotes = ReplicatedStorage:WaitForChild("TitleRemotes")
local titleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))
local titleEffectPreview = require(ReplicatedStorage:WaitForChild("TitleEffectPreview"))

local mainframe = script.Parent:WaitForChild("mainframe")
local scrollingFrame = mainframe:WaitForChild("ScrollingFrame")
local template = scrollingFrame:WaitForChild("template")
local layout = scrollingFrame:WaitForChild("UIListLayout")
local currentTitleLabel = mainframe:WaitForChild("CurrentTitle")
local filterTabs = mainframe:WaitForChild("FilterTabs")
local allButton = filterTabs:WaitForChild("All")
local ownedButton = filterTabs:WaitForChild("Owned")
local levelButton = filterTabs:WaitForChild("Level")
local shopButton = filterTabs:WaitForChild("Shop")
local gamepassButton = filterTabs:WaitForChild("Gamepass")
local filterTabsLayout = filterTabs:WaitForChild("UIListLayout")

local getTitleData = titleRemotes:WaitForChild("GetTitleData")
local equipTitle = titleRemotes:WaitForChild("EquipTitle")
local titleDataUpdated = titleRemotes:WaitForChild("TitleDataUpdated")

template.Visible = false

local rowMetricDefaults = {
    templateSize = template.Size,
    padding = layout.Padding,
}

local refreshToken = 0
local currentData = nil
local equippedValue = nil
local boundEquippedValue = nil
local activeFilter = "all"
local hoveredFilter = nil

local filterButtons = {
    all = allButton,
    owned = ownedButton,
    level = levelButton,
    shop = shopButton,
    gamepass = gamepassButton,
}

local filterButtonOrder = { "all", "level", "shop", "gamepass", "owned" }

local filterTabDefaults = {
    size = filterTabs.Size,
    padding = filterTabsLayout.Padding,
    buttons = {},
}

for filterName, button in pairs(filterButtons) do
    filterTabDefaults.buttons[filterName] = {
        size = button.Size,
        textSize = button.TextSize,
    }
end

local MOBILE_FILTER_VIEWPORT_WIDTH = 900
local MOBILE_FILTER_ROW_SIZE = UDim2.new(0.97, 0, filterTabs.Size.Y.Scale, filterTabs.Size.Y.Offset)
local MOBILE_FILTER_ROW_PADDING = UDim.new(0, 1)
local MOBILE_FILTER_TEXT_SIZE_OPTIONS = { 9, 8, 7, 6 }
local MOBILE_FILTER_BUTTON_HORIZONTAL_PADDING = 6
local MOBILE_FILTER_MIN_BUTTON_WIDTH = 14
local MOBILE_FILTER_HARD_MIN_BUTTON_WIDTH = 10
local viewportSizeConnection = nil

local function normalizeRowMetrics()
    if template.Size ~= rowMetricDefaults.templateSize then
        template.Size = rowMetricDefaults.templateSize
    end

    if layout.Padding ~= rowMetricDefaults.padding then
        layout.Padding = rowMetricDefaults.padding
    end
end

local function updateCanvasSize()
    normalizeRowMetrics()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)

local function getFallbackTitleId()
    if equippedValue and equippedValue:IsA("StringValue") then
        return titleConfig.NormalizeTitleId(equippedValue.Value) or titleConfig.DEFAULT_TITLE_ID
    end
    return titleConfig.DEFAULT_TITLE_ID
end

local function getFallbackTitleName()
    return titleConfig.GetDisplayName(getFallbackTitleId())
end

local function setCurrentTitleLabel(titleId, displayName)
    local resolvedTitleId = titleConfig.NormalizeTitleId(titleId) or getFallbackTitleId()
    currentTitleLabel.Text = displayName or titleConfig.GetDisplayName(resolvedTitleId)
    titleEffectPreview.Apply(currentTitleLabel, resolvedTitleId)
end

local function clearRows()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child ~= template and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            titleEffectPreview.ClearContainer(child)
            child:Destroy()
        end
    end
end

local function normalizeCategory(category)
    if type(category) ~= "string" then
        return nil
    end

    local normalized = string.lower(category)
    if normalized == "gamepass" or normalized == "level" or normalized == "shop" then
        return normalized
    end

    return nil
end

local function isOwnedEntry(entry)
    return type(entry) == "table" and entry.Owned == true
end

local function setFilterButtonState(button, isActive, isHovering)
    if not (button and button:IsA("TextButton")) then
        return
    end

    local stroke = button:FindFirstChild("TabStroke")
    button.BackgroundColor3 = isActive and Color3.fromRGB(24, 24, 24) or Color3.fromRGB(0, 0, 0)
    button.BackgroundTransparency = isActive and 0.08 or (isHovering and 0.26 or 0.4)
    button.TextTransparency = isActive and 0 or (isHovering and 0.03 or 0.1)
    button.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or (isHovering and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(225, 225, 225))

    if stroke and stroke:IsA("UIStroke") then
        stroke.Transparency = isActive and 0.15 or (isHovering and 0.35 or 0.55)
        stroke.Thickness = isActive and 1.5 or 1
        stroke.Color = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(185, 185, 185)
    end
end

local function refreshFilterButtonStates()
    for filterName, button in pairs(filterButtons) do
        setFilterButtonState(button, filterName == activeFilter, filterName == hoveredFilter)
    end
end

local function isCompactTouchViewport()
    local camera = workspace.CurrentCamera
    local viewportWidth = camera and camera.ViewportSize.X or 0
    return UserInputService.TouchEnabled and viewportWidth > 0 and viewportWidth <= MOBILE_FILTER_VIEWPORT_WIDTH
end

local function getEstimatedAbsoluteWidth(guiObject)
    local absoluteWidth = guiObject.AbsoluteSize.X
    if absoluteWidth > 0 then
        return absoluteWidth
    end

    local parent = guiObject.Parent
    if parent and parent:IsA("GuiObject") then
        return (parent.AbsoluteSize.X * guiObject.Size.X.Scale) + guiObject.Size.X.Offset
    end

    return 0
end

local function sumCompactFilterWidths(widths)
    local total = 0
    for _, filterName in ipairs(filterButtonOrder) do
        total += widths[filterName] or 0
    end
    return total
end

local function fitCompactFilterWidths(widths, availableWidth, minWidth)
    local fittedWidths = {}
    for filterName, width in pairs(widths) do
        fittedWidths[filterName] = width
    end

    local totalWidth = sumCompactFilterWidths(fittedWidths)
    if totalWidth <= availableWidth then
        return fittedWidths
    end

    local scale = availableWidth / totalWidth
    for filterName, width in pairs(fittedWidths) do
        fittedWidths[filterName] = math.max(minWidth, width * scale)
    end

    totalWidth = sumCompactFilterWidths(fittedWidths)
    if totalWidth <= availableWidth then
        return fittedWidths
    end

    local overflow = totalWidth - availableWidth
    while overflow > 0.001 do
        local reducibleWidth = 0
        for _, filterName in ipairs(filterButtonOrder) do
            reducibleWidth += math.max(0, (fittedWidths[filterName] or 0) - minWidth)
        end

        if reducibleWidth <= 0 then
            local equalWidth = availableWidth / #filterButtonOrder
            for _, filterName in ipairs(filterButtonOrder) do
                fittedWidths[filterName] = equalWidth
            end
            return fittedWidths
        end

        local reductionRatio = math.min(1, overflow / reducibleWidth)
        for _, filterName in ipairs(filterButtonOrder) do
            local currentWidth = fittedWidths[filterName] or 0
            local availableReduction = math.max(0, currentWidth - minWidth)
            if availableReduction > 0 then
                fittedWidths[filterName] = math.max(minWidth, currentWidth - (availableReduction * reductionRatio))
            end
        end

        local nextTotalWidth = sumCompactFilterWidths(fittedWidths)
        if math.abs(nextTotalWidth - totalWidth) <= 0.001 then
            break
        end

        totalWidth = nextTotalWidth
        overflow = totalWidth - availableWidth
    end

    if sumCompactFilterWidths(fittedWidths) > availableWidth + 0.001 then
        local equalWidth = availableWidth / #filterButtonOrder
        for _, filterName in ipairs(filterButtonOrder) do
            fittedWidths[filterName] = equalWidth
        end
    end

    return fittedWidths
end

local function getCompactFilterWidths(rowWidth)
    local paddingPixels = MOBILE_FILTER_ROW_PADDING.Offset * math.max(#filterButtonOrder - 1, 0)
    local availableWidth = math.max(rowWidth - paddingPixels, 0)
    local chosenTextSize = MOBILE_FILTER_TEXT_SIZE_OPTIONS[#MOBILE_FILTER_TEXT_SIZE_OPTIONS]
    local chosenWidths = {}

    for _, textSize in ipairs(MOBILE_FILTER_TEXT_SIZE_OPTIONS) do
        local candidateWidths = {}
        local totalWidth = 0

        for _, filterName in ipairs(filterButtonOrder) do
            local button = filterButtons[filterName]
            if button and button:IsA("TextButton") then
                local textBounds = TextService:GetTextSize(button.Text, textSize, button.Font, Vector2.new(1000, 1000))
                local buttonWidth = math.max(MOBILE_FILTER_MIN_BUTTON_WIDTH, textBounds.X + MOBILE_FILTER_BUTTON_HORIZONTAL_PADDING)
                candidateWidths[filterName] = buttonWidth
                totalWidth += buttonWidth
            end
        end

        chosenTextSize = textSize
        chosenWidths = candidateWidths

        if totalWidth <= availableWidth then
            break
        end
    end

    local totalChosenWidth = sumCompactFilterWidths(chosenWidths)

    if totalChosenWidth <= 0 then
        return chosenTextSize, chosenWidths
    end

    if totalChosenWidth < availableWidth then
        local extraPerButton = (availableWidth - totalChosenWidth) / #filterButtonOrder
        for _, filterName in ipairs(filterButtonOrder) do
            chosenWidths[filterName] = (chosenWidths[filterName] or 0) + extraPerButton
        end
    elseif totalChosenWidth > availableWidth then
        chosenWidths = fitCompactFilterWidths(chosenWidths, availableWidth, MOBILE_FILTER_HARD_MIN_BUTTON_WIDTH)
    end

    return chosenTextSize, chosenWidths
end

local function updateFilterRowLayout()
    local useCompactLayout = isCompactTouchViewport()

    filterTabs.Size = useCompactLayout and MOBILE_FILTER_ROW_SIZE or filterTabDefaults.size
    filterTabsLayout.Padding = useCompactLayout and MOBILE_FILTER_ROW_PADDING or filterTabDefaults.padding

    local rowWidth = useCompactLayout and getEstimatedAbsoluteWidth(filterTabs) or 0
    local compactTextSize, compactWidths = nil, nil
    if useCompactLayout and rowWidth > 0 then
        compactTextSize, compactWidths = getCompactFilterWidths(rowWidth)
    end

    for filterName, button in pairs(filterButtons) do
        if button and button:IsA("TextButton") then
            local defaults = filterTabDefaults.buttons[filterName]
            if useCompactLayout and compactTextSize and compactWidths then
                local widthScale = compactWidths[filterName] and (compactWidths[filterName] / rowWidth) or defaults.size.X.Scale
                button.Size = UDim2.new(widthScale, 0, defaults.size.Y.Scale, defaults.size.Y.Offset)
                button.TextSize = compactTextSize
            else
                button.Size = defaults.size
                button.TextSize = defaults.textSize
            end
        end
    end
end

local function bindViewportSizeListener()
    if viewportSizeConnection then
        viewportSizeConnection:Disconnect()
        viewportSizeConnection = nil
    end

    local camera = workspace.CurrentCamera
    if camera then
        viewportSizeConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFilterRowLayout)
    end
end

local function buildVisibleEntries(payload)
    local entries = {}
    if type(payload) ~= "table" or type(payload.Titles) ~= "table" then
        return entries
    end

    for _, entry in ipairs(payload.Titles) do
        local entryCategory = normalizeCategory(entry.Category)
        local shouldShow = activeFilter == "all"
            or (activeFilter == "owned" and isOwnedEntry(entry))
            or entryCategory == activeFilter

        if shouldShow then
            table.insert(entries, entry)
        end
    end

    return entries
end

local function createEmptyStateRow(message, detail)
    normalizeRowMetrics()
    local row = template:Clone()
    row.Name = "EmptyState"
    row.Visible = true
    row.AutoButtonColor = false
    row.Active = false

    local titleName = row:FindFirstChild("TitleName")
    local requirementLabel = row:FindFirstChild("TitleRequiredLevel")
    local statusLabel = row:FindFirstChild("EquipedLabel")

    if titleName then
        titleName.Text = message or "nothing here yet"
        titleEffectPreview.Clear(titleName)
    end
    if requirementLabel then
        requirementLabel.Text = detail or "try another tab"
    end
    if statusLabel then
        statusLabel.Text = ""
    end

    row.Parent = scrollingFrame
end

local function applyPayload(payload)
    normalizeRowMetrics()
    clearRows()
    currentData = nil

    if not payload or type(payload) ~= "table" then
        setCurrentTitleLabel(getFallbackTitleId(), getFallbackTitleName())
        updateCanvasSize()
        return
    end

    currentData = payload
    setCurrentTitleLabel(payload.EquippedTitleId, payload.EquippedTitleName or getFallbackTitleName())

    local visibleEntries = buildVisibleEntries(payload)
    if #visibleEntries == 0 then
        local labelByFilter = {
            all = "no titles found",
            owned = "no owned titles yet",
            level = "no level titles yet",
            shop = "no shop titles yet",
            gamepass = "no gamepass titles yet",
        }
        createEmptyStateRow(labelByFilter[activeFilter] or "nothing here yet", "try another tab")
        updateCanvasSize()
        return
    end

    for _, entry in ipairs(visibleEntries) do
        local rowData = entry
        local row = template:Clone()
        row.Name = rowData.Id
        row.Visible = true
        row.AutoButtonColor = rowData.Action == "equip" or rowData.Action == "buy"
        row.Active = row.AutoButtonColor
        row.Parent = scrollingFrame

        local titleName = row:FindFirstChild("TitleName")
        local requirementLabel = row:FindFirstChild("TitleRequiredLevel")
        local statusLabel = row:FindFirstChild("EquipedLabel")

        if titleName then
            titleName.Text = rowData.Name
            titleEffectPreview.Apply(titleName, rowData.Id)
        end
        if requirementLabel then
            requirementLabel.Text = rowData.RequirementText
        end
        if statusLabel then
            statusLabel.Text = rowData.StatusText
        end

        row.MouseButton1Click:Connect(function()
            if rowData.Action == "equip" then
                local equipSuccess, response = pcall(function()
                    return equipTitle:InvokeServer(rowData.Id)
                end)
                if equipSuccess and type(response) == "table" then
                    applyPayload(response)
                end
            elseif rowData.Action == "buy" then
                MarketplaceService:PromptGamePassPurchase(player, titleConfig.TITLE_PACK_GAMEPASS_ID)
            end
        end)
    end

    updateCanvasSize()
end

local function refreshUI()
    refreshToken += 1
    local token = refreshToken

    local success, payload = pcall(function()
        return getTitleData:InvokeServer()
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

local function bindEquippedValue(valueObject)
    if boundEquippedValue == valueObject then
        return
    end

    boundEquippedValue = valueObject
    equippedValue = valueObject

    valueObject:GetPropertyChangedSignal("Value"):Connect(function()
        setCurrentTitleLabel(valueObject.Value, titleConfig.GetDisplayName(valueObject.Value))
    end)
end

screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if screenGui.Enabled then
        refreshUI()
    else
        titleEffectPreview.Clear(currentTitleLabel)
        titleEffectPreview.ClearContainer(scrollingFrame)
    end
end)

titleDataUpdated.OnClientEvent:Connect(function()
    if screenGui.Enabled then
        refreshUI()
    else
        setCurrentTitleLabel(getFallbackTitleId(), getFallbackTitleName())
        titleEffectPreview.ClearContainer(scrollingFrame)
    end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(playerOrUserId, gamePassId, wasPurchased)
    local finishedUserId = nil
    if typeof(playerOrUserId) == "Instance" and playerOrUserId:IsA("Player") then
        finishedUserId = playerOrUserId.UserId
    elseif type(playerOrUserId) == "number" then
        finishedUserId = playerOrUserId
    end

    if finishedUserId ~= player.UserId or gamePassId ~= titleConfig.TITLE_PACK_GAMEPASS_ID or not wasPurchased then
        return
    end

    task.spawn(function()
        for _ = 1, 5 do
            task.wait(1)
            refreshUI()
            if currentData and currentData.TitlePackOwned then
                break
            end
        end
    end)
end)

player.ChildAdded:Connect(function(child)
    if child.Name == "EquippedTitle" and child:IsA("StringValue") then
        bindEquippedValue(child)
        setCurrentTitleLabel(child.Value, titleConfig.GetDisplayName(child.Value))
    end
end)

equippedValue = player:FindFirstChild("EquippedTitle") or player:WaitForChild("EquippedTitle", 10)
if equippedValue and equippedValue:IsA("StringValue") then
    bindEquippedValue(equippedValue)
end

for filterName, button in pairs(filterButtons) do
    if button and button:IsA("TextButton") then
        button.MouseEnter:Connect(function()
            hoveredFilter = filterName
            refreshFilterButtonStates()
        end)

        button.MouseLeave:Connect(function()
            if hoveredFilter == filterName then
                hoveredFilter = nil
                refreshFilterButtonStates()
            end
        end)

        button.MouseButton1Click:Connect(function()
            if activeFilter == filterName then
                return
            end
            activeFilter = filterName
            refreshFilterButtonStates()
            applyPayload(currentData)
        end)
    end
end

mainframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateFilterRowLayout)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    bindViewportSizeListener()
    updateFilterRowLayout()
end)

bindViewportSizeListener()
updateFilterRowLayout()
refreshFilterButtonStates()
setCurrentTitleLabel(getFallbackTitleId(), getFallbackTitleName())
refreshUI()
