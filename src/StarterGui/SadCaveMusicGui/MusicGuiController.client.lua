local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MUSIC_ENABLED_ATTR = "MusicEnabled"
local CURRENT_TRACK_ATTR = "CurrentTrackName"
local CURRENT_PLAYLIST_ATTR = "CurrentPlaylistName"
local PLAYING_ATTR = "IsPlaying"
local VOLUME_ATTR = "Volume"
local CONTROLLER_READY_ATTR = "ControllerReady"

local player = Players.LocalPlayer
local gui = script.Parent
local panel = gui:FindFirstChild("MusicPanel")
local mini = gui:FindFirstChild("MiniButton")
local controls = panel and panel:FindFirstChild("Controls")
local volumeFrame = controls and controls:FindFirstChild("Volume")
local playPause = controls and controls:FindFirstChild("PlayPause")
local nextBtn = controls and controls:FindFirstChild("Next")
local songLabel = panel and panel:FindFirstChild("SongLabel")
local hideBtn = panel and panel:FindFirstChild("HideButton")
local sliderBack = volumeFrame and volumeFrame:FindFirstChild("SliderBack")
local sliderFill = sliderBack and sliderBack:FindFirstChild("SliderFill")
local knob = sliderBack and sliderBack:FindFirstChild("Knob")

local function getRemote(name)
	return ReplicatedStorage:FindFirstChild(name)
end

local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getOrCreateBindableEvent(parent, name)
	local bindable = parent:FindFirstChild(name)
	if not bindable then
		bindable = Instance.new("BindableEvent")
		bindable.Name = name
		bindable.Parent = parent
	end
	return bindable
end

local ambientRoot = SoundService:FindFirstChild("SadCaveAmbient")
if not ambientRoot then
	ambientRoot = Instance.new("Folder")
	ambientRoot.Name = "SadCaveAmbient"
	ambientRoot.Parent = SoundService
end

local playlistFolder = ambientRoot:FindFirstChild("Playlist")
if not playlistFolder then
	playlistFolder = Instance.new("Folder")
	playlistFolder.Name = "Playlist"
	playlistFolder.Parent = ambientRoot
end

local commandFolder = getOrCreateFolder(ambientRoot, "Commands")
local togglePlaybackEvent = getOrCreateBindableEvent(commandFolder, "TogglePlayback")
local nextTrackEvent = getOrCreateBindableEvent(commandFolder, "NextTrack")
local setVolumeEvent = getOrCreateBindableEvent(commandFolder, "SetVolume")

local nowPlaying = ambientRoot:FindFirstChild("NowPlaying")
if not nowPlaying then
	nowPlaying = Instance.new("Sound")
	nowPlaying.Name = "NowPlaying"
	nowPlaying.Looped = false
	nowPlaying.Volume = 0.5
	nowPlaying.Parent = ambientRoot
end

if ambientRoot:GetAttribute(VOLUME_ATTR) == nil then
	ambientRoot:SetAttribute(VOLUME_ATTR, nowPlaying.Volume)
end
ambientRoot:SetAttribute(MUSIC_ENABLED_ATTR, true)
ambientRoot:SetAttribute(CONTROLLER_READY_ATTR, true)
ambientRoot:SetAttribute(CURRENT_PLAYLIST_ATTR, "Playlist")

local Camera = Workspace.CurrentCamera
local IS_EMBEDDED = gui:GetAttribute("SadCaveMusic_Embedded") == true
local DESKTOP_PANEL_POS = UDim2.new(1, -24, 1, -24)
local MOBILE_PANEL_POS = UDim2.new(1, -16, 1, -16)
local DESKTOP_MINI_POS = UDim2.new(1, -24, 1, -24)
local MOBILE_MINI_POS = UDim2.new(1, -16, 1, -16)

local function getOrCreateUIScale(parent)
	local existing = parent:FindFirstChildWhichIsA("UIScale")
	if existing then
		return existing
	end
	local scale = Instance.new("UIScale")
	scale.Name = "AutoUIScale"
	scale.Parent = parent
	return scale
