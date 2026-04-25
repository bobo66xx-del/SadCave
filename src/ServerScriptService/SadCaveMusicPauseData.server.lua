local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local STORE_NAME = "SadCaveMusicPrefsV1"
local store = DataStoreService:GetDataStore(STORE_NAME)

local KEY_PREFIX = "u_"
local function keyForUserId(userId)
	return KEY_PREFIX .. tostring(userId)
end

-- RemoteFunction: client asks current saved paused state
-- RemoteFunction: client asks current saved paused state
local getFn = ReplicatedStorage:FindFirstChild("SadCaveMusic_Remote_GetPaused")
if not getFn then
	getFn = Instance.new("RemoteFunction")
	getFn.Name = "SadCaveMusic_Remote_GetPaused"
	getFn.Parent = ReplicatedStorage
end

-- RemoteEvent: client tells server new paused state
local setEv = ReplicatedStorage:FindFirstChild("SadCaveMusic_Remote_SetPaused")
if not setEv then
	setEv = Instance.new("RemoteEvent")
	setEv.Name = "SadCaveMusic_Remote_SetPaused"
	setEv.Parent = ReplicatedStorage
end

-- New: GUI minimized preference
local getMinFn = ReplicatedStorage:FindFirstChild("SadCaveMusic_Remote_GetMinimized")
if not getMinFn then
	getMinFn = Instance.new("RemoteFunction")
	getMinFn.Name = "SadCaveMusic_Remote_GetMinimized"
	getMinFn.Parent = ReplicatedStorage
end

local setMinEv = ReplicatedStorage:FindFirstChild("SadCaveMusic_Remote_SetMinimized")
if not setMinEv then
	setMinEv = Instance.new("RemoteEvent")
	setMinEv.Name = "SadCaveMusic_Remote_SetMinimized"
	setMinEv.Parent = ReplicatedStorage
end

-- New: GUI panel position preference (UDim2)
local getPosFn = ReplicatedStorage:FindFirstChild("SadCaveMusic_Remote_GetPanelPos")
if not getPosFn then
	getPosFn = Instance.new("RemoteFunction")
	getPosFn.Name = "SadCaveMusic_Remote_GetPanelPos"
	getPosFn.Parent = ReplicatedStorage
end

local setPosEv = ReplicatedStorage:FindFirstChild("SadCaveMusic_Remote_SetPanelPos")
if not setPosEv then
	setPosEv = Instance.new("RemoteEvent")
	setPosEv.Name = "SadCaveMusic_Remote_SetPanelPos"
	setPosEv.Parent = ReplicatedStorage
end

local sessionCache = {} -- [userId] = { paused: boolean?, minimized: boolean?, panelPos: table? }

local function safeGet(userId)
	local ok, result = pcall(function()
		return store:GetAsync(keyForUserId(userId))
	end)
	if ok and type(result) == "table" then
		return result
	end
	-- Backwards compatibility: if old value was a boolean, treat it as paused
	if ok and type(result) == "boolean" then
		return { paused = result }
	end
	return nil
end

local function safeSet(userId, prefs)
	if type(prefs) ~= "table" then
		return
	end
	pcall(function()
		local pos = prefs.panelPos
		store:SetAsync(keyForUserId(userId), {
			paused = (prefs.paused == true),
			minimized = (prefs.minimized == true),
			panelPos = (type(pos) == "table") and pos or nil,
		})
	end)
end

Players.PlayerAdded:Connect(function(player)
	local prefs = safeGet(player.UserId)
	if prefs ~= nil then
		sessionCache[player.UserId] = prefs
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local prefs = sessionCache[player.UserId]
	if prefs ~= nil then
		safeSet(player.UserId, prefs)
	end
	sessionCache[player.UserId] = nil
end)

getFn.OnServerInvoke = function(player)
	local cached = sessionCache[player.UserId]
	if cached ~= nil then
		return cached.paused
	end
	local prefs = safeGet(player.UserId)
	if prefs ~= nil then
		sessionCache[player.UserId] = prefs
		return prefs.paused
	end
	return nil
end

setEv.OnServerEvent:Connect(function(player, isPaused)
	if type(isPaused) ~= "boolean" then
		return
	end
	local prefs = sessionCache[player.UserId]
	if prefs == nil then prefs = {} end
	prefs.paused = isPaused
	sessionCache[player.UserId] = prefs
	safeSet(player.UserId, prefs)
end)

getMinFn.OnServerInvoke = function(player)
	local cached = sessionCache[player.UserId]
	if cached ~= nil then
		return cached.minimized
	end
	local prefs = safeGet(player.UserId)
	if prefs ~= nil then
		sessionCache[player.UserId] = prefs
		return prefs.minimized
	end
	return nil
end

setMinEv.OnServerEvent:Connect(function(player, isMinimized)
	if type(isMinimized) ~= "boolean" then
		return
	end
	local prefs = sessionCache[player.UserId]
	if prefs == nil then prefs = {} end
	prefs.minimized = isMinimized
	sessionCache[player.UserId] = prefs
	safeSet(player.UserId, prefs)
end)

-- panelPos is saved as a plain table so it can be stored in DataStore:
-- { xScale, xOffset, yScale, yOffset }
getPosFn.OnServerInvoke = function(player)
	local cached = sessionCache[player.UserId]
	if cached ~= nil then
		return cached.panelPos
	end
	local prefs = safeGet(player.UserId)
	if prefs ~= nil then
		sessionCache[player.UserId] = prefs
		return prefs.panelPos
	end
	return nil
end

setPosEv.OnServerEvent:Connect(function(player, panelPos)
	if type(panelPos) ~= "table" then
		return
	end
	local xs = tonumber(panelPos.xScale)
	local xo = tonumber(panelPos.xOffset)
	local ys = tonumber(panelPos.yScale)
	local yo = tonumber(panelPos.yOffset)
	if xs == nil or xo == nil or ys == nil or yo == nil then
		return
	end

	local prefs = sessionCache[player.UserId]
	if prefs == nil then prefs = {} end
	prefs.panelPos = {
		xScale = xs,
		xOffset = xo,
		yScale = ys,
		yOffset = yo,
	}
	sessionCache[player.UserId] = prefs
	safeSet(player.UserId, prefs)
end)
