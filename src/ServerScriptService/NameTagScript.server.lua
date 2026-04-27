-- Robust nametag: attaches to HumanoidRootPart (Avalog-safe) and re-applies if destroyed.
local Players = game:GetService("Players")

local function buildBillboard(adornee, displayName)
	local bb = Instance.new("BillboardGui")
	bb.Name = "NameTag"
	bb.Adornee = adornee
	bb.AlwaysOnTop = true
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.MaxDistance = 100

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.fromRGB(225, 215, 200)
	nameLabel.TextStrokeTransparency = 0.6
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Text = displayName
	nameLabel.Parent = bb

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(1, 0, 0.4, 0)
	levelLabel.Position = UDim2.new(0, 0, 0.6, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextSize = 12
	levelLabel.TextColor3 = Color3.fromRGB(180, 170, 155)
	levelLabel.TextStrokeTransparency = 0.7
	levelLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	levelLabel.Text = "level 0"
	levelLabel.Parent = bb

	return bb, levelLabel
end

local function applyNameTag(player, character)
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	if not hrp then return end

	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	local function ensureBillboard()
		local existing = hrp:FindFirstChild("NameTag")
		if existing and existing:IsA("BillboardGui") then return existing, existing:FindFirstChild("LevelLabel") end
		local bb, levelLabel = buildBillboard(hrp, player.DisplayName)
		bb.Parent = hrp
		return bb, levelLabel
	end

	local bb, levelLabel = ensureBillboard()

	local function updateLevel()
		local lb = player:FindFirstChild("leaderstats")
		local lvl = lb and lb:FindFirstChild("Level")
		if lvl and levelLabel and levelLabel.Parent then
			levelLabel.Text = "level " .. tostring(lvl.Value)
		end
	end

	-- Watchdog: if Avalog destroys our BillboardGui, recreate it.
	local function watchBillboard()
		bb.AncestryChanged:Connect(function(_, parent)
			if not parent and character.Parent then
				task.wait(0.1)
				if not character.Parent then return end
				bb, levelLabel = ensureBillboard()
				updateLevel()
				watchBillboard()
			end
		end)
	end
	watchBillboard()

	-- Hook leaderstats for level updates
	local function hookLeaderstats(lb)
		local lvl = lb:FindFirstChild("Level")
		if lvl then
			updateLevel()
			lvl:GetPropertyChangedSignal("Value"):Connect(updateLevel)
		end
		lb.ChildAdded:Connect(function(c)
			if c.Name == "Level" and c:IsA("IntValue") then
				updateLevel()
				c:GetPropertyChangedSignal("Value"):Connect(updateLevel)
			end
		end)
	end

	local existingLB = player:FindFirstChild("leaderstats")
	if existingLB then
		hookLeaderstats(existingLB)
	else
		player.ChildAdded:Connect(function(c)
			if c.Name == "leaderstats" then hookLeaderstats(c) end
		end)
	end

	updateLevel()
end

local function onPlayer(player)
	if player.Character then
		task.spawn(applyNameTag, player, player.Character)
	end
	player.CharacterAdded:Connect(function(c)
		task.spawn(applyNameTag, player, c)
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayer, p)
end

print("[NameTag] script ready")

