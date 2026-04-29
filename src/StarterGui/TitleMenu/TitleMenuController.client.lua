local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local screenGui = script.Parent

local TitleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))

local function ensureBindable(name)
	local existing = screenGui:FindFirstChild(name)
	if existing and not existing:IsA("BindableEvent") then
		existing:Destroy()
		existing = nil
	end

	if not existing then
		existing = Instance.new("BindableEvent")
		existing.Name = name
		existing.Parent = screenGui
	end

	return existing
end

local OpenRequested = ensureBindable("OpenRequested")
local CloseRequested = ensureBindable("CloseRequested")

local titleRemotes = ReplicatedStorage:WaitForChild("TitleRemotes", 10)
if not titleRemotes then
	warn("[TitleMenu] ReplicatedStorage.TitleRemotes was not found")
	return
end

local TitleDataUpdated = titleRemotes:WaitForChild("TitleDataUpdated", 10)
local EquipTitle = titleRemotes:WaitForChild("EquipTitle", 10)
local UnequipTitle = titleRemotes:WaitForChild("UnequipTitle", 10)

if not TitleDataUpdated or not EquipTitle or not UnequipTitle then
	warn("[TitleMenu] Title remotes were not ready")
	return
end

local COLORS = {
	background = Color3.fromRGB(20, 18, 22),
	row = Color3.fromRGB(34, 30, 38),
	rowHover = Color3.fromRGB(42, 37, 47),
	text = Color3.fromRGB(225, 215, 200),
	muted = Color3.fromRGB(150, 142, 132),
	scroll = Color3.fromRGB(110, 102, 94),
}

local CATEGORY_SEQUENCE = {
	"level",
	"gamepass",
	"presence",
	"exploration",
	"achievement",
	"seasonal",
}

local CATEGORY_ORDER = {}
for index, category in ipairs(CATEGORY_SEQUENCE) do
	CATEGORY_ORDER[category] = index
end

local ACHIEVEMENT_HINTS = {
	said_something = "say something to someone",
	sat_down = "the first time you rest",
	left_a_mark = "leave a note behind",
	came_back = "come back another time",
	keeps_coming_back = "keep finding your way back",
	part_of_the_walls = "be here long enough to belong",
	heard_them_all = "hear every voice",
	knows_every_chair = "find a different seat each time",
	up_too_late = "stay until the early hours",
	fell_asleep_here = "rest for a long while",
	one_of_us = "join the group",
	day_one = "be here from the start",
}

local OPEN_POSITION = UDim2.new(1, 0, 0.5, 0)
local CLOSED_POSITION = UDim2.new(2, 0, 0.5, 0)
local OPEN_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local CLOSE_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local DIM_TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local HOVER_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local ownedTitleIds = {}
local equippedTitleId = nil
local rowRecords = {}
local sectionFrames = {}
local isOpen = false
local activeRootTween = nil
local activeDimTween = nil

for _, childName in ipairs({ "DimOverlay", "Root" }) do
	local existing = screenGui:FindFirstChild(childName)
	if existing then
		existing:Destroy()
	end
end

local allTitles = {}
local titlesByCategory = {}
for _, category in ipairs(CATEGORY_SEQUENCE) do
	titlesByCategory[category] = {}
end

for _, title in pairs(TitleConfig.titles) do
	table.insert(allTitles, title)

	if not titlesByCategory[title.category] then
		titlesByCategory[title.category] = {}
	end
	table.insert(titlesByCategory[title.category], title)
end

local function sortValue(title)
	if title.category == "level" then
		return title.levelRequired or 0
	end

	if title.category == "presence" then
		return title.hoursRequired or 0
	end

	return title.display or title.id
end

local function sortTitles(left, right)
	local leftValue = sortValue(left)
	local rightValue = sortValue(right)

	if typeof(leftValue) == typeof(rightValue) then
		if leftValue == rightValue then
			return (left.display or left.id) < (right.display or right.id)
		end

		return leftValue < rightValue
	end

	return tostring(leftValue) < tostring(rightValue)
end

for _, titles in pairs(titlesByCategory) do
	table.sort(titles, sortTitles)
end

table.sort(allTitles, function(left, right)
	local leftCategory = CATEGORY_ORDER[left.category] or 99
	local rightCategory = CATEGORY_ORDER[right.category] or 99
	if leftCategory ~= rightCategory then
		return leftCategory < rightCategory
	end

	return sortTitles(left, right)
end)

