-- Daily Rewards (server)
-- Persists last claim time using DataStore + os.time() so the timer continues while offline.
-- Server is authoritative: clients can only request; server validates every claim.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local COOLDOWN_SECONDS = 24 * 60 * 60
local REWARD_SHARDS = 150

-- 1) RemoteObjects (created if missing)
-- NOTE: Your existing UI expects these legacy names directly under ReplicatedStorage:
--   RemoteFunction "DailyRewardStatus" and RemoteEvent "ClaimDailyReward"
-- We still keep the newer folder remotes too, but we alias them to avoid breaking your UI.

local remotesFolder = ReplicatedStorage:FindFirstChild("DailyRewardsRemotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "DailyRewardsRemotes"
	remotesFolder.Parent = ReplicatedStorage
end

local getStatus = remotesFolder:FindFirstChild("GetStatus")
if not getStatus then
	getStatus = Instance.new("RemoteFunction")
	getStatus.Name = "GetStatus"
	getStatus.Parent = remotesFolder
end

local claimEvent = remotesFolder:FindFirstChild("Claim")
if not claimEvent then
	claimEvent = Instance.new("RemoteEvent")
	claimEvent.Name = "Claim"
	claimEvent.Parent = remotesFolder
end

-- Legacy aliases used by existing LocalScripts
local legacyStatus = ReplicatedStorage:FindFirstChild("DailyRewardStatus")
if not legacyStatus then
	legacyStatus = Instance.new("RemoteFunction")
	legacyStatus.Name = "DailyRewardStatus"
	legacyStatus.Parent = ReplicatedStorage
end

local legacyClaim = ReplicatedStorage:FindFirstChild("ClaimDailyReward")
if not legacyClaim then
	legacyClaim = Instance.new("RemoteEvent")
	legacyClaim.Name = "ClaimDailyReward"
	legacyClaim.Parent = ReplicatedStorage
end

-- 2) DataStore
local LastClaimStore = DataStoreService:GetDataStore("DailyRewards_LastClaim_v1")

-- Cache in memory to reduce DataStore reads
local lastClaimCache: {[number]: number} = {}

local function getLastClaim(userId: number): number
	local cached = lastClaimCache[userId]
	if cached ~= nil then
		return cached
	end

	local loaded = 0
	pcall(function()
		loaded = LastClaimStore:GetAsync(userId) or 0
	end)
	loaded = tonumber(loaded) or 0
	lastClaimCache[userId] = loaded
	return loaded
end

local function computeStatusFromLastClaim(lastClaimTs: number)
	local now = os.time()
	local elapsed = now - (tonumber(lastClaimTs) or 0)
	if elapsed >= COOLDOWN_SECONDS then
		return true, 0
	end
	return false, math.max(0, COOLDOWN_SECONDS - elapsed)
end

local function getStatusForPlayer(player: Player)
	local lastClaimTs = getLastClaim(player.UserId)
	local canClaim, timeLeft = computeStatusFromLastClaim(lastClaimTs)
	return {
		CanClaim = canClaim,
		TimeLeft = timeLeft,
		CooldownSeconds = COOLDOWN_SECONDS,
		RewardAmount = REWARD_SHARDS,
	}
end

-- Load on join (optional because we lazy-load, but this warms the cache)
Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		getLastClaim(player.UserId)
		-- push status once so UI can initialize without waiting on invoke spam
		claimEvent:FireClient(player, getStatusForPlayer(player))
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	lastClaimCache[player.UserId] = nil
end)

-- RemoteFunction: client requests status (display only)
function getStatus.OnServerInvoke(player: Player)
	return getStatusForPlayer(player)
end

-- Legacy RemoteFunction support (existing UI)
function legacyStatus.OnServerInvoke(player: Player)
	return getStatusForPlayer(player)
end

-- Helper: award shards (your game stores IntValue named "Shards" under the Player)
local function awardShards(player: Player, amount: number)
	--[[
		CONNECT YOUR SHARDS VALUE HERE:
		Your game already has: player.Shards (IntValue) created in ServerScriptService.CashLeaderstats
		If you ever move to leaderstats, change this lookup accordingly.
	]]
	local shards = player:FindFirstChild("Shards")
	if shards and shards:IsA("IntValue") then
		shards.Value += amount
		return true
	end
	return false
end

-- RemoteEvent: claim request
local function handleClaim(player: Player)
	-- Server-authoritative validation
	local lastClaimTs = getLastClaim(player.UserId)
	local canClaim = computeStatusFromLastClaim(lastClaimTs)
	if canClaim ~= true then
		-- Not ready; just resend current status
		local status = getStatusForPlayer(player)
		claimEvent:FireClient(player, status)
		legacyClaim:FireClient(player, status)
		return
	end

	-- Award and persist immediately
	awardShards(player, REWARD_SHARDS)

	local newTs = os.time()
	lastClaimCache[player.UserId] = newTs
	pcall(function()
		LastClaimStore:SetAsync(player.UserId, newTs)
	end)

	-- Send updated status back instantly
	local status = getStatusForPlayer(player)
	claimEvent:FireClient(player, status)
	legacyClaim:FireClient(player, status)
end

claimEvent.OnServerEvent:Connect(handleClaim)
legacyClaim.OnServerEvent:Connect(handleClaim)
