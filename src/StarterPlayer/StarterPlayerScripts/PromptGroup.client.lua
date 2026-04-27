local GROUP_ID = 8106647
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")

task.wait(10) -- how long the script waits after you join before prompting the join group.

local player = Players.LocalPlayer

-- Check if player is already in the group before prompting
if player and not player:IsInGroup(GROUP_ID) then
	local success, result = pcall(function()
		return GroupService:PromptJoinAsync(GROUP_ID)
	end)
end