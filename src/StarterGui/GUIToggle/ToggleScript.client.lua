local button = script.Parent:WaitForChild("EyeButton")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local workspace = game:GetService("Workspace")

-- We cache each GUI's previous Enabled state so toggling back on doesn't force-open everything.
-- IMPORTANT: default to TRUE so titles are visible on first spawn.
local guiVisible = true
local cachedGuiStates = {}

-- Ensure the toggle doesn't start in an "off" state from previous play sessions.
-- (LocalScripts can be preserved between Play sessions in Studio, depending on settings.)
guiVisible = true

-- Eye icons
local EYE_OPEN = "rbxassetid://127468172207913"
local EYE_CLOSED = "rbxassetid://103941529358555"

-- Scale down for mobile devices
local uiScale = button:FindFirstChild("UIScale")
if uiScale then
	local isMobile = game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").KeyboardEnabled
	if isMobile then
		uiScale.Scale = 0.75 -- 75% size on mobile
	end
end

local function toggleGUIs()
	guiVisible = not guiVisible
	
	-- Always keep touch controls enabled on mobile.
	local touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui and touchGui:IsA("ScreenGui") then
		touchGui.Enabled = true
	end
	
	-- Toggle ScreenGuis (but never TouchGui)
	for _, gui in playerGui:GetChildren() do
		if gui:IsA("ScreenGui") and gui.Name ~= "GUIToggle" and gui.Name ~= "TouchGui" then
			if not guiVisible then
				cachedGuiStates[gui] = gui.Enabled
				gui.Enabled = false
			else
				local prev = cachedGuiStates[gui]
				if prev == nil then prev = true end
				gui.Enabled = prev
			end
		end
	end
	
	-- Toggle NameTags (LOCAL only)
	-- New nametag system parents BillboardGuis to character Heads.
	-- We only change visibility on *this client's* screen.
	for _, plr in game:GetService("Players"):GetPlayers() do
		local char = plr.Character
		local head = char and char:FindFirstChild("Head")
		local tag = head and (head:FindFirstChild("NameTag") or head:FindFirstChild("SadCaveNameTag"))
		if tag and tag:IsA("BillboardGui") then
			tag.Enabled = guiVisible
		end
	end
	-- Also support any remaining legacy tags stored in Workspace.NameTags
	local nameTagsFolder = workspace:FindFirstChild("NameTags")
	if nameTagsFolder then
		for _, nameTag in nameTagsFolder:GetDescendants() do
			if nameTag:IsA("BillboardGui") then
				nameTag.Enabled = guiVisible
			end
		end
	end
	
	-- Re-assert touch controls after toggling everything else (some scripts may flip it)
	if touchGui and touchGui:IsA("ScreenGui") then
		touchGui.Enabled = true
	end
	
	-- Update button appearance
	if guiVisible then
		button.Image = EYE_OPEN
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	else
		button.Image = EYE_CLOSED
		button.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
	end
end

-- Make sure tags start ON locally when you press Play
-- (so your title is visible by default)
task.defer(function()
	for _, plr in game:GetService("Players"):GetPlayers() do
		local char = plr.Character
		local head = char and char:FindFirstChild("Head")
		local tag = head and head:FindFirstChild("NameTag")
		if tag and tag:IsA("BillboardGui") then
			tag.Enabled = true
		end
	end
	local nameTagsFolder = workspace:FindFirstChild("NameTags")
	if nameTagsFolder then
		for _, nameTag in nameTagsFolder:GetDescendants() do
			if nameTag:IsA("BillboardGui") then
				nameTag.Enabled = true
			end
		end
	end
end)

button.MouseButton1Click:Connect(toggleGUIs)

-- Hover effect
button.MouseEnter:Connect(function()
	button.BackgroundColor3 = guiVisible and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(100, 30, 30)
end)

button.MouseLeave:Connect(function()
	button.BackgroundColor3 = guiVisible and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(80, 20, 20)
end)

-- Handle name tags added during gameplay (LOCAL only)
-- New system: tags appear under Head, so watch characters as they spawn.
local Players = game:GetService("Players")

local function applyToCharacter(char)
	local head = char and char:FindFirstChild("Head")
	if not head then return end

	-- IMPORTANT:
	-- There are TWO different "hide tags" systems in this place:
	-- 1) GUIToggle (eye button) -> hides *all* ScreenGuis + overhead BillboardGuis locally.
	-- 2) settingui hide tags toggle -> hides custom overhead tags but should persist for joins/resets.
	--
	-- This GUIToggle script now also respects the settingui toggle if it exists.
	local settingsUi = playerGui:FindFirstChild("settingui")
	local hideTagsSetting = settingsUi
		and settingsUi:FindFirstChild("mainui2")
		and settingsUi.mainui2:FindFirstChild("ScrollingFrame")
		and settingsUi.mainui2.ScrollingFrame:FindFirstChild("settingframe7")
		and settingsUi.mainui2.ScrollingFrame.settingframe7:FindFirstChild("HideTagsEnabled")

	local shouldShowTags = guiVisible
	if hideTagsSetting and hideTagsSetting:IsA("BoolValue") and hideTagsSetting.Value == true then
		shouldShowTags = false
	end

	local function applyToBillboard(bbg: BillboardGui)
		-- Only affect custom overhead/name tags (and known legacy tag names)
		local n = string.lower(bbg.Name)
		local isCustom = (bbg:GetAttribute("IsCustomNameTag") == true)
		if isCustom or bbg.Name == "NameTag" or bbg.Name == "SadCaveNameTag" or bbg.Name == "OverheadGui"
			or string.find(n, "overhead") or string.find(n, "nametag") or string.find(n, "title") then
			bbg.Enabled = shouldShowTags
		end
	end

	-- Apply to existing tags now
	for _, child in head:GetChildren() do
		if child:IsA("BillboardGui") then
			applyToBillboard(child)
		end
	end

	-- And apply to tags created later (common on join/reset)
	head.ChildAdded:Connect(function(inst)
		if inst:IsA("BillboardGui") then
			applyToBillboard(inst)
		end
	end)
end

local function hookPlayer(plr)
	plr.CharacterAdded:Connect(function(char)
		-- let the server create/tag it first
		task.wait(0.2)
		applyToCharacter(char)
	end)
	if plr.Character then
		applyToCharacter(plr.Character)
	end
end

Players.PlayerAdded:Connect(hookPlayer)
for _, p in Players:GetPlayers() do
	hookPlayer(p)
end

-- Legacy support
local nameTagsFolder = workspace:FindFirstChild("NameTags")
if nameTagsFolder then
	nameTagsFolder.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BillboardGui") then
			descendant.Enabled = guiVisible
		end
	end)
end