end

local panelScale = panel and getOrCreateUIScale(panel) or nil
local miniScale = mini and getOrCreateUIScale(mini) or nil
local panelUsesManagedDefault = false
if IS_EMBEDDED and mini then
	mini.Visible = false
end

local function computeScale(viewportSize)
	local ref = Vector2.new(1920, 1080)
	local sx = viewportSize.X / ref.X
	local sy = viewportSize.Y / ref.Y
	return math.clamp(math.min(sx, sy), 0.65, 1.0)
end

local function getViewportSize()
	if not Camera then
		Camera = Workspace.CurrentCamera
	end
	return (Camera and Camera.ViewportSize) or Vector2.new(1920, 1080)
end

local function isCompactViewport(viewportSize)
	return viewportSize.X <= 960 or viewportSize.Y <= 700
end

local function getManagedPanelPosition(viewportSize)
	if isCompactViewport(viewportSize) then
		return MOBILE_PANEL_POS
	end
	return DESKTOP_PANEL_POS
end

local function getManagedMiniPosition(viewportSize)
	if isCompactViewport(viewportSize) then
		return MOBILE_MINI_POS
	end
	return DESKTOP_MINI_POS
end

local function nearlyEqual(a, b, tolerance)
	return math.abs(a - b) <= (tolerance or 0.001)
end

local function isLegacyDefaultPosition(position)
	if nearlyEqual(position.X.Scale, 0, 0.001) and math.abs(position.X.Offset - 24) <= 12 and nearlyEqual(position.Y.Scale, 1, 0.001) and math.abs(position.Y.Offset + 24) <= 12 then
		return true
	end
	if nearlyEqual(position.X.Scale, 0.214, 0.02) and math.abs(position.X.Offset) <= 16 and nearlyEqual(position.Y.Scale, 0.992, 0.02) and math.abs(position.Y.Offset) <= 16 then
		return true
	end
	return false
end

local function isClearlyOffscreen(position, viewportSize, scale)
	if not panel then
		return false
	end
	local width = panel.AbsoluteSize.X
	local height = panel.AbsoluteSize.Y
	if width <= 0 or height <= 0 then
		width = panel.Size.X.Offset * scale
		height = panel.Size.Y.Offset * scale
	end
	local left = viewportSize.X * position.X.Scale + position.X.Offset - (panel.AnchorPoint.X * width)
	local top = viewportSize.Y * position.Y.Scale + position.Y.Offset - (panel.AnchorPoint.Y * height)
	local right = left + width
	local bottom = top + height
	return right < 24 or left > (viewportSize.X - 24) or bottom < 24 or top > (viewportSize.Y - 24)
end

local function shouldUseManagedDefault(position, viewportSize, scale)
	return isLegacyDefaultPosition(position) or isClearlyOffscreen(position, viewportSize, scale)
end

local function applyManagedLayout(viewportSize)
	if not viewportSize then
		viewportSize = getViewportSize()
	end
	if panel and panelUsesManagedDefault then
		panel.Position = getManagedPanelPosition(viewportSize)
	end
	if mini then
		mini.Position = getManagedMiniPosition(viewportSize)
	end
end

local function applyResponsiveScale()
	local vp = getViewportSize()
	local scale = computeScale(vp)
	if panelScale then
		panelScale.Scale = scale
	end
	if miniScale then
		miniScale.Scale = scale
	end
	applyManagedLayout(vp)
end

local function makeDraggable(frame)
	frame.Active = true
	frame.Selectable = true

	local dragging = false
	local dragStart = nil
	local startPos = nil

	local function update(input)
		if not dragStart or not startPos then
			return
		end
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if gui:GetAttribute("_SadCaveMusic_ControlActive") == true then
			return
		end
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			update(input)
		end
	end)
end

