local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- SETTINGS
local USE_M_KEY = false -- set true if you still want M as well
local MARKER_FOLDER_NAME = "SeatMarkersClient"
local SEATS_FOLDER_NAME = "Seats" -- optional. if missing, it scans whole workspace

local SHOW_TRANSPARENCY = 0.25
local MARKER_SIZE = Vector3.new(1.2, 1.2, 1.2)
local MARKER_OFFSET_Y = 2

-- Find button anywhere under PlayerGui
local function findSeatButton()
	local pg = player:WaitForChild("PlayerGui")

	-- wait for guis to actually replicate
	for _ = 1, 120 do -- ~2 seconds
		for _, obj in ipairs(pg:GetDescendants()) do
			if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Name == "SeatToggleButton" then
				return obj
			end
		end
		task.wait(0.05)
	end

	warn("SeatToggleButton not found. In StarterGui, name your button exactly 'SeatToggleButton'.")
	return nil
end

local button = findSeatButton()
if not button then return end

-- Marker folder
local markersFolder = workspace:FindFirstChild(MARKER_FOLDER_NAME)
if not markersFolder then
	markersFolder = Instance.new("Folder")
	markersFolder.Name = MARKER_FOLDER_NAME
	markersFolder.Parent = workspace
end

-- Seat finding
local seatsFolder = workspace:FindFirstChild(SEATS_FOLDER_NAME)

local function getSeats()
	local list = {}
	local root = seatsFolder or workspace
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
			table.insert(list, obj)
		end
	end
	return list
end

-- Build markers once
local built = false
local visible = false

local function buildMarkers()
	if built then return end
	built = true

	for _, child in ipairs(markersFolder:GetChildren()) do
		child:Destroy()
	end

	local seats = getSeats()
	warn(("Seat toggle: found %d seats"):format(#seats))

	for _, seat in ipairs(seats) do
		local marker = Instance.new("Part")
		marker.Name = "SeatMarker"
		marker.Shape = Enum.PartType.Ball
		marker.Size = MARKER_SIZE
		marker.Anchored = true
		marker.CanCollide = false
		marker.Material = Enum.Material.Neon
		marker.Transparency = 0
		marker.LocalTransparencyModifier = 1
		marker.Parent = markersFolder

		marker.CFrame = seat.CFrame * CFrame.new(0, MARKER_OFFSET_Y, 0)

		seat:GetPropertyChangedSignal("CFrame"):Connect(function()
			if marker.Parent then
				marker.CFrame = seat.CFrame * CFrame.new(0, MARKER_OFFSET_Y, 0)
			end
		end)

		seat.AncestryChanged:Connect(function(_, parent)
			if not parent and marker.Parent then
				marker:Destroy()
			end
		end)
	end
end

local function setVisible(state)
	if state and not built then
		buildMarkers()
	end

	for _, marker in ipairs(markersFolder:GetChildren()) do
		if marker:IsA("BasePart") then
			marker.LocalTransparencyModifier = state and SHOW_TRANSPARENCY or 1
		end
	end

	if button:IsA("TextButton") then
		button.Text = state and "Hide Seats" or "Show Seats"
	end
end

local function toggle()
	visible = not visible
	setVisible(visible)
end

button.MouseButton1Click:Connect(toggle)

if USE_M_KEY then
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.M then
			toggle()
		end
	end)
end

setVisible(false)
warn("Seat toggle loaded OK")
