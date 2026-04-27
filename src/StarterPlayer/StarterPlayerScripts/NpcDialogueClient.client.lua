local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local dialogueData = require(ReplicatedStorage:WaitForChild("DialogueData"))
local globalConfig = dialogueData.Global or {}
local characterConfigs = dialogueData.Characters or {}

local remotes = ReplicatedStorage:WaitForChild("DialogueRemotes")
local playCharacterDialogueRemote = remotes:WaitForChild("PlayCharacterDialogue")
local requestCharacterConversationRemote = remotes:WaitForChild("RequestCharacterConversation")

local interactKey = globalConfig.interactKey or Enum.KeyCode.E
local checkInterval = globalConfig.checkInterval or 0.1

local worldFolder = workspace:FindFirstChild("DialogueWorldText")
if not worldFolder then
	worldFolder = Instance.new("Folder")
	worldFolder.Name = "DialogueWorldText"
	worldFolder.Parent = workspace
end

local statesByCharacter = {}
local queueByCharacter = {}
local workerByCharacter = {}
local promptsByCharacter = {}
local promptCharacterMap = {}
local lastPromptFireAt = {}
local dialogueGui = nil
local dialogueGuiConnection = nil

local elapsed = 0
local promptDebounce = false
local rng = Random.new()

local function removeFromArray(array, value)
	for index = #array, 1, -1 do
		if array[index] == value then
			table.remove(array, index)
		end
	end
end

local function isDialoguePoint(instance)
	return instance and (instance:IsA("BasePart") or instance:IsA("Attachment"))
end

local function findByPath(root, path)
	if not root or type(path) ~= "string" or path == "" then
		return nil
	end

	local current = root
	for segment in string.gmatch(path, "[^%.]+") do
		if not current then
			return nil
		end
		current = current:FindFirstChild(segment)
	end
	return current
end

local function getCharacterModel(characterId, config)
	if type(config) ~= "table" then
		return nil
	end
	return workspace:FindFirstChild(config.modelName or characterId)
end

local function getCharacterPoint(characterId, config)
	if type(config.dialoguePointWorkspacePath) == "string" then
		local workspacePoint = findByPath(workspace, config.dialoguePointWorkspacePath)
		if isDialoguePoint(workspacePoint) then
			return workspacePoint, true
		end
	end

	local model = getCharacterModel(characterId, config)
	if not model then
		return nil, false
	end

	if type(config.dialoguePointPath) == "string" then
		local byPath = findByPath(model, config.dialoguePointPath)
		if isDialoguePoint(byPath) then
			return byPath, true
		end
	end

	if config.useNamedDialoguePoint == true then
		local pointName = config.dialoguePointName or globalConfig.dialoguePointName or "DialoguePoint"
		local namedPoint = model:FindFirstChild(pointName, true)
		if isDialoguePoint(namedPoint) then
			return namedPoint, true
		end
	end

	local fallbackPoint = model:FindFirstChild("Head")
		or model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChildWhichIsA("BasePart")
	return fallbackPoint, false
end

local function getPointCFrame(point)
	if not point then
		return nil
	end
	if point:IsA("Attachment") then
		return point.WorldCFrame
	end
	if point:IsA("BasePart") then
		return point.CFrame
	end
	return nil
end

local function getModelBaseCFrame(characterId, config)
	local model = getCharacterModel(characterId, config)
	if not model then
		return nil
	end

	local root = model:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root.CFrame
	end

	if model.PrimaryPart then
		return model.PrimaryPart.CFrame
	end

	local anyPart = model:FindFirstChildWhichIsA("BasePart")
	if anyPart then
		return anyPart.CFrame
	end

	return nil
end

local function splitChars(text)
	local characters = {}
	if type(text) ~= "string" or text == "" then
		return characters
	end

	local ok = pcall(function()
		for _, codepoint in utf8.codes(text) do
			table.insert(characters, utf8.char(codepoint))
		end
	end)

	if not ok or #characters == 0 then
		for index = 1, #text do
			characters[index] = text:sub(index, index)
		end
	end

	return characters
end

local function getGraphemeCount(text)
	local ok, length = pcall(function()
		return utf8.len(text)
	end)
	if ok and length then
		return length
	end
	return #splitChars(text)
end

local function countWords(text)
	local count = 0
	for _ in string.gmatch(text or "", "%S+") do
		count += 1
	end
	return count
end