local function fetchPersistedPanelPos()
	local remote = getRemote("SadCaveMusic_Remote_GetPanelPos")
	if not remote then
		return nil
	end
	local ok, result = pcall(function()
		return remote:InvokeServer()
	end)
	if ok then
		return result
	end
	return nil
end

local function persistPanelPos(pos)
	local remote = getRemote("SadCaveMusic_Remote_SetPanelPos")
	if remote then
		pcall(function()
			remote:FireServer({
				xScale = pos.X.Scale,
				xOffset = pos.X.Offset,
				yScale = pos.Y.Scale,
				yOffset = pos.Y.Offset,
			})
		end)
	end
end

if panel then
	if not IS_EMBEDDED then
		local savedPos = fetchPersistedPanelPos()
		if type(savedPos) == "table" then
			local xs = tonumber(savedPos.xScale)
			local xo = tonumber(savedPos.xOffset)
			local ys = tonumber(savedPos.yScale)
			local yo = tonumber(savedPos.yOffset)
			if xs and xo and ys and yo then
				local persistedPos = UDim2.new(xs, xo, ys, yo)
				local viewportSize = getViewportSize()
				local scale = computeScale(viewportSize)
				if shouldUseManagedDefault(persistedPos, viewportSize, scale) then
					panelUsesManagedDefault = true
				else
					panel.Position = persistedPos
				end
			else
				panelUsesManagedDefault = true
			end
		else
			panelUsesManagedDefault = true
		end
		applyManagedLayout(getViewportSize())
		makeDraggable(panel)
		panel.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				panelUsesManagedDefault = false
				persistPanelPos(panel.Position)
			end
		end)
	else
		panel.Active = false
		panel.Selectable = false
	end
end

applyResponsiveScale()
if Camera then
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveScale)
end

local playlist = {}
local index = 1
local playing = false
local volume = tonumber(ambientRoot:GetAttribute(VOLUME_ATTR)) or 0.5

