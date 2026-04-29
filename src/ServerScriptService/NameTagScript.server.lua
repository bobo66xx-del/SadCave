-- Robust nametag: attaches to HumanoidRootPart (Avalog-safe) and re-applies if destroyed.
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local TitleService = require(ServerScriptService:WaitForChild("TitleService"))

local function getTitlePayload(player)
	return TitleService.GetPlayerTitlePayload(player)
end

local function applyTitlePayload(bb, payload)
	TitleService.ApplyTitlePayloadToBillboard(bb, payload)
end

local function ensureBillboardLayout(bb, displayName)
	bb.Size = UDim2.new(0, 200, 0, 50)

	local titleLabel = bb:FindFirstChild("TitleLabel")
	if not titleLabel or not titleLabel:IsA("TextLabel") then
		if titleLabel then
			titleLabel:Destroy()
		end

		titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "TitleLabel"
		titleLabel.Parent = bb
	end

	titleLabel.Size = UDim2.new(1, 0, 0, 16)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.TextSize = 11
	titleLabel.TextColor3 = Color3.fromRGB(225, 215, 200)
	titleLabel.TextTransparency = 0.25
	titleLabel.TextStrokeTransparency = 0.7
	titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	titleLabel.TextYAlignment = Enum.TextYAlignment.Bottom

	local nameLabel = bb:FindFirstChild("NameLabel")
	if not nameLabel or not nameLabel:IsA("TextLabel") then
		if nameLabel then
			nameLabel:Destroy()
		end

		nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Parent = bb
	end

	nameLabel.Size = UDim2.new(1, 0, 0, 28)
	nameLabel.Position = UDim2.new(0, 0, 0, 19)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.fromRGB(225, 215, 200)
	nameLabel.TextStrokeTransparency = 0.6
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.TextYAlignment = Enum.TextYAlignment.Top
	nameLabel.Text = displayName

	return bb
end

local function buildBillboard(adornee, displayName)
	local bb = Instance.new("BillboardGui")
	bb.Name = "NameTag"
	bb.Adornee = adornee
	bb.AlwaysOnTop = true
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.MaxDistance = 100

	return ensureBillboardLayout(bb, displayName)
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
		if existing and existing:IsA("BillboardGui") then
			ensureBillboardLayout(existing, player.DisplayName)
			applyTitlePayload(existing, getTitlePayload(player))
			return existing
		end

		local newBillboard = buildBillboard(hrp, player.DisplayName)
		applyTitlePayload(newBillboard, getTitlePayload(player))
		newBillboard.Parent = hrp
		return newBillboard
	end

	local bb = ensureBillboard()

	-- Watchdog: if Avalog destroys our BillboardGui, recreate it.
	local function watchBillboard()
		bb.AncestryChanged:Connect(function(_, parent)
			if not parent and character.Parent then
				task.wait(0.1)
				if not character.Parent then return end
				bb = ensureBillboard()
				watchBillboard()
			end
		end)
	end
	watchBillboard()
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