local function titleLayoutOrder(title, owned)
	local categoryTitles = titlesByCategory[title.category] or {}
	local titleIndex = 999
	for index, candidate in ipairs(categoryTitles) do
		if candidate.id == title.id then
			titleIndex = index
			break
		end
	end

	return (owned and 1000 or 5000) + titleIndex
end

local function getHint(title)
	if title.category == "level" and title.levelRequired then
		return "reach level " .. tostring(title.levelRequired)
	end

	if title.category == "gamepass" then
		return "from the title pack"
	end

	if title.category == "presence" and title.hoursRequired then
		if title.hoursRequired == 1 then
			return "play for 1 hour"
		end

		return "play for " .. tostring(title.hoursRequired) .. " hours"
	end

	if title.category == "exploration" and title.zoneId then
		return "find the " .. string.gsub(title.zoneId, "_", " ")
	end

	if title.category == "achievement" then
		return ACHIEVEMENT_HINTS[title.id] or "keep exploring"
	end

	if title.category == "seasonal" then
		return "only during certain times"
	end

	return "keep exploring"
end

local function getTitleTextColor(title)
	if title.effect and title.effect ~= "none" and typeof(title.tintColor) == "Color3" then
		return title.tintColor
	end

	return COLORS.text
end

local function normalizeOwnedTitleIds(titleIds)
	local nextOwnedTitleIds = {}
	if typeof(titleIds) ~= "table" then
		return nextOwnedTitleIds
	end

	for _, titleId in ipairs(titleIds) do
		if typeof(titleId) == "string" then
			nextOwnedTitleIds[titleId] = true
		end
	end

	return nextOwnedTitleIds
end

local dimOverlay = Instance.new("TextButton")
dimOverlay.Name = "DimOverlay"
dimOverlay.Size = UDim2.new(1, 0, 1, 0)
dimOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dimOverlay.BackgroundTransparency = 1
dimOverlay.BorderSizePixel = 0
dimOverlay.AutoButtonColor = false
dimOverlay.Text = ""
dimOverlay.Active = false
dimOverlay.Visible = false
dimOverlay.ZIndex = 10
dimOverlay.Parent = screenGui

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(1, 0.5)
root.Position = CLOSED_POSITION
root.Size = UDim2.new(0.34, 0, 1, 0)
root.BackgroundColor3 = COLORS.background
root.BackgroundTransparency = 0.05
root.BorderSizePixel = 0
root.Visible = true
root.ZIndex = 20
root.Parent = screenGui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 8)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Color = COLORS.text
rootStroke.Transparency = 0.82
rootStroke.Thickness = 1
rootStroke.Parent = root

local rootSize = Instance.new("UISizeConstraint")
rootSize.MinSize = Vector2.new(320, 0)
rootSize.MaxSize = Vector2.new(520, math.huge)
rootSize.Parent = root

local rootPadding = Instance.new("UIPadding")
rootPadding.PaddingTop = UDim.new(0, 12)
rootPadding.PaddingBottom = UDim.new(0, 12)
rootPadding.PaddingLeft = UDim.new(0, 12)
rootPadding.PaddingRight = UDim.new(0, 12)
rootPadding.Parent = root

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, 0, 0, 38)
header.ZIndex = 21
header.Parent = root

local headerTitle = Instance.new("TextLabel")
headerTitle.Name = "Title"
headerTitle.BackgroundTransparency = 1
headerTitle.Position = UDim2.new(0, 0, 0, 0)
headerTitle.Size = UDim2.new(1, -36, 1, 0)
headerTitle.Font = Enum.Font.Gotham
headerTitle.Text = "your titles"
headerTitle.TextSize = 14
headerTitle.TextColor3 = COLORS.text
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.TextYAlignment = Enum.TextYAlignment.Center
headerTitle.ZIndex = 22
headerTitle.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, 0, 0, 0)
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.BackgroundTransparency = 1
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Font = Enum.Font.Gotham
closeButton.Text = "x"
closeButton.TextSize = 16
closeButton.TextColor3 = COLORS.text
closeButton.TextTransparency = 0.35
closeButton.ZIndex = 22
closeButton.Parent = header

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Body"
scroll.Position = UDim2.new(0, 0, 0, 44)
scroll.Size = UDim2.new(1, 0, 1, -44)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = COLORS.scroll
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 21
scroll.Parent = root

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 12)
scrollLayout.Parent = scroll

local scrollPadding = Instance.new("UIPadding")
scrollPadding.PaddingTop = UDim.new(0, 2)
scrollPadding.PaddingBottom = UDim.new(0, 16)
scrollPadding.PaddingLeft = UDim.new(0, 0)
scrollPadding.PaddingRight = UDim.new(0, 6)
scrollPadding.Parent = scroll