local function createSurface(part, face, canvasSize)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "Dialogue" .. face.Name
	surface.Face = face
	surface.AlwaysOnTop = true
	surface.LightInfluence = 0
	surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surface.CanvasSize = canvasSize
	surface.Parent = part

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.ClipsDescendants = false
	root.Parent = surface

	return {
		surface = surface,
		root = root,
	}
end

local function createState(characterId, config)
	local bubbleSize = config.bubbleSize
	if typeof(bubbleSize) ~= "Vector2" then
		bubbleSize = Vector2.new(960, 280)
	end

	local typeSoundConfig = type(config.dialogueSound) == "table" and config.dialogueSound or nil

	local state = {
		characterId = characterId,
		config = config,
		maxVisibleLines = config.maxVisibleLines or globalConfig.maxVisibleNpcLines or 2,
		lineHeight = config.lineHeight or 72,
		lineGap = config.lineGap or 8,
		typeSpeed = config.typeSpeed or 0.03,
		holdDuration = config.holdDuration or 1.15,
		betweenLinesDelay = config.betweenLinesDelay or 0.1,
		studsOffset = typeof(config.studsOffset) == "Vector3" and config.studsOffset or Vector3.new(0, 0, 0),
		frontDistance = config.frontDistance or globalConfig.dialogueFrontDistance or 2.6,
		frontHeight = config.frontHeight or globalConfig.dialogueFrontHeight or 0.85,
		autoOffset = typeof(config.autoOffset) == "Vector3" and config.autoOffset
			or (typeof(globalConfig.dialogueAutoOffset) == "Vector3" and globalConfig.dialogueAutoOffset or Vector3.new(0, 0, 0)),
		decayBase = config.decayBase or globalConfig.npcDecayBase or 1.8,
		decayPerWord = config.decayPerWord or globalConfig.npcDecayPerWord or 0.22,
		decayPerCharacter = config.decayPerCharacter or globalConfig.npcDecayPerCharacter or 0.04,
		decayMin = config.decayMin or globalConfig.npcDecayMin or 2.2,
		decayMax = config.decayMax or globalConfig.npcDecayMax or 8,
		showSpeaker = config.showSpeaker == true,
		style = config.style or {},
		typeSoundConfig = typeSoundConfig,
		typeSound = nil,
		baseTypeSoundSpeed = 1,
		typeSoundMinInterval = 0.05,
		typeSoundPitchJitter = 0,
		typeSoundOnlyLetters = true,
		typeSoundLetterVolume = 0.35,
		lastTypeSoundAt = 0,
		slotEntries = {},
		activeEntries = {},
		nextSlot = 1,
	}

	state.anchorPart = Instance.new("Part")
	state.anchorPart.Name = characterId .. "DialogueAnchor"
	state.anchorPart.Anchored = true
	state.anchorPart.CanCollide = false
	state.anchorPart.CanTouch = false
	state.anchorPart.CanQuery = false
	state.anchorPart.CastShadow = false
	state.anchorPart.Transparency = 1
	state.anchorPart.Size = Vector3.new(10, 3.5, 0.2)
	state.anchorPart.Locked = true
	state.anchorPart.Parent = worldFolder

	if state.typeSoundConfig and type(state.typeSoundConfig.soundId) == "string" and state.typeSoundConfig.soundId ~= "" then
		local sound = Instance.new("Sound")
		sound.Name = "DialogueTypeSound"
		sound.SoundId = state.typeSoundConfig.soundId
		local letterVolume = state.typeSoundConfig.letterVolume or state.typeSoundConfig.volume or 0.35
		sound.Volume = state.typeSoundConfig.startVolume or letterVolume
		sound.PlaybackSpeed = state.typeSoundConfig.playbackSpeed or 1
		sound.RollOffMode = Enum.RollOffMode.Linear
		sound.RollOffMinDistance = state.typeSoundConfig.minDistance or 4
		sound.RollOffMaxDistance = state.typeSoundConfig.maxDistance or 36
		sound.Parent = state.anchorPart
		state.typeSound = sound
		state.baseTypeSoundSpeed = sound.PlaybackSpeed
		state.typeSoundLetterVolume = letterVolume
		state.typeSoundMinInterval = state.typeSoundConfig.minInterval or math.max(state.typeSpeed * 0.8, 0.03)
		state.typeSoundPitchJitter = state.typeSoundConfig.pitchJitter or 0
		state.typeSoundOnlyLetters = state.typeSoundConfig.onlyLetters ~= false
	end

	state.surfaces = {
		createSurface(state.anchorPart, Enum.NormalId.Front, bubbleSize),
		createSurface(state.anchorPart, Enum.NormalId.Back, bubbleSize),
	}
	return state
