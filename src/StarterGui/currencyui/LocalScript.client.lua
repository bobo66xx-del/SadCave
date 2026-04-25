local Players = game:GetService("Players")
local player = Players.LocalPlayer

local shardsLabel = script.Parent.maincanvas.mainframe:FindFirstChild("ShardsValue")
if not shardsLabel then
	return
end

local function formatWithCommas(n: number)
	local s = tostring(math.floor(tonumber(n) or 0))
	local neg = false
	if string.sub(s, 1, 1) == "-" then
		neg = true
		s = string.sub(s, 2)
	end

	local formatted = s
	while true do
		local newStr, k = string.gsub(formatted, "^(%d+)(%d%d%d)", "%1,%2")
		formatted = newStr
		if k == 0 then break end
	end

	return neg and ("-" .. formatted) or formatted
end

-- Your game creates currency as an IntValue directly under the Player (ServerScriptService.CashLeaderstats)
-- so we should bind to player.Shards (not leaderstats.Shards).
local shardsValue: IntValue? = nil
local valueConn: RBXScriptConnection? = nil

local function setText(v: number)
	shardsLabel.Text = formatWithCommas(v)
end

local function hookToShards(newShards: IntValue)
	shardsValue = newShards
	if valueConn then
		valueConn:Disconnect()
		valueConn = nil
	end
	valueConn = shardsValue:GetPropertyChangedSignal("Value"):Connect(function()
		setText(shardsValue.Value)
	end)
	setText(shardsValue.Value) -- show current immediately
end

local function tryHook()
	local shards = player:FindFirstChild("Shards")
	if shards and shards:IsA("IntValue") then
		hookToShards(shards)
	end
end

-- immediate attempt
tryHook()

-- if Shards appears later
player.ChildAdded:Connect(function(child)
	if child.Name == "Shards" and child:IsA("IntValue") then
		hookToShards(child)
	end
end)

-- If we haven't hooked yet, show a loading placeholder instead of 0.
if not shardsValue then
	shardsLabel.Text = "..."
end
