local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent that clients use to request toggling overhead tags
local evt = ReplicatedStorage:FindFirstChild("OverheadTagsToggle")
if not evt then
	evt = Instance.new("RemoteEvent")
	evt.Name = "OverheadTagsToggle"
	evt.Parent = ReplicatedStorage
end

-- Global switch used by NameTagScript Owner
local toggle = ReplicatedStorage:FindFirstChild("OverheadTagsEnabled")
if not toggle then
	toggle = Instance.new("BoolValue")
	toggle.Name = "OverheadTagsEnabled"
	toggle.Value = true
	toggle.Parent = ReplicatedStorage
end

-- BindableEvent listened to by NameTagScript Owner to rebuild tags without respawn
local rebuildEvt = ReplicatedStorage:FindFirstChild("RebuildOverheadTags")
if not rebuildEvt then
	rebuildEvt = Instance.new("BindableEvent")
	rebuildEvt.Name = "RebuildOverheadTags"
	rebuildEvt.Parent = ReplicatedStorage
end

-- IMPORTANT: Overhead tag visibility is now a LOCAL, client-side preference.
-- This server RemoteEvent is kept only for backward compatibility (older clients may still fire it),
-- but it must NOT change shared state.

evt.OnServerEvent:Connect(function(_player, _enabled)
	-- no-op
	-- (do not modify ReplicatedStorage.OverheadTagsEnabled)
end)