local function makeSection(category, order)
	local section = Instance.new("Frame")
	section.Name = category .. "Section"
	section.BackgroundTransparency = 1
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.Size = UDim2.new(1, 0, 0, 0)
	section.LayoutOrder = order
	section.ZIndex = 21
	section.Parent = scroll

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = section

	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "SectionHeader"
	headerFrame.BackgroundTransparency = 1
	headerFrame.Size = UDim2.new(1, 0, 0, 24)
	headerFrame.LayoutOrder = 0
	headerFrame.ZIndex = 22
	headerFrame.Parent = section

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 0, 0, 0)
	label.Size = UDim2.new(1, 0, 0, 17)
	label.Font = Enum.Font.Gotham
	label.Text = category
	label.TextSize = 13
	label.TextColor3 = COLORS.text
	label.TextTransparency = 0.3
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 23
	label.Parent = headerFrame

	local rule = Instance.new("Frame")
	rule.Name = "Rule"
	rule.AnchorPoint = Vector2.new(0, 1)
	rule.Position = UDim2.new(0, 0, 1, 0)
	rule.Size = UDim2.new(1, 0, 0, 1)
	rule.BackgroundColor3 = COLORS.text
	rule.BackgroundTransparency = 0.85
	rule.BorderSizePixel = 0
	rule.ZIndex = 23
	rule.Parent = headerFrame

	sectionFrames[category] = section
end

for order, category in ipairs(CATEGORY_SEQUENCE) do
	makeSection(category, order)
end

local function makeOwnedRow(title)
	local row = Instance.new("TextButton")
	row.Name = title.id
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundColor3 = COLORS.row
	row.BackgroundTransparency = 0.1
	row.BorderSizePixel = 0
	row.AutoButtonColor = false
	row.Text = ""
	row.ZIndex = 23

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = row

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleText"
	titleLabel.Position = UDim2.new(0, 12, 0, 5)
	titleLabel.Size = UDim2.new(1, -24, 0, 16)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.Text = title.display
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = getTitleTextColor(title)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.ZIndex = 24
	titleLabel.Parent = row

	local wearingLabel = Instance.new("TextLabel")
	wearingLabel.Name = "WearingLabel"
	wearingLabel.AnchorPoint = Vector2.new(1, 0)
	wearingLabel.Position = UDim2.new(1, -12, 0, 20)
	wearingLabel.Size = UDim2.new(0, 90, 0, 12)
	wearingLabel.BackgroundTransparency = 1
	wearingLabel.Font = Enum.Font.Gotham
	wearingLabel.Text = "wearing"
	wearingLabel.TextSize = 10
	wearingLabel.TextColor3 = COLORS.text
	wearingLabel.TextTransparency = 0.5
	wearingLabel.TextXAlignment = Enum.TextXAlignment.Right
	wearingLabel.TextYAlignment = Enum.TextYAlignment.Center
	wearingLabel.Visible = title.id == equippedTitleId
	wearingLabel.ZIndex = 24
	wearingLabel.Parent = row

	row.MouseEnter:Connect(function()
		TweenService:Create(row, HOVER_TWEEN, {
			BackgroundColor3 = COLORS.rowHover,
		}):Play()
	end)

	row.MouseLeave:Connect(function()
		TweenService:Create(row, HOVER_TWEEN, {
			BackgroundColor3 = COLORS.row,
		}):Play()
	end)

	row.MouseButton1Click:Connect(function()
		if title.id == equippedTitleId then
			UnequipTitle:FireServer()
		else
			EquipTitle:FireServer(title.id)
		end
	end)

	return row, wearingLabel
end