end

local function getOrCreateState(characterId)
	local state = statesByCharacter[characterId]
	if state then
		return state
	end

	local config = characterConfigs[characterId]
	if not config then
		return nil
	end

	state = createState(characterId, config)
	statesByCharacter[characterId] = state
	return state
end

local function computeLifetime(state, text)
	local words = countWords(text)
	local characters = getGraphemeCount(text)
	local value = state.decayBase + (words * state.decayPerWord) + (characters * state.decayPerCharacter)
	return math.clamp(value, state.decayMin, state.decayMax)
end

local function getSlotYOffset(state, slotIndex)
	return (slotIndex - 1) * (state.lineHeight + state.lineGap)
end

local function getDisplayText(state, speaker, line)
	if state.showSpeaker and type(speaker) == "string" and speaker ~= "" then
		return string.format("%s: %s", speaker, line)
	end
	return line
end

local function createLineEntry(state, speaker, line, slotIndex)
	local style = state.style
	local displayText = getDisplayText(state, speaker, line)
	local entry = {
		slotIndex = slotIndex,
		textValue = displayText,
		frames = {},
		textLabels = {},
		shadowLabels = {},
		expiresAt = 0,
		breaking = false,
	}

	local targetPosition = UDim2.new(0.5, 0, 1, -getSlotYOffset(state, slotIndex))

	for _, surfaceData in ipairs(state.surfaces) do
		local frame = Instance.new("Frame")
		frame.Name = "Line"
		frame.AnchorPoint = Vector2.new(0.5, 1)
		frame.Position = targetPosition
		frame.Size = UDim2.new(0.98, 0, 0, state.lineHeight)
		frame.BackgroundColor3 = style.lineBackgroundColor or Color3.fromRGB(0, 0, 0)
		frame.BackgroundTransparency = style.lineBackgroundTransparency ~= nil and style.lineBackgroundTransparency or 1
		frame.BorderSizePixel = 0
		frame.Parent = surfaceData.root

		if frame.BackgroundTransparency < 1 then
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, style.cornerRadius or 10)
			corner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = style.lineBorderColor or Color3.fromRGB(94, 84, 112)
			stroke.Transparency = style.lineBorderTransparency ~= nil and style.lineBorderTransparency or 0.68
			stroke.Thickness = style.lineBorderThickness or 1
			stroke.Parent = frame
		end

		local shadowOffset = style.shadowOffset or Vector2.new(0, 2)
		local shadow = Instance.new("TextLabel")
		shadow.Name = "Shadow"
		shadow.AnchorPoint = Vector2.new(0.5, 0.5)
		shadow.Position = UDim2.new(0.5, shadowOffset.X, 0.5, shadowOffset.Y)
		shadow.Size = UDim2.new(1, -18, 1, 0)
		shadow.BackgroundTransparency = 1
		shadow.Font = style.shadowFont or style.font or Enum.Font.GothamMedium
		shadow.Text = displayText
		shadow.TextScaled = true
		shadow.TextWrapped = true
		shadow.TextXAlignment = Enum.TextXAlignment.Center
		shadow.TextYAlignment = Enum.TextYAlignment.Center
		shadow.TextColor3 = style.shadowColor or Color3.fromRGB(28, 10, 42)
		shadow.TextTransparency = style.shadowTransparency ~= nil and style.shadowTransparency or 0.48
		shadow.TextStrokeTransparency = 1
		shadow.Parent = frame

		local shadowSize = Instance.new("UITextSizeConstraint")
		shadowSize.MaxTextSize = style.maxTextSize or 50
		shadowSize.MinTextSize = style.minTextSize or 20
		shadowSize.Parent = shadow

		local text = Instance.new("TextLabel")
		text.Name = "Text"
		text.AnchorPoint = Vector2.new(0.5, 0.5)
		text.Position = UDim2.fromScale(0.5, 0.5)
		text.Size = UDim2.new(1, -18, 1, 0)
		text.BackgroundTransparency = 1
		text.Font = style.font or Enum.Font.GothamMedium
		text.Text = displayText
		text.TextScaled = true
		text.TextWrapped = true
		text.TextXAlignment = Enum.TextXAlignment.Center
		text.TextYAlignment = Enum.TextYAlignment.Center
		text.TextColor3 = style.textColor or Color3.fromRGB(244, 214, 255)
		text.TextStrokeColor3 = style.strokeColor or Color3.fromRGB(82, 30, 122)
		text.TextTransparency = style.textTransparency or 0
		text.TextStrokeTransparency = style.strokeTransparency or 0.08
		text.Parent = frame

		local textSize = Instance.new("UITextSizeConstraint")
		textSize.MaxTextSize = style.maxTextSize or 50
		textSize.MinTextSize = style.minTextSize or 20
		textSize.Parent = text

		table.insert(entry.frames, frame)
		table.insert(entry.textLabels, text)
		table.insert(entry.shadowLabels, shadow)
	end

	return entry
