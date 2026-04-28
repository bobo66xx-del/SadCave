local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local screenGui = script.Parent

local TitleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))

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
	panel = Color3.fromRGB(27, 24, 30),
	row = Color3.fromRGB(34, 30, 38),
	rowHover = Color3.fromRGB(42, 37, 47),
	text = Color3.fromRGB(225, 215, 200),
	muted = Color3.fromRGB(150, 142, 132),
	stroke = Color3.fromRGB(225, 215, 200),
}

local CATEGORY_ORDER = {
	level = 1,
	gamepass = 2,
	presence = 3,
	exploration = 4,
	achievement = 5,
	seasonal = 6,
}

local ACHIEVEMENT_HINTS = {
	said_something = "finish a conversation",
	sat_down = "sit for a while",
	left_a_mark = "write a note",
	came_back = "come back again",
	heard_them_all = "hear every voice",
	knows_every_chair = "sit in different places",
	keeps_coming_back = "keep coming back",
	part_of_the_walls = "keep returning",
	up_too_late = "visit late at night",
	fell_asleep_here = "rest for a long while",
	one_of_us = "join the group",
	day_one = "arrive early",
}

local ownedTitleIds = {}
local equippedTitleId = nil
local currentTab = "owned"

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.new(0.5, 0, 0.5, 0)
root.Size = UDim2.new(0.7, 0, 0.7, 0)
root.BackgroundColor3 = COLORS.background
root.BackgroundTransparency = 0.08
root.BorderSizePixel = 0
root.Visible = false
root.ZIndex = 20
root.Parent = screenGui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 8)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Color = COLORS.stroke
rootStroke.Transparency = 0.82
rootStroke.Thickness = 1
rootStroke.Parent = root

local rootSize = Instance.new("UISizeConstraint")
rootSize.MinSize = Vector2.new(290, 280)
rootSize.MaxSize = Vector2.new(620, 520)
rootSize.Parent = root

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = root

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, 0, 0, 34)
header.ZIndex = 21
header.Parent = root

local tabs = Instance.new("Frame")
tabs.Name = "Tabs"
tabs.BackgroundTransparency = 1
tabs.Size = UDim2.new(1, -38, 1, 0)
tabs.ZIndex = 21
tabs.Parent = header

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabs

local function makeTab(name, order)
	local tab = Instance.new("TextButton")
	tab.Name = name .. "Tab"
	tab.LayoutOrder = order
	tab.Size = UDim2.new(0, 84, 1, 0)
	tab.BackgroundColor3 = COLORS.panel
	tab.BackgroundTransparency = 0.15
	tab.BorderSizePixel = 0
	tab.AutoButtonColor = false
	tab.Font = Enum.Font.Gotham
	tab.Text = name
	tab.TextSize = 14
	tab.TextColor3 = COLORS.text
	tab.ZIndex = 22
	tab.Parent = tabs

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = tab

	return tab
end

local ownedTab = makeTab("owned", 1)
local lockedTab = makeTab("locked", 2)

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
closeButton.TextSize = 14
closeButton.TextColor3 = COLORS.muted
closeButton.ZIndex = 22
closeButton.Parent = header

local body = Instance.new("Frame")
body.Name = "Body"
body.Position = UDim2.new(0, 0, 0, 42)
body.Size = UDim2.new(1, 0, 1, -42)
body.BackgroundTransparency = 1
body.ZIndex = 21
body.Parent = root

local function makeScroll(name)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(110, 102, 94)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
	scroll.ZIndex = 21
	scroll.Parent = body

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 5)
	list.Parent = scroll

	local inset = Instance.new("UIPadding")
	inset.PaddingTop = UDim.new(0, 2)
	inset.PaddingBottom = UDim.new(0, 8)
	inset.PaddingLeft = UDim.new(0, 2)
	inset.PaddingRight = UDim.new(0, 6)
	inset.Parent = scroll

	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 12)
	end)

	return scroll
end

local ownedScroll = makeScroll("OwnedScroll")
local lockedScroll = makeScroll("LockedScroll")
lockedScroll.Visible = false

local allTitles = {}
for _, title in pairs(TitleConfig.titles) do
	table.insert(allTitles, title)
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

table.sort(allTitles, function(left, right)
	local leftCategory = CATEGORY_ORDER[left.category] or 99
	local rightCategory = CATEGORY_ORDER[right.category] or 99
	if leftCategory ~= rightCategory then
		return leftCategory < rightCategory
	end

	local leftValue = sortValue(left)
	local rightValue = sortValue(right)
	if typeof(leftValue) == typeof(rightValue) then
		return leftValue < rightValue
	end

	return tostring(leftValue) < tostring(rightValue)
end)

local function clearRows(scroll)
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function getHint(title)
	if title.category == "level" and title.levelRequired then
		return "reach level " .. tostring(title.levelRequired)
	end
	if title.category == "gamepass" then
		return "buy the title pack"
	end
	if title.category == "presence" and title.hoursRequired then
		if title.hoursRequired == 1 then
			return "play for 1 hour"
		end
		return "play for " .. tostring(title.hoursRequired) .. " hours"
	end
	if title.category == "exploration" and title.zoneId then
		return "discover " .. string.gsub(title.zoneId, "_", " ")
	end
	if title.category == "achievement" then
		return ACHIEVEMENT_HINTS[title.id] or "do something special"
	end
	if title.category == "seasonal" then
		return "during a special event"
	end
	return "keep exploring"
