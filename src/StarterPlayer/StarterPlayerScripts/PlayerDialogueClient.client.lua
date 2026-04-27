local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local dialogueData = require(ReplicatedStorage:WaitForChild("DialogueData"))
local characterConfigs = dialogueData.Characters or {}
local config = dialogueData.Player or {}
local styles = config.styles or {}
local uiStyle = config.uiStyle or {}

local remotes = ReplicatedStorage:WaitForChild("DialogueRemotes")
local playPlayerDialogueRemote = remotes:WaitForChild("PlayPlayerDialogue")
local playCharacterDialogueRemote = remotes:WaitForChild("PlayCharacterDialogue")
local choiceSelectedRemote = remotes:WaitForChild("PlayerDialogueChoiceSelected")

local TYPE_SPEED = config.typeSpeed or 0.03
local HOLD_DURATION = config.holdDuration or 1.05
local BETWEEN_LINES_DELAY = config.betweenLinesDelay or 0.1
local CHOICE_TIMEOUT = config.choiceTimeout or 18

local uiConfig = config.ui or {}
local subtitlePosition = uiConfig.subtitlePosition or UDim2.fromScale(0.5, 0.88)
local choicePosition = uiConfig.choicePosition or UDim2.fromScale(0.5, 0.95)
local panelCornerRadius = uiStyle.panelCornerRadius or 16

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerDialogueGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui:SetAttribute("DialogueActive", false)
screenGui.Parent = playerGui

local subtitleRoot = Instance.new("Frame")
subtitleRoot.Name = "SubtitleRoot"
subtitleRoot.AnchorPoint = Vector2.new(0.5, 1)
subtitleRoot.Position = subtitlePosition
subtitleRoot.Size = UDim2.fromOffset(660, 112)
subtitleRoot.BackgroundTransparency = 1
subtitleRoot.Visible = false
subtitleRoot.Parent = screenGui

local subtitleShadow = Instance.new("Frame")
subtitleShadow.Name = "SubtitleShadow"
subtitleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
subtitleShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
subtitleShadow.Size = UDim2.new(1, -8, 1, -8)
subtitleShadow.BackgroundColor3 = uiStyle.subtitleShadowColor or Color3.fromRGB(6, 6, 8)
subtitleShadow.BackgroundTransparency = uiStyle.subtitleShadowTransparency or 0.7
subtitleShadow.BorderSizePixel = 0
subtitleShadow.ZIndex = 0
subtitleShadow.Parent = subtitleRoot

local subtitleShadowCorner = Instance.new("UICorner")
subtitleShadowCorner.CornerRadius = UDim.new(0, panelCornerRadius + 2)
subtitleShadowCorner.Parent = subtitleShadow

local subtitlePanel = Instance.new("Frame")
subtitlePanel.Name = "SubtitlePanel"
subtitlePanel.AnchorPoint = Vector2.new(0.5, 0.5)
subtitlePanel.Position = UDim2.fromScale(0.5, 0.5)
subtitlePanel.Size = UDim2.new(1, 0, 1, 0)
subtitlePanel.BackgroundColor3 = uiStyle.subtitlePanelColor or Color3.fromRGB(20, 18, 25)
subtitlePanel.BackgroundTransparency = uiStyle.subtitlePanelTransparency or 0.16
subtitlePanel.BorderSizePixel = 0
subtitlePanel.ZIndex = 1
subtitlePanel.Parent = subtitleRoot

local subtitlePanelCorner = Instance.new("UICorner")
subtitlePanelCorner.CornerRadius = UDim.new(0, panelCornerRadius)
subtitlePanelCorner.Parent = subtitlePanel

local subtitlePanelStroke = Instance.new("UIStroke")
subtitlePanelStroke.Color = uiStyle.subtitleBorderColor or Color3.fromRGB(103, 94, 120)
subtitlePanelStroke.Transparency = uiStyle.subtitleBorderTransparency or 0.56
subtitlePanelStroke.Thickness = 1
subtitlePanelStroke.Parent = subtitlePanel