end

local function setVisibleGraphemes(entry, value)
	for _, label in ipairs(entry.textLabels) do
		label.MaxVisibleGraphemes = value
	end
	for _, label in ipairs(entry.shadowLabels) do
		label.MaxVisibleGraphemes = value
	end
end

local function tryPlayTypeSound(state, character)
	local sound = state.typeSound
	if not sound then
		return
	end

	if state.typeSoundOnlyLetters then
		if not string.match(character, "[%w]") then
			return
		end
	elseif string.match(character, "^%s$") then
		return
	end

	local now = os.clock()
	if now - (state.lastTypeSoundAt or 0) < (state.typeSoundMinInterval or 0) then
		return
	end
	state.lastTypeSoundAt = now

	local jitter = state.typeSoundPitchJitter or 0
	if jitter > 0 then
		sound.PlaybackSpeed = state.baseTypeSoundSpeed + rng:NextNumber(-jitter, jitter)
	else
		sound.PlaybackSpeed = state.baseTypeSoundSpeed
	end
	sound.Volume = state.typeSoundLetterVolume or sound.Volume

	sound:Stop()
	sound:Play()
end

local function breakLine(state, entry)
	if not entry or entry.breaking then
		return
	end
	entry.breaking = true
	state.slotEntries[entry.slotIndex] = nil
	removeFromArray(state.activeEntries, entry)

	local graphemes = splitChars(entry.textValue)

	for frameIndex, frame in ipairs(entry.frames) do
		local textLabel = entry.textLabels[frameIndex]
		local shadowLabel = entry.shadowLabels[frameIndex]
		if textLabel then
			textLabel.Visible = false
		end
		if shadowLabel then
			shadowLabel.Visible = false
		end

		local fragmentRoot = Instance.new("Frame")
		fragmentRoot.Name = "BreakFragments"
		fragmentRoot.BackgroundTransparency = 1
		fragmentRoot.Size = UDim2.fromScale(1, 1)
		fragmentRoot.ClipsDescendants = false
		fragmentRoot.Parent = frame

		if #graphemes == 0 then
			frame:Destroy()
		else
			local textHeight = textLabel and textLabel.TextBounds.Y or 26
			local textSize = math.max(math.floor(textHeight * 0.9), 14)
			local textWidth = textLabel and textLabel.TextBounds.X or (textSize * #graphemes)
			textWidth = math.max(textWidth, textSize * 0.6)
			local cursorX = -textWidth * 0.5

			for _, character in ipairs(graphemes) do
				local glyphWidth = TextService:GetTextSize(character, textSize, Enum.Font.FredokaOne, Vector2.new(2048, 2048)).X
				if glyphWidth <= 0 then
					glyphWidth = textSize * 0.35
				end

				local centerX = cursorX + (glyphWidth * 0.5)
				cursorX += glyphWidth

				if not string.match(character, "^%s$") then
					local piece = Instance.new("TextLabel")
					piece.Name = "Piece"
					piece.AnchorPoint = Vector2.new(0.5, 0.5)
					piece.BackgroundTransparency = 1
					piece.Size = UDim2.fromOffset(math.max(14, math.ceil(glyphWidth) + 6), math.max(20, math.ceil(textHeight) + 6))
					piece.Position = UDim2.new(0.5, math.floor(centerX), 0.5, rng:NextInteger(-2, 2))
					piece.Font = textLabel and textLabel.Font or Enum.Font.FredokaOne
					piece.Text = character
					piece.TextScaled = true
					piece.TextColor3 = textLabel and textLabel.TextColor3 or Color3.fromRGB(255, 255, 255)
					piece.TextStrokeColor3 = textLabel and textLabel.TextStrokeColor3 or Color3.fromRGB(0, 0, 0)
					piece.TextStrokeTransparency = textLabel and textLabel.TextStrokeTransparency or 0.08
					piece.Parent = fragmentRoot

					local hop = piece.Position + UDim2.fromOffset(rng:NextInteger(-3, 3), -rng:NextInteger(24, 36))
					local fall = hop + UDim2.fromOffset(rng:NextInteger(-6, 6), rng:NextInteger(34, 52))
					local rotA = rng:NextInteger(-18, 18)
					local rotB = rotA + rng:NextInteger(-18, 18)

					TweenService:Create(piece, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = hop,
						Rotation = rotA,
					}):Play()

					task.delay(0.1, function()
						if not piece.Parent then
							return
						end
						TweenService:Create(piece, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Position = fall,
							Rotation = rotB,
							TextTransparency = 1,
							TextStrokeTransparency = 1,
						}):Play()
					end)
				end
			end

			task.delay(0.42, function()
				if frame.Parent then
					frame:Destroy()
				end
			end)
		end
	end
