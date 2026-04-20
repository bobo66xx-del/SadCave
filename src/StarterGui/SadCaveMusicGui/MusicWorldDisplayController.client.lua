local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CURRENT_TRACK_ATTR = "CurrentTrackName"
local PLAYING_ATTR = "IsPlaying"

local ambientRoot = SoundService:WaitForChild("SadCaveAmbient")
local nowPlaying = ambientRoot:WaitForChild("NowPlaying")

local function getSongLabels()
	local main = Workspace:FindFirstChild("@main")
	local recordPlayer = main and main:FindFirstChild("recordplayer")
	local billboardGui = recordPlayer and recordPlayer:FindFirstChild("BillboardGui")
	local songTitleLabel = billboardGui and billboardGui:FindFirstChild("Songtitle")
	local songTimeLabel = songTitleLabel and songTitleLabel:FindFirstChild("Songtime")
	return songTitleLabel, songTimeLabel
end

local function updateSongTitle()
	local songTitleLabel = getSongLabels()
	if not songTitleLabel then
		return
	end

	local trackName = ambientRoot:GetAttribute(CURRENT_TRACK_ATTR)
	if typeof(trackName) ~= "string" or trackName == "" then
		songTitleLabel.Text = ""
		return
	end

	songTitleLabel.Text = trackName
end

local function formatTime(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function updateSongTime()
	local _, songTimeLabel = getSongLabels()
	if not songTimeLabel then
		return
	end

	local soundId = nowPlaying.SoundId
	if not soundId or soundId == "" then
		songTimeLabel.Text = ""
		return
	end

	local timePosition = nowPlaying.TimePosition or 0
	local timeLength = nowPlaying.TimeLength or 0
	if timeLength > 0 then
		songTimeLabel.Text = formatTime(timePosition) .. " / " .. formatTime(timeLength)
	else
		songTimeLabel.Text = formatTime(timePosition) .. " / ??:??"
	end
end

local function syncDisplay()
	updateSongTitle()
	updateSongTime()
end

ambientRoot:GetAttributeChangedSignal(CURRENT_TRACK_ATTR):Connect(function()
	updateSongTitle()
	updateSongTime()
end)
ambientRoot:GetAttributeChangedSignal(PLAYING_ATTR):Connect(updateSongTime)
nowPlaying:GetPropertyChangedSignal("SoundId"):Connect(function()
	updateSongTitle()
	updateSongTime()
end)
nowPlaying:GetPropertyChangedSignal("TimeLength"):Connect(updateSongTime)

RunService.RenderStepped:Connect(updateSongTime)
syncDisplay()
