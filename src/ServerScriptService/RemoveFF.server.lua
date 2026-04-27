
game.Workspace.ChildAdded:connect(function(character)
	if game.Players:GetPlayerFromCharacter(character) ~= nil then
	character:WaitForChild("ForceField"):Destroy()
	end
end)