end

local function typeLine(state, entry)
	entry.expiresAt = math.huge
	setVisibleGraphemes(entry, 0)

	local characters = splitChars(entry.textValue)
	for index, character in ipairs(characters) do
		setVisibleGraphemes(entry, index)
		tryPlayTypeSound(state, character)

		local extra = 0
		if character == "," or character == ";" or character == ":" then
			extra = math.clamp(state.typeSpeed * 2.4, 0.02, 0.1)
		elseif character == "." or character == "!" or character == "?" then
			extra = math.clamp(state.typeSpeed * 4.2, 0.04, 0.2)
		end

		task.wait(state.typeSpeed + extra)
	end

	setVisibleGraphemes(entry, -1)
	task.wait(state.holdDuration)
	entry.expiresAt = os.clock() + computeLifetime(state, entry.textValue)
end

local function processLine(state, speaker, line)
	if type(line) ~= "string" or line == "" then
		return
	end

	local slotIndex = state.nextSlot
	state.nextSlot += 1
	if state.nextSlot > state.maxVisibleLines then
		state.nextSlot = 1
	end

	local existing = state.slotEntries[slotIndex]
	if existing then
		breakLine(state, existing)
	end

	local entry = createLineEntry(state, speaker, line, slotIndex)
	state.slotEntries[slotIndex] = entry
	table.insert(state.activeEntries, entry)

	typeLine(state, entry)
	task.wait(state.betweenLinesDelay)
end

local function updateAnchor(state)
	local point, isManualPoint = getCharacterPoint(state.characterId, state.config)
	local pointCFrame = getPointCFrame(point)
	if not point or not pointCFrame then
		state.anchorPart.Parent = nil
		return false
	end

	if state.anchorPart.Parent ~= worldFolder then
		state.anchorPart.Parent = worldFolder
	end

	if isManualPoint then
		state.anchorPart.CFrame = pointCFrame * CFrame.new(state.studsOffset)
		return true
	end

	local baseCFrame = getModelBaseCFrame(state.characterId, state.config) or pointCFrame
	local targetPosition = baseCFrame.Position
		+ (baseCFrame.LookVector * state.frontDistance)
		+ Vector3.new(0, state.frontHeight, 0)
		+ state.autoOffset

	local look = baseCFrame.LookVector
	if look.Magnitude < 0.001 then
		look = Vector3.new(0, 0, -1)
	end

	state.anchorPart.CFrame = CFrame.lookAt(targetPosition, targetPosition + look, Vector3.new(0, 1, 0))
	return true
end