local function makeLockedRow(title)
	local row = Instance.new("Frame")
	row.Name = title.id
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundColor3 = COLORS.row
	row.BackgroundTransparency = 0.4
	row.BorderSizePixel = 0
	row.ZIndex = 23

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = row

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleText"
	titleLabel.Position = UDim2.new(0, 12, 0, 0)
	titleLabel.Size = UDim2.new(0.4, -12, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.Text = title.display
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = COLORS.text
	titleLabel.TextTransparency = 0.4
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.ZIndex = 24
	titleLabel.Parent = row

	local hintLabel = Instance.new("TextLabel")
	hintLabel.Name = "HintText"
	hintLabel.AnchorPoint = Vector2.new(1, 0.5)
	hintLabel.Position = UDim2.new(1, -14, 0.5, 0)
	hintLabel.Size = UDim2.new(0.6, -18, 1, 0)
	hintLabel.BackgroundTransparency = 1
	hintLabel.Font = Enum.Font.Gotham
	hintLabel.Text = getHint(title)
	hintLabel.TextSize = 11
	hintLabel.TextColor3 = COLORS.text
	hintLabel.TextTransparency = 0.4
	hintLabel.TextXAlignment = Enum.TextXAlignment.Right
	hintLabel.TextYAlignment = Enum.TextYAlignment.Center
	hintLabel.TextTruncate = Enum.TextTruncate.AtEnd
	hintLabel.ZIndex = 24
	hintLabel.Parent = row

	return row
end

local function createRow(title, owned)
	local row, wearingLabel
	if owned then
		row, wearingLabel = makeOwnedRow(title)
	else
		row = makeLockedRow(title)
	end

	row.LayoutOrder = titleLayoutOrder(title, owned)
	row.Parent = sectionFrames[title.category] or sectionFrames.level
	rowRecords[title.id] = {
		row = row,
		owned = owned,
		wearingLabel = wearingLabel,
	}
end

local function replaceRow(title, owned)
	local existingRecord = rowRecords[title.id]
	if existingRecord and existingRecord.row then
		existingRecord.row:Destroy()
	end

	createRow(title, owned)
end

local function updateWearing(previousTitleId, nextTitleId)
	if previousTitleId and rowRecords[previousTitleId] and rowRecords[previousTitleId].wearingLabel then
		rowRecords[previousTitleId].wearingLabel.Visible = false
	end

	if nextTitleId and rowRecords[nextTitleId] and rowRecords[nextTitleId].wearingLabel then
		rowRecords[nextTitleId].wearingLabel.Visible = true
	end
end

local function applyOwnedDiff(nextOwnedTitleIds)
	for _, title in ipairs(allTitles) do
		local wasOwned = ownedTitleIds[title.id] == true
		local isOwned = nextOwnedTitleIds[title.id] == true
		local record = rowRecords[title.id]

		if not record or record.owned ~= isOwned or wasOwned ~= isOwned then
			replaceRow(title, isOwned)
		end
	end

	ownedTitleIds = nextOwnedTitleIds
end

for _, title in ipairs(allTitles) do
	createRow(title, false)
end

local function cancelTween(tween)
	if tween then
		tween:Cancel()
	end
end

local function openDrawer()
	if isOpen then
		return
	end

	isOpen = true
	cancelTween(activeRootTween)
	cancelTween(activeDimTween)

	dimOverlay.Visible = true
	dimOverlay.Active = true

	activeRootTween = TweenService:Create(root, OPEN_TWEEN, {
		Position = OPEN_POSITION,
	})
	activeDimTween = TweenService:Create(dimOverlay, DIM_TWEEN, {
		BackgroundTransparency = 0.75,
	})

	activeRootTween:Play()
	activeDimTween:Play()
end

local function closeDrawer(shouldBroadcast)
	if not isOpen then
		return
	end

	isOpen = false
	cancelTween(activeRootTween)
	cancelTween(activeDimTween)

	dimOverlay.Active = false

	activeRootTween = TweenService:Create(root, CLOSE_TWEEN, {
		Position = CLOSED_POSITION,
	})
	activeDimTween = TweenService:Create(dimOverlay, DIM_TWEEN, {
		BackgroundTransparency = 1,
	})

	activeRootTween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed and not isOpen then
			dimOverlay.Visible = false
		end
	end)

	activeRootTween:Play()
	activeDimTween:Play()

	if shouldBroadcast then
		CloseRequested:Fire()
	end
end

OpenRequested.Event:Connect(openDrawer)

CloseRequested.Event:Connect(function()
	closeDrawer(false)
end)

dimOverlay.MouseButton1Click:Connect(function()
	closeDrawer(true)
end)

closeButton.MouseButton1Click:Connect(function()
	closeDrawer(true)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isOpen then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape then
		closeDrawer(true)
	end
end)

TitleDataUpdated.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	local previousEquippedTitleId = equippedTitleId
	local nextEquippedTitleId = equippedTitleId
	if payload.notificationOnly ~= true and typeof(payload.equippedTitle) == "string" then
		nextEquippedTitleId = payload.equippedTitle
	elseif not equippedTitleId and typeof(payload.currentEquippedTitle) == "string" then
		nextEquippedTitleId = payload.currentEquippedTitle
	end

	equippedTitleId = nextEquippedTitleId

	if payload.ownedTitleIds then
		applyOwnedDiff(normalizeOwnedTitleIds(payload.ownedTitleIds))
	end

	updateWearing(previousEquippedTitleId, equippedTitleId)
end)