local function rebuildPlaylist()
	local sounds = {}
	for _, inst in ipairs(playlistFolder:GetChildren()) do
		if inst:IsA("Sound") and tostring(inst.SoundId) ~= "" and tostring(inst.SoundId) ~= "rbxassetid://0" then
			sounds[#sounds + 1] = inst
		end
	end
	table.sort(sounds, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)
	playlist = sounds
	if #playlist == 0 then
		index = 1
	else
		index = math.clamp(index, 1, #playlist)
	end
	return #playlist
end

local function chooseInitialTrack()
	if #playlist == 0 then
		index = 1
		return
	end
	local rng = Random.new()
	index = rng:NextInteger(1, #playlist)
end

local function chooseNextTrack()
	if #playlist == 0 then
		index = 1
		return
	end
	if #playlist == 1 then
		index = 1
		return
	end
	local previousIndex = index
	local rng = Random.new()
	repeat
		index = rng:NextInteger(1, #playlist)
	until index ~= previousIndex
end

local function currentSound()
	if #playlist == 0 then
		return nil
	end
	index = math.clamp(index, 1, #playlist)
	return playlist[index]
end

local function setCurrentTrackState(sound)
	ambientRoot:SetAttribute(CURRENT_TRACK_ATTR, sound and sound.Name or "")
end

local function applySongText()
	local sound = currentSound()
	if songLabel then
		if sound then
			songLabel.Text = "now playing: " .. sound.Name
		else
			songLabel.Text = "now playing: (none)"
		end
	end
	setCurrentTrackState(sound)
end

local function publishPlaybackState()
	ambientRoot:SetAttribute(PLAYING_ATTR, playing)
	ambientRoot:SetAttribute(VOLUME_ATTR, volume)
end

local function applyPlayText()
	if playPause then
		playPause.Text = playing and "Pause" or "Play"
	end
	publishPlaybackState()
end

local function setVolume(v)
	volume = math.clamp(tonumber(v) or 0, 0, 1)
	if sliderFill then
		sliderFill.Size = UDim2.new(volume, 0, 1, 0)
	end
	if knob then
		knob.Position = UDim2.new(volume, 0, 0.5, 0)
	end
	nowPlaying.Volume = volume
	publishPlaybackState()
end

local function loadCurrentIntoNowPlaying()
	local sound = currentSound()
	if not sound then
		nowPlaying:Stop()
		nowPlaying.SoundId = ""
		setCurrentTrackState(nil)
		return false
	end
	nowPlaying.SoundId = sound.SoundId
	nowPlaying.TimePosition = 0
	nowPlaying.Looped = false
	nowPlaying.Volume = volume
	pcall(function() nowPlaying.PlaybackSpeed = sound.PlaybackSpeed end)
	pcall(function() nowPlaying.RollOffMode = sound.RollOffMode end)
	pcall(function() nowPlaying.RollOffMaxDistance = sound.RollOffMaxDistance end)
	pcall(function() nowPlaying.RollOffMinDistance = sound.RollOffMinDistance end)
	setCurrentTrackState(sound)
	return true
end

local function isMusicEnabled()
	local value = ambientRoot:GetAttribute(MUSIC_ENABLED_ATTR)
	if value == nil then
		return true
	end
	return value == true
end

local function setMusicEnabled(enabled)
	ambientRoot:SetAttribute(MUSIC_ENABLED_ATTR, enabled == true)
end

local function playLoadedTrack()
	if nowPlaying.SoundId == "" then
		return
	end
	nowPlaying.Looped = false
	nowPlaying.Volume = volume
	nowPlaying:Play()
end

local function applyMusicEnabledState()
	if isMusicEnabled() then
		if playing then
			if nowPlaying.SoundId == "" and not loadCurrentIntoNowPlaying() then
				return
			end
			playLoadedTrack()
		end
	else
		nowPlaying:Pause()
	end
end

local function fetchPersistedPaused()
	local remote = getRemote("SadCaveMusic_Remote_GetPaused")
	if not remote then
		return nil
	end
	local ok, result = pcall(function()
		return remote:InvokeServer()
	end)
	if ok then
		return result
	end
	return nil
end

local function fetchPersistedMinimized()
	local remote = getRemote("SadCaveMusic_Remote_GetMinimized")
	if not remote then
		return nil
	end
	local ok, result = pcall(function()
		return remote:InvokeServer()
	end)
	if ok then
		return result
	end
	return nil
end

local function persistPausedState(isPaused)
	local remote = getRemote("SadCaveMusic_Remote_SetPaused")
	if remote then
		pcall(function()
			remote:FireServer(isPaused == true)
		end)
	end
end

local function persistMinimizedState(isMinimized)
	local remote = getRemote("SadCaveMusic_Remote_SetMinimized")
	if remote then
		pcall(function()
			remote:FireServer(isMinimized == true)
		end)
	end
end

local persistedPaused = fetchPersistedPaused()
playing = true
if persistedPaused == true then
	persistPausedState(false)
end
applyPlayText()

if IS_EMBEDDED then
	if panel then
		panel.Visible = true
	end
	if mini then
		mini.Visible = false
	end
else
	local persistedMinimized = fetchPersistedMinimized()
	if persistedMinimized ~= nil then
		local isMinimized = persistedMinimized == true
		if panel then
			panel.Visible = not isMinimized
		end
		if mini then
			mini.Visible = isMinimized
		end
	end
end

rebuildPlaylist()
if #playlist > 0 then
	chooseInitialTrack()
	loadCurrentIntoNowPlaying()
else
	applySongText()
end
setVolume(volume)
setMusicEnabled(true)

if playing and isMusicEnabled() and nowPlaying.SoundId ~= "" then
	nowPlaying.Volume = 0
	nowPlaying:Play()
	task.spawn(function()
		local targetVolume = volume
		local startTime = os.clock()
		while true do
			if not isMusicEnabled() or not playing then
				return
			end
			local alpha = (os.clock() - startTime) / 2
			if alpha >= 1 then
				break
			end
			nowPlaying.Volume = targetVolume * math.clamp(alpha, 0, 1)
			task.wait()
		end
		if isMusicEnabled() and playing then
			nowPlaying.Volume = targetVolume
		end
	end)
end

if playPause then
	playPause.MouseButton1Click:Connect(function()
		gui:SetAttribute("_SadCaveMusic_ControlActive", true)
		task.defer(function()
			gui:SetAttribute("_SadCaveMusic_ControlActive", false)
		end)
		togglePlaybackEvent:Fire()
	end)
end

if nextBtn then
	nextBtn.MouseButton1Click:Connect(function()
		gui:SetAttribute("_SadCaveMusic_ControlActive", true)
		task.defer(function()
			gui:SetAttribute("_SadCaveMusic_ControlActive", false)
		end)
		nextTrackEvent:Fire()
	end)
end

if panel and hideBtn and mini then
	if not IS_EMBEDDED then
		hideBtn.MouseButton1Click:Connect(function()
			gui:SetAttribute("_SadCaveMusic_ControlActive", true)
			task.defer(function()
				gui:SetAttribute("_SadCaveMusic_ControlActive", false)
			end)
			panel.Visible = false
			mini.Visible = true
			persistMinimizedState(true)
		end)

		mini.MouseButton1Click:Connect(function()
			gui:SetAttribute("_SadCaveMusic_ControlActive", true)
			task.defer(function()
				gui:SetAttribute("_SadCaveMusic_ControlActive", false)
			end)
			mini.Visible = false
			panel.Visible = true
			persistMinimizedState(false)
		end)
	else
		hideBtn.Visible = false
		mini.Visible = false
	end
elseif mini and IS_EMBEDDED then
	mini.Visible = false
end

local draggingSlider = false
local function updateFromX(x)
	if not sliderBack then
		return
	end
	local absPos = sliderBack.AbsolutePosition.X
	local absSize = sliderBack.AbsoluteSize.X
	if absSize <= 0 then
		return
	end
	setVolumeEvent:Fire((x - absPos) / absSize)
end

if sliderBack then
	sliderBack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			gui:SetAttribute("_SadCaveMusic_ControlActive", true)
			updateFromX(input.Position.X)
		end
	end)

	sliderBack.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = false
			gui:SetAttribute("_SadCaveMusic_ControlActive", false)
		end
	end)
end

UserInputService.InputChanged:Connect(function(input)
	if not draggingSlider then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		updateFromX(input.Position.X)
	end
end)

local function performTogglePlayback()
	rebuildPlaylist()
	if #playlist == 0 then
		playing = false
		applySongText()
		applyPlayText()
		return
	end
	if not isMusicEnabled() then
		setMusicEnabled(true)
	end
	playing = not playing
	applyPlayText()
	persistPausedState(not playing)
	if playing then
		if nowPlaying.SoundId == "" and not loadCurrentIntoNowPlaying() then
			return
		end
		playLoadedTrack()
	else
		nowPlaying:Pause()
	end
end

local function performNextTrack()
	rebuildPlaylist()
	if #playlist == 0 then
		applySongText()
		return
	end
	chooseNextTrack()
	applySongText()
	loadCurrentIntoNowPlaying()
	if playing and isMusicEnabled() then
		playLoadedTrack()
	end
end

togglePlaybackEvent.Event:Connect(performTogglePlayback)
nextTrackEvent.Event:Connect(performNextTrack)
setVolumeEvent.Event:Connect(function(v)
	setVolume(v)
end)

ambientRoot:GetAttributeChangedSignal(MUSIC_ENABLED_ATTR):Connect(function()
	applyMusicEnabledState()
end)

nowPlaying.Ended:Connect(function()
	if not playing then
		applyPlayText()
		return
	end
	-- Reusing the same Sound inside its own Ended callback can leave the new track loaded but idle.
	task.defer(performNextTrack)
end)

applySongText()
publishPlaybackState()
