--[[
	SoftShutdown 1.2
	Author: Merely
	
	This system lets you shut down servers without losing a bunch of players.
	When game.OnClose is called, the script teleports everyone in the server
	into a reserved server.
	
	When the reserved servers start up, they wait a few seconds, and then
	send everyone back into the main place.
	
	I added wait() in a couple of places because if you don't, everyone will spawn into
	their own servers with only 1 player.
--]]
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

if (game.VIPServerId ~= "" and game.VIPServerOwnerId == 0) then
	-- this is a reserved server without a VIP server owner

	local waitTime = 5

	Players.PlayerAdded:connect(function(player)
		
		local gui = player.PlayerGui:WaitForChild("ShutdownGUI")
		gui.Enabled = true
		
		ReplicatedFirst:RemoveDefaultLoadingScreen()

		TeleportService:SetTeleportGui(gui)
		
		
		

		wait(5)
		TeleportService:Teleport(game.PlaceId, player)
	end)

	for _,player in pairs(Players:GetPlayers()) do
		TeleportService:Teleport(game.PlaceId, player)
		local gui = player.PlayerGui:WaitForChild("ShutdownGUI")
		TeleportService:SetTeleportGui(gui)
		wait(waitTime)
		
		waitTime = waitTime / 2
	end
else
	game:BindToClose(function()
		if (#Players:GetPlayers() == 0) then
			return
		end

		if (game:GetService("RunService"):IsStudio()) then
			return
		end
		
		
		Players = game:GetService("Players")
		for i, player in pairs(Players:GetPlayers()) do
			local gui = player.PlayerGui:FindFirstChild("ShutdownGUI")
			gui.Enabled = true
			ReplicatedFirst:RemoveDefaultLoadingScreen()
			TeleportService:SetTeleportGui(gui)
		end
		
		
	
		
		wait(2)
		local reservedServerCode = TeleportService:ReserveServer(game.PlaceId)

		for _,player in pairs(Players:GetPlayers()) do
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end
		Players.PlayerAdded:connect(function(player)
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end)
		while (#Players:GetPlayers() > 0) do
			wait(1)
		end	

		-- done
	end)
end