local modeLabel = Instance.new("TextLabel")
modeLabel.Name = "ModeLabel"
modeLabel.AnchorPoint = Vector2.new(0, 0)
modeLabel.Position = UDim2.new(0, 22, 0, 12)
modeLabel.Size = UDim2.fromOffset(300, 18)
modeLabel.BackgroundTransparency = 1
modeLabel.Font = Enum.Font.GothamMedium
modeLabel.Text = ""
modeLabel.TextScaled = true
modeLabel.TextTransparency = 1
modeLabel.TextStrokeTransparency = 1
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.ZIndex = 2
modeLabel.Parent = subtitleRoot

local modeSize = Instance.new("UITextSizeConstraint")
modeSize.MaxTextSize = 14
modeSize.MinTextSize = 10
modeSize.Parent = modeLabel

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
subtitle.Position = UDim2.new(0.5, 0, 0.58, 8)
subtitle.Size = UDim2.fromOffset(610, 58)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.GothamMedium
subtitle.Text = ""
subtitle.TextScaled = true
subtitle.TextWrapped = true
subtitle.TextTransparency = 1
subtitle.TextStrokeTransparency = 1
subtitle.TextXAlignment = Enum.TextXAlignment.Center
subtitle.TextYAlignment = Enum.TextYAlignment.Center
subtitle.ZIndex = 2
subtitle.Parent = subtitleRoot

local subtitleSize = Instance.new("UITextSizeConstraint")
subtitleSize.MaxTextSize = 26
subtitleSize.MinTextSize = 14
subtitleSize.Parent = subtitle

local choiceRoot = Instance.new("Frame")
choiceRoot.Name = "ChoiceRoot"
choiceRoot.AnchorPoint = Vector2.new(0.5, 1)
choiceRoot.Position = choicePosition
choiceRoot.Size = UDim2.fromOffset(620, 250)
choiceRoot.BackgroundTransparency = 1
choiceRoot.Visible = false
choiceRoot.Parent = screenGui

local choiceShadow = Instance.new("Frame")
choiceShadow.Name = "ChoiceShadow"
choiceShadow.AnchorPoint = Vector2.new(0.5, 0.5)
choiceShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
choiceShadow.Size = UDim2.new(1, -8, 1, -8)
choiceShadow.BackgroundColor3 = uiStyle.choiceShadowColor or Color3.fromRGB(6, 6, 8)
choiceShadow.BackgroundTransparency = uiStyle.choiceShadowTransparency or 0.72
choiceShadow.BorderSizePixel = 0
choiceShadow.ZIndex = 0
choiceShadow.Parent = choiceRoot

local choiceShadowCorner = Instance.new("UICorner")
choiceShadowCorner.CornerRadius = UDim.new(0, panelCornerRadius + 2)
choiceShadowCorner.Parent = choiceShadow

local choicePanel = Instance.new("Frame")
choicePanel.Name = "ChoicePanel"
choicePanel.AnchorPoint = Vector2.new(0.5, 0.5)
choicePanel.Position = UDim2.fromScale(0.5, 0.5)
choicePanel.Size = UDim2.new(1, 0, 1, 0)
choicePanel.BackgroundColor3 = uiStyle.choicePanelColor or Color3.fromRGB(18, 17, 23)
choicePanel.BackgroundTransparency = uiStyle.choicePanelTransparency or 0.14
choicePanel.BorderSizePixel = 0
choicePanel.ZIndex = 1
choicePanel.Parent = choiceRoot

local choicePanelCorner = Instance.new("UICorner")
choicePanelCorner.CornerRadius = UDim.new(0, panelCornerRadius)
choicePanelCorner.Parent = choicePanel

local choicePanelStroke = Instance.new("UIStroke")
choicePanelStroke.Color = uiStyle.choiceBorderColor or Color3.fromRGB(101, 92, 118)
choicePanelStroke.Transparency = uiStyle.choiceBorderTransparency or 0.54
choicePanelStroke.Thickness = 1
choicePanelStroke.Parent = choicePanel

local choicePrompt = Instance.new("TextLabel")
choicePrompt.Name = "ChoicePrompt"
choicePrompt.AnchorPoint = Vector2.new(0.5, 0)
choicePrompt.Position = UDim2.new(0.5, 0, 0, 18)
choicePrompt.Size = UDim2.fromOffset(560, 42)
choicePrompt.BackgroundTransparency = 1
choicePrompt.Font = Enum.Font.GothamMedium
choicePrompt.Text = ""
choicePrompt.TextScaled = true
choicePrompt.TextWrapped = true
choicePrompt.TextTransparency = 1
choicePrompt.TextStrokeTransparency = 1
choicePrompt.ZIndex = 2
choicePrompt.Parent = choicePanel

