function onChatted(msg, recipient, speaker) 

	local source = string.lower(speaker.Name)
	msg = string.lower(msg)

	if (msg == "/re") then
		
		local health = speaker.Character.Humanoid.Health
		speaker.Character.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(speaker.UserId))
		
		speaker.Character.Head.Transparency = 0
		speaker.Character.Head.face.Transparency = 0
	end 

end 

function onPlayerEntered(newPlayer) 
	newPlayer.Chatted:connect(function(msg, recipient) onChatted(msg, recipient, newPlayer) end) 
end 

game.Players.ChildAdded:connect(onPlayerEntered)