local function runCharacterQueue(characterId)
	local state = getOrCreateState(characterId)
	if not state then
		workerByCharacter[characterId] = nil
		return
	end

	local queue = queueByCharacter[characterId]
	while queue and #queue > 0 do
		local payload = table.remove(queue, 1)
		local speaker = payload.speaker or state.config.displayName or characterId
		for _, line in ipairs(payload.lines or {}) do
			if updateAnchor(state) then
				processLine(state, speaker, line)
			else
				local estimate = (#line * state.typeSpeed) + state.holdDuration + state.betweenLinesDelay
				task.wait(math.max(estimate, 0.1))
			end
		end
	end

	workerByCharacter[characterId] = nil
end

local function enqueueCharacterPayload(payload)
	if type(payload) ~= "table" or type(payload.characterId) ~= "string" or type(payload.lines) ~= "table" then
		return
	end

	local characterConfig = characterConfigs[payload.characterId]
	if not characterConfig then
		return
	end
	if characterConfig.dialogueRenderMode == "subtitle" then
		return
	end

	queueByCharacter[payload.characterId] = queueByCharacter[payload.characterId] or {}
	table.insert(queueByCharacter[payload.characterId], payload)

	if workerByCharacter[payload.characterId] then
		return
	end

	workerByCharacter[payload.characterId] = true
	task.spawn(function()
		runCharacterQueue(payload.characterId)
	end)
end

local function requestConversation(characterId)
	if type(characterId) ~= "string" then
		return
	end
	if promptDebounce then
		return
	end

	local last = lastPromptFireAt[characterId] or 0
	if os.clock() - last < 0.35 then
		return
	end

	promptDebounce = true
	lastPromptFireAt[characterId] = os.clock()
	requestCharacterConversationRemote:FireServer(characterId)
	task.delay(0.25, function()
		promptDebounce = false
	end)
end

local function isDialogueInteractionActive()
	return dialogueGui ~= nil and dialogueGui:GetAttribute("DialogueActive") == true
end

local function applyPromptVisibility()
	local dialogueActive = isDialogueInteractionActive()
	for characterId, prompt in pairs(promptsByCharacter) do
		if prompt then
			local config = characterConfigs[characterId]
			local hasPoint = config and getCharacterPoint(characterId, config) ~= nil
			prompt.Enabled = hasPoint and not dialogueActive
		end
	end
end

local function bindDialogueGui(gui)
	if dialogueGuiConnection then
		dialogueGuiConnection:Disconnect()
		dialogueGuiConnection = nil
	end

	dialogueGui = gui
	if dialogueGui then
		dialogueGuiConnection = dialogueGui:GetAttributeChangedSignal("DialogueActive"):Connect(function()
			applyPromptVisibility()
		end)
	end

	applyPromptVisibility()
end

local function ensurePrompt(characterId, config)
	local point = getCharacterPoint(characterId, config)
	local prompt = promptsByCharacter[characterId]

	if not point then
		if prompt then
			prompt.Enabled = false
		end
		return
	end

	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "DialoguePrompt"
		prompt.RequiresLineOfSight = false
		prompt.HoldDuration = 0
		prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
		prompt.KeyboardKeyCode = interactKey
		prompt.ActionText = config.promptText or "Interact"
		prompt.ObjectText = config.displayName or characterId
		promptsByCharacter[characterId] = prompt
		promptCharacterMap[prompt] = characterId
	end

	if prompt.Parent ~= point then
		prompt.Parent = point
	end

	prompt.ActionText = config.promptText or "Interact"
	prompt.ObjectText = config.displayName or characterId
	prompt.MaxActivationDistance = config.triggerDistance or globalConfig.fallbackTriggerDistance or 12
	prompt.Enabled = not isDialogueInteractionActive()
end

local function updatePrompts()
	for characterId, config in pairs(characterConfigs) do
		ensurePrompt(characterId, config)
	end
	applyPromptVisibility()
end

local function updateDecay(now)
	for characterId, state in pairs(statesByCharacter) do
		for _, entry in ipairs(state.activeEntries) do
			if not entry.breaking and entry.expiresAt > 0 and now >= entry.expiresAt then
				breakLine(state, entry)
			end
		end

		local anchored = updateAnchor(state)
		if not anchored and #state.activeEntries == 0 and not workerByCharacter[characterId] then
			state.anchorPart.Parent = nil
		end
	end
end

bindDialogueGui(playerGui:FindFirstChild("PlayerDialogueGui"))

playerGui.ChildAdded:Connect(function(child)
	if child.Name == "PlayerDialogueGui" then
		bindDialogueGui(child)
	end
end)

playerGui.ChildRemoved:Connect(function(child)
	if child == dialogueGui then
		bindDialogueGui(nil)
	end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, triggerPlayer)
	if triggerPlayer ~= player then
		return
	end

	local characterId = promptCharacterMap[prompt]
	if characterId then
		requestConversation(characterId)
	end
end)

playCharacterDialogueRemote.OnClientEvent:Connect(function(payload)
	enqueueCharacterPayload(payload)
end)

RunService.RenderStepped:Connect(function(deltaTime)
	elapsed += deltaTime
	if elapsed < checkInterval then
		return
	end
	elapsed = 0

	updatePrompts()
	updateDecay(os.clock())
end)