local promptSize = Instance.new("UITextSizeConstraint")
promptSize.MaxTextSize = 24
promptSize.MinTextSize = 15
promptSize.Parent = choicePrompt

local choicesContainer = Instance.new("Frame")
choicesContainer.Name = "ChoicesContainer"
choicesContainer.AnchorPoint = Vector2.new(0.5, 0)
choicesContainer.Position = UDim2.new(0.5, 0, 0, 72)
choicesContainer.Size = UDim2.new(1, -32, 1, -88)
choicesContainer.BackgroundTransparency = 1
choicesContainer.ZIndex = 2
choicesContainer.Parent = choiceRoot

local choiceLayout = Instance.new("UIListLayout")
choiceLayout.Padding = UDim.new(0, 10)
choiceLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
choiceLayout.Parent = choicesContainer

local activeRequestId = 0
local activeButtons = {}
local interactionEndTicket = 0

local function setDialogueActive(isActive)
	screenGui:SetAttribute("DialogueActive", isActive == true)
end

local function cancelPendingInteractionEnd()
	interactionEndTicket += 1
end

local function scheduleInteractionEnd(requestId)
	cancelPendingInteractionEnd()
	local ticket = interactionEndTicket
	task.delay(0.6, function()
		if ticket ~= interactionEndTicket then
			return
		end
		if requestId ~= activeRequestId then
			return
		end
		if subtitleRoot.Visible or choiceRoot.Visible then
			return
		end
		setDialogueActive(false)
	end)
end

local function beginInteraction()
	cancelPendingInteractionEnd()
	setDialogueActive(true)
end

local function getStyle(mode)
	return styles[mode] or styles.spoken or {
		label = "",
		textColor = Color3.fromRGB(255, 255, 255),
		strokeColor = Color3.fromRGB(30, 30, 30),
		strokeTransparency = 0.5,
	}
end

local function getChoiceStyle()
	return styles.choice or {
		textColor = Color3.fromRGB(227, 224, 233),
		strokeColor = Color3.fromRGB(40, 36, 48),
		backgroundColor = Color3.fromRGB(35, 31, 41),
		backgroundTransparency = 0.18,
		borderColor = Color3.fromRGB(120, 110, 143),
		borderTransparency = 0.6,
		hoverBackgroundColor = Color3.fromRGB(42, 37, 49),
		hoverBackgroundTransparency = 0.12,
		hoverBorderColor = Color3.fromRGB(140, 130, 166),
		hoverBorderTransparency = 0.48,
		pressedBackgroundColor = Color3.fromRGB(29, 26, 34),
		pressedBackgroundTransparency = 0.08,
		pressedBorderColor = Color3.fromRGB(158, 148, 184),
		pressedBorderTransparency = 0.38,
	}
end

local function clearChoices()
	for _, button in ipairs(activeButtons) do
		if button.Parent then
			button:Destroy()
		end
	end
	table.clear(activeButtons)
	choicePrompt.Text = ""
	choiceRoot.Visible = false
end

local function clearSubtitle()
	subtitle.Text = ""
	subtitle.MaxVisibleGraphemes = -1
	modeLabel.Text = ""
	subtitleRoot.Visible = false
	subtitle.TextTransparency = 1
	subtitle.TextStrokeTransparency = 1
	modeLabel.TextTransparency = 1
	modeLabel.TextStrokeTransparency = 1
end

local function clearVisuals()
	clearChoices()
	clearSubtitle()
end

local function clearAll()
	activeRequestId += 1
	cancelPendingInteractionEnd()
	clearVisuals()
	setDialogueActive(false)
end

local function prepareForPayload()
	beginInteraction()
	activeRequestId += 1
	clearVisuals()
	return activeRequestId
end

local function getGraphemeCount(text)
	local ok, length = pcall(function()
		return utf8.len(text)
	end)
	if ok and length then
		return length
	end
	return #text
end

