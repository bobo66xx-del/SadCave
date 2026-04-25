game.Players.PlayerAdded:connect(function(plr)
	plr.Chatted:connect(function(msg)
		local GampassId = 22828201
		local source = string.lower(plr.Name)
		
		
		
		
		
		-------------------------

		-------------------------
		
		if string.sub(msg, 1, 6) == "/morph" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then

			local yeah = string.sub(msg, 8, string.len(msg))

			local name = game.Players:GetUserIdFromNameAsync(yeah)
			print(yeah)
			plr.Character.Humanoid:ApplyDescription(game.Players:GetHumanoidDescriptionFromUserId(name))
		end
		
		-------------------------
		if string.sub(msg, 1, 6) == "/speed" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah2 = string.sub(msg, 8, string.len(msg))
			plr.Character.Humanoid.WalkSpeed = yeah2
		end
		-------------------------
		if string.sub(msg, 1, 3) == "/to" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah3 = string.sub(msg, 5, string.len(msg))
			plr.Character.Humanoid.Jump = true
			wait(.5)
			local pwayer = game.Players:FindFirstChild(yeah3)
			if pwayer then
				plr.Character.Head.CFrame = pwayer.Character.HumanoidRootPart.CFrame
			end
		end
		-------------------------
		if string.sub(msg, 1, 4) == "/hat" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah4 = string.sub(msg, 6, string.len(msg))
			local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = humanoid:GetAppliedDescription()
				descriptionClone.HatAccessory = descriptionClone.HatAccessory .. ","..yeah4
				humanoid:ApplyDescription(descriptionClone)
			end
		end
		-------------------------
		if string.sub(msg, 1, 5) == "/face" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah5 = string.sub(msg, 7, string.len(msg))
			local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = humanoid:GetAppliedDescription()
				descriptionClone.Face = yeah5
				humanoid:ApplyDescription(descriptionClone)
			end			
		end
		-------------------------
		if string.sub(msg, 1, 5) == "/back" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah6 = string.sub(msg, 6, string.len(msg))
			local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = humanoid:GetAppliedDescription()
				descriptionClone.BackAccessory = descriptionClone.BackAccessory .. ","..yeah6
				humanoid:ApplyDescription(descriptionClone)
			end
		end
		-------------------------
		if string.sub(msg, 1, 5) == "/hair" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah7 = string.sub(msg, 6, string.len(msg))
			local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = humanoid:GetAppliedDescription()
				descriptionClone.HairAccessory = descriptionClone.HairAccessory .. ","..yeah7
				humanoid:ApplyDescription(descriptionClone)
			end
		end
		-------------------------
		if string.sub(msg, 1, 6) == "/waist" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah8 = string.sub(msg, 8, string.len(msg))
			local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = humanoid:GetAppliedDescription()
				descriptionClone.WaistAccessory = descriptionClone.WaistAccessory .. ","..yeah8
				humanoid:ApplyDescription(descriptionClone)
			end
		end
		-------------------------
		if string.sub(msg, 1, 7) == "/tall" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah9 = string.sub(msg, 9, string.len(msg))
			local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = humanoid:GetAppliedDescription()
				descriptionClone.HeightScale = 2

				humanoid:ApplyDescription(descriptionClone)
			end
		end
		-------------------------
		if string.sub(msg, 1, 5) == "/mini" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah10 = string.sub(msg, 7, string.len(msg))
			local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = humanoid:GetAppliedDescription()
				descriptionClone.HeightScale = .5

				humanoid:ApplyDescription(descriptionClone)
			end
		end
		-------------------------
		if string.sub(msg, 1, 7) == "/normal" and game.MarketplaceService:UserOwnsGamePassAsync(plr.userId,GampassId)  then
			local yeah10 = string.sub(msg, 9, string.len(msg))
			local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
			if humanoid then
				local descriptionClone = humanoid:GetAppliedDescription()
				descriptionClone.HeightScale = 1
				
				humanoid:ApplyDescription(descriptionClone)
			end
		end
		-------------------------
	end)
end)