end

local function makeDot(parent, color, xOffset)
	local dot = Instance.new("Frame")
	dot.Name = "ColorDot"
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, xOffset, 0.5, 0)
	dot.Size = UDim2.new(0, 12, 0, 12)
	dot.BackgroundColor3 = color
	dot.BorderSizePixel = 0
	dot.ZIndex = 24
	dot.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = dot

	return dot
end

local function makeTitleText(parent, title, widthScale)
	local label = Instance.new("TextLabel")
	label.Name = "TitleText"
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 34, 0.5, 0)
	label.Size = UDim2.new(widthScale, -38, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.Text = title.display
	label.TextSize = 12
	label.TextColor3 = COLORS.text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.ZIndex = 24
	label.Parent = parent
	return label
end

local function createRow(title, owned, order)
	local row
	if owned then
		row = Instance.new("TextButton")
		row.Text = ""
		row.AutoButtonColor = false
	else
		row = Instance.new("Frame")
	end

	row.Name = title.id
	row.LayoutOrder = order
	row.Size = UDim2.new(1, -8, 0, 36)
	row.BackgroundColor3 = COLORS.row
	row.BackgroundTransparency = owned and 0.1 or 0.35
	row.BorderSizePixel = 0
	row.ZIndex = 23

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = row

	makeDot(row, title.tintColor or COLORS.text, 12)
	makeTitleText(row, title, owned and 0.78 or 0.5)

	if owned then
		local equippedDot = makeDot(row, title.tintColor or COLORS.text, 0)
		equippedDot.Name = "EquippedDot"
		equippedDot.AnchorPoint = Vector2.new(1, 0.5)
		equippedDot.Position = UDim2.new(1, -14, 0.5, 0)
		equippedDot.Size = UDim2.new(0, 9, 0, 9)
		equippedDot.Visible = title.id == equippedTitleId

		row.MouseEnter:Connect(function()
			row.BackgroundColor3 = COLORS.rowHover
		end)
		row.MouseLeave:Connect(function()
			row.BackgroundColor3 = COLORS.row
		end)
		row.MouseButton1Click:Connect(function()
			if title.id == equippedTitleId then
				UnequipTitle:FireServer()
			else
				EquipTitle:FireServer(title.id)
			end
		end)
	else
		local hint = Instance.new("TextLabel")
		hint.Name = "HintText"
		hint.AnchorPoint = Vector2.new(1, 0.5)
		hint.Position = UDim2.new(1, -12, 0.5, 0)
		hint.Size = UDim2.new(0.5, -18, 1, 0)
		hint.BackgroundTransparency = 1
		hint.Font = Enum.Font.Gotham
		hint.Text = getHint(title)
		hint.TextSize = 11
		hint.TextColor3 = COLORS.muted
		hint.TextXAlignment = Enum.TextXAlignment.Right
		hint.TextTruncate = Enum.TextTruncate.AtEnd
		hint.ZIndex = 24
		hint.Parent = row
	end

	return row
end

local function updateTabs()
	local ownedActive = currentTab == "owned"
	ownedScroll.Visible = ownedActive
	lockedScroll.Visible = not ownedActive
	ownedTab.BackgroundTransparency = ownedActive and 0.05 or 0.35
	lockedTab.BackgroundTransparency = ownedActive and 0.35 or 0.05
end

local function renderRows()
	clearRows(ownedScroll)
	clearRows(lockedScroll)

	local ownedOrder = 0
	local lockedOrder = 0
	for _, title in ipairs(allTitles) do
		if ownedTitleIds[title.id] then
			ownedOrder += 1
			createRow(title, true, ownedOrder).Parent = ownedScroll
		else
			lockedOrder += 1
			createRow(title, false, lockedOrder).Parent = lockedScroll
		end
	end
end

local function setOwnedTitleIds(titleIds)
	ownedTitleIds = {}
	if typeof(titleIds) ~= "table" then
		return
	end

	for _, titleId in ipairs(titleIds) do
		if typeof(titleId) == "string" then
			ownedTitleIds[titleId] = true
		end
	end
end

ownedTab.MouseButton1Click:Connect(function()
	currentTab = "owned"
	updateTabs()
end)

lockedTab.MouseButton1Click:Connect(function()
	currentTab = "locked"
	updateTabs()
end)

closeButton.MouseButton1Click:Connect(function()
	root.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not root.Visible then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape then
		root.Visible = false
	end
end)

TitleDataUpdated.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	if payload.ownedTitleIds then
		setOwnedTitleIds(payload.ownedTitleIds)
	end

	if payload.notificationOnly ~= true and typeof(payload.equippedTitle) == "string" then
		equippedTitleId = payload.equippedTitle
	elseif not equippedTitleId and typeof(payload.currentEquippedTitle) == "string" then
		equippedTitleId = payload.currentEquippedTitle
	end

	renderRows()
end)

updateTabs()
renderRows()