local function applyStyle(mode, labelOverride, styleOverride)
	local style = styleOverride or getStyle(mode)
	subtitle.TextColor3 = style.textColor
	subtitle.TextStrokeColor3 = style.strokeColor
	subtitle.TextStrokeTransparency = style.strokeTransparency or 0.5
	modeLabel.TextColor3 = style.textColor:Lerp(Color3.fromRGB(160, 156, 172), 0.35)
	modeLabel.TextStrokeColor3 = style.strokeColor
	modeLabel.TextStrokeTransparency = math.min((style.strokeTransparency or 0.5) + 0.12, 1)
	modeLabel.Text = labelOverride or style.label or ""
	return style
end

local function typeLine(line, requestId, typeSpeed, holdDuration)
	if requestId ~= activeRequestId then
		return false
	end

	if type(line) ~= "string" then
		line = ""
	end

	subtitle.Text = line
	subtitle.MaxVisibleGraphemes = 0

	local total = getGraphemeCount(line)
	for index = 1, total do
		if requestId ~= activeRequestId then
			return false
		end

		subtitle.MaxVisibleGraphemes = index
		task.wait(typeSpeed or TYPE_SPEED)
	end

	subtitle.MaxVisibleGraphemes = -1
	task.wait(holdDuration or HOLD_DURATION)
	return requestId == activeRequestId
end

local function playLines(lines, requestId, presentation)
	presentation = presentation or {}
	local mode = presentation.mode or "spoken"
	local style = applyStyle(mode, presentation.label, presentation.style)
	subtitleRoot.Visible = true
	subtitle.TextTransparency = 0
	subtitle.TextStrokeTransparency = style.strokeTransparency or 0.5
	modeLabel.TextTransparency = 0.08
	modeLabel.TextStrokeTransparency = math.min((style.strokeTransparency or 0.5) + 0.12, 1)

	for _, line in ipairs(lines or {}) do
		local completed = typeLine(line, requestId, presentation.typeSpeed, presentation.holdDuration)
		if not completed then
			return false
		end
	end

	clearSubtitle()
	task.wait(presentation.betweenLinesDelay or BETWEEN_LINES_DELAY)
	return true
end

local function applyChoiceVisualState(button, stroke, choiceStyle, state)
	if state == "hover" then
		button.BackgroundColor3 = choiceStyle.hoverBackgroundColor or choiceStyle.backgroundColor
		button.BackgroundTransparency = choiceStyle.hoverBackgroundTransparency or choiceStyle.backgroundTransparency
		stroke.Color = choiceStyle.hoverBorderColor or choiceStyle.borderColor or choiceStyle.textColor
		stroke.Transparency = choiceStyle.hoverBorderTransparency or choiceStyle.borderTransparency or 0.5
	elseif state == "pressed" then
		button.BackgroundColor3 = choiceStyle.pressedBackgroundColor or choiceStyle.hoverBackgroundColor or choiceStyle.backgroundColor
		button.BackgroundTransparency = choiceStyle.pressedBackgroundTransparency or choiceStyle.hoverBackgroundTransparency or choiceStyle.backgroundTransparency
		stroke.Color = choiceStyle.pressedBorderColor or choiceStyle.hoverBorderColor or choiceStyle.borderColor or choiceStyle.textColor
		stroke.Transparency = choiceStyle.pressedBorderTransparency or choiceStyle.hoverBorderTransparency or choiceStyle.borderTransparency or 0.5
	else
		button.BackgroundColor3 = choiceStyle.backgroundColor
		button.BackgroundTransparency = choiceStyle.backgroundTransparency
		stroke.Color = choiceStyle.borderColor or choiceStyle.textColor
		stroke.Transparency = choiceStyle.borderTransparency or 0.6
	end
end

local function createChoiceButton(choiceStyle, choice, index)
	local button = Instance.new("TextButton")
	button.Name = choice.id or ("Choice" .. tostring(index))
	button.Size = UDim2.fromOffset(588, 48)
	button.BackgroundColor3 = choiceStyle.backgroundColor
	button.BackgroundTransparency = choiceStyle.backgroundTransparency
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamMedium
	button.Text = choice.text or ("Choice " .. tostring(index))
	button.TextScaled = true
	button.TextWrapped = true
	button.TextColor3 = choiceStyle.textColor
	button.TextStrokeColor3 = choiceStyle.strokeColor
	button.TextStrokeTransparency = 0.62
	button.ZIndex = 3
	button.Parent = choicesContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Parent = button
	applyChoiceVisualState(button, stroke, choiceStyle, "idle")

	local sizeConstraint = Instance.new("UITextSizeConstraint")
	sizeConstraint.MaxTextSize = 22
	sizeConstraint.MinTextSize = 15
	sizeConstraint.Parent = button

	button.MouseEnter:Connect(function()
		applyChoiceVisualState(button, stroke, choiceStyle, "hover")
	end)

	button.MouseLeave:Connect(function()
		applyChoiceVisualState(button, stroke, choiceStyle, "idle")
	end)

	button.MouseButton1Down:Connect(function()
		applyChoiceVisualState(button, stroke, choiceStyle, "pressed")
	end)

	button.MouseButton1Up:Connect(function()
		applyChoiceVisualState(button, stroke, choiceStyle, "hover")
	end)

	return button
