local Players = game:GetService("Players")
local ScriptService = game:GetService("ServerScriptService")
local ChatService = require(game:GetService('ServerScriptService'):WaitForChild('ChatServiceRunner'):WaitForChild('ChatService'))
local service = game:GetService("MarketplaceService")

ChatService.SpeakerAdded:Connect(function(SpeakerName)
	local Player = Players:FindFirstChild(SpeakerName)
	local Speaker
	while not Speaker do
		Speaker = ChatService:GetSpeaker(tostring(SpeakerName))
		if Speaker then
			break
		end
		wait()
	end
	
	for _, v in pairs(script.Users:GetChildren()) do
		if v.Value ~= nil then
			if Player.UserId == v.Value then
				if v.NameColor.Enabled.Value == true then
					Speaker:SetExtraData("NameColor", v.NameColor.Value)
				end
				if v.ChatColor.Enabled.Value == true then
					Speaker:SetExtraData("ChatColor", v.ChatColor.Value)
				end
				if v.Tag.Enabled.Value == true then
					Speaker:SetExtraData("Tags", {{TagText = v.Tag.Value, TagColor = v.Tag.Color.Value}})
				end
			end
		else
			break
		end
	end
	
	for _, v in pairs(script.AllUserFriends:GetChildren()) do
		if v.Value ~= 0 then
			if Player:IsFriendsWith(v.Value) then
				if v.NameColor.Enabled.Value == true then
					Speaker:SetExtraData("NameColor", v.NameColor.Value)
				end
				if v.ChatColor.Enabled.Value == true then
					Speaker:SetExtraData("ChatColor", v.ChatColor.Value)
				end
				if v.Tag.Enabled.Value == true then
					Speaker:SetExtraData("Tags", {{TagText = v.Tag.Value, TagColor = v.Tag.Color.Value}})
				end
			end
		else
			break
		end
	end
	
	for _, v in pairs(script.Gamepasses:GetChildren()) do
		if v.Value ~= 0 then
			if service:UserOwnsGamePassAsync(Player.UserId, v.Value) then
				if v.NameColor.Enabled.Value == true then
					Speaker:SetExtraData("NameColor", v.NameColor.Value)
				end
				if v.ChatColor.Enabled.Value == true then
					Speaker:SetExtraData("ChatColor", v.ChatColor.Value)
				end
				if v.Tag.Enabled.Value == true then
					Speaker:SetExtraData("Tags", {{TagText = v.Tag.Value, TagColor = v.Tag.Color.Value}})
				end
			end
		else
			break
		end
	end
	
end)