end

local function showChoices(payload, requestId)
	if requestId ~= activeRequestId then
		return nil
	end

	clearChoices()
	local choiceStyle = getChoiceStyle()
	choicePrompt.Text = payload.prompt or "Choose"
	choicePrompt.TextColor3 = uiStyle.choicePromptColor or choiceStyle.textColor
	choicePrompt.TextStrokeColor3 = uiStyle.choicePromptStrokeColor or choiceStyle.strokeColor
	choicePrompt.TextTransparency = 0
	choicePrompt.TextStrokeTransparency = uiStyle.choicePromptStrokeTransparency or 0.64
	choiceRoot.Visible = true

	local selectedChoice = nil
	local resolved = false

	for index, choice in ipairs(payload.choices or {}) do
		local button = createChoiceButton(choiceStyle, choice, index)
		table.insert(activeButtons, button)
		button.MouseButton1Click:Connect(function()
			if resolved or requestId ~= activeRequestId then
				return
			end
			resolved = true
			selectedChoice = choice
		end)
	end

	local deadline = os.clock() + (payload.timeout or CHOICE_TIMEOUT)
	while requestId == activeRequestId and not resolved and os.clock() < deadline do
		task.wait(0.05)
	end

	if not selectedChoice and #payload.choices > 0 then
		selectedChoice = payload.choices[1]
	end

	if selectedChoice then
		choiceSelectedRemote:FireServer(
			payload.id or payload.templateId or "choice",
			selectedChoice.id
		)
	end

	clearChoices()
	return selectedChoice
end

local function playPayload(payload)
	local requestId = prepareForPayload()

	if payload.mode == "choice" then
		showChoices(payload, requestId)
		if requestId == activeRequestId then
			scheduleInteractionEnd(requestId)
		end
		return
	end

	local lines = payload.lines or {}
	if #lines == 0 then
		clearSubtitle()
		scheduleInteractionEnd(requestId)
		return
	end

	playLines(lines, requestId, {
		mode = payload.mode or "spoken",
	})
	if requestId == activeRequestId then
		scheduleInteractionEnd(requestId)
	end
end

local function playCharacterSubtitlePayload(payload)
	local characterConfig = characterConfigs[payload.characterId]
	if type(characterConfig) ~= "table" or characterConfig.dialogueRenderMode ~= "subtitle" then
		return
	end

	local requestId = prepareForPayload()
	local lines = payload.lines or {}
	if #lines == 0 then
		clearSubtitle()
		scheduleInteractionEnd(requestId)
		return
	end

	playLines(lines, requestId, {
		mode = "spoken",
		label = payload.speaker or characterConfig.displayName or payload.characterId,
		style = getStyle("spoken"),
		typeSpeed = characterConfig.typeSpeed or TYPE_SPEED,
		holdDuration = characterConfig.holdDuration or HOLD_DURATION,
		betweenLinesDelay = characterConfig.betweenLinesDelay or BETWEEN_LINES_DELAY,
	})
	if requestId == activeRequestId then
		scheduleInteractionEnd(requestId)
	end
end

playPlayerDialogueRemote.OnClientEvent:Connect(function(payload)
	if type(payload) == "string" and config.templates then
		payload = config.templates[payload]
	elseif type(payload) == "table" and payload.templateId and config.templates then
		payload = config.templates[payload.templateId] or payload
	end

	if type(payload) ~= "table" then
		return
	end

	playPayload(payload)
end)

playCharacterDialogueRemote.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" or type(payload.characterId) ~= "string" then
		return
	end

	playCharacterSubtitlePayload(payload)
end)