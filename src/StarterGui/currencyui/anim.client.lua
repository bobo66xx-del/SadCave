local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local function _(arg1, arg2, arg3, arg4) -- Line 19, Named "createSound"
	local SOME = arg1:FindFirstChild(arg3)
	if SOME and SOME:IsA("Sound") then
		return SOME
	end
	local Sound = Instance.new("Sound")
	Sound.Name = arg3
	Sound.SoundId = arg2
	Sound.Volume = arg4 or 1
	Sound.Parent = arg1
	return Sound
end
local function _(arg1, arg2) -- Line 33, Named "scaledUDim2"
	return UDim2.new(arg1.X.Scale * arg2, math.floor(arg1.X.Offset * arg2), arg1.Y.Scale * arg2, math.floor(arg1.Y.Offset * arg2))
end
local function _(arg1) -- Line 42, Named "isValidButton"
	local children = arg1:IsA("TextButton")
	if not children then
		children = arg1:IsA("ImageButton")
	end
	return children
end
local tbl_upvr = {}
local TweenService_upvr = game:GetService("TweenService")
local function setupButton_upvr(arg1) -- Line 46, Named "setupButton"
	--[[ Upvalues[2]:
		[1]: tbl_upvr (readonly)
		[2]: TweenService_upvr (readonly)
	]]
	if arg1:GetAttribute("DisableGlobalButtonHover") == true then
		return
	end
	if tbl_upvr[arg1] then
	else
		tbl_upvr[arg1] = true
		local Size_upvr = arg1.Size
		local HoverSound = arg1:FindFirstChild("HoverSound")
		local var9_upvr
		if HoverSound and HoverSound:IsA("Sound") then
			var9_upvr = HoverSound
		else
			local Sound_2 = Instance.new("Sound")
			Sound_2.Name = "HoverSound"
			Sound_2.SoundId = "rbxassetid://0"
			Sound_2.Volume = 0.5
			Sound_2.Parent = arg1
			var9_upvr = Sound_2
		end
		local ClickSound = arg1:FindFirstChild("ClickSound")
		local var12_upvr
		if ClickSound and ClickSound:IsA("Sound") then
			var12_upvr = ClickSound
		else
			local Sound_3 = Instance.new("Sound")
			Sound_3.Name = "ClickSound"
			Sound_3.SoundId = "rbxassetid://0"
			Sound_3.Volume = 0.7
			Sound_3.Parent = arg1
			var12_upvr = Sound_3
		end
		local var14_upvw = false
		local var15_upvw = false
		local var16_upvw
		local function tweenSize_upvr(arg1_2, arg2, arg3, arg4) -- Line 64, Named "tweenSize"
			--[[ Upvalues[3]:
				[1]: var16_upvw (read and write)
				[2]: TweenService_upvr (copied, readonly)
				[3]: arg1 (readonly)
			]]
			if var16_upvw then
				var16_upvw:Cancel()
			end
			local var17 = arg3
			if not var17 then
				var17 = Enum.EasingStyle.Quad
			end
			local var18 = arg4
			if not var18 then
				var18 = Enum.EasingDirection.Out
			end
			local tbl = {}
			tbl.Size = arg1_2
			var16_upvw = TweenService_upvr:Create(arg1, TweenInfo.new(arg2, var17, var18), tbl)
			var16_upvw:Play()
		end
		local udim2_upvr_3 = UDim2.new(Size_upvr.X.Scale * 1.0120000000000002, math.floor(Size_upvr.X.Offset * 1.0120000000000002), Size_upvr.Y.Scale * 1.0120000000000002, math.floor(Size_upvr.Y.Offset * 1.0120000000000002))
		local udim2_upvr_2 = UDim2.new(Size_upvr.X.Scale * 0.92, math.floor(Size_upvr.X.Offset * 0.92), Size_upvr.Y.Scale * 0.92, math.floor(Size_upvr.Y.Offset * 0.92))
		local udim2_upvr = UDim2.new(Size_upvr.X.Scale * 1.1, math.floor(Size_upvr.X.Offset * 1.1), Size_upvr.Y.Scale * 1.1, math.floor(Size_upvr.Y.Offset * 1.1))
		local function updateVisual_upvr() -- Line 77, Named "updateVisual"
			--[[ Upvalues[8]:
				[1]: arg1 (readonly)
				[2]: var15_upvw (read and write)
				[3]: var14_upvw (read and write)
				[4]: tweenSize_upvr (readonly)
				[5]: udim2_upvr_3 (readonly)
				[6]: udim2_upvr_2 (readonly)
				[7]: udim2_upvr (readonly)
				[8]: Size_upvr (readonly)
			]]
			if not arg1.Parent then
			else
				if var15_upvw and var14_upvw then
					tweenSize_upvr(udim2_upvr_3, 0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					return
				end
				if var15_upvw then
					tweenSize_upvr(udim2_upvr_2, 0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					return
				end
				if var14_upvw then
					tweenSize_upvr(udim2_upvr, 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
					return
				end
				tweenSize_upvr(Size_upvr, 0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
			end
		end
		arg1.MouseEnter:Connect(function() -- Line 93
			--[[ Upvalues[3]:
				[1]: var14_upvw (read and write)
				[2]: var9_upvr (readonly)
				[3]: updateVisual_upvr (readonly)
			]]
			var14_upvw = true
			var9_upvr:Play()
			updateVisual_upvr()
		end)
		arg1.MouseLeave:Connect(function() -- Line 99
			--[[ Upvalues[3]:
				[1]: var14_upvw (read and write)
				[2]: var15_upvw (read and write)
				[3]: updateVisual_upvr (readonly)
			]]
			var14_upvw = false
			var15_upvw = false
			updateVisual_upvr()
		end)
		arg1.MouseButton1Down:Connect(function() -- Line 105
			--[[ Upvalues[3]:
				[1]: var15_upvw (read and write)
				[2]: var12_upvr (readonly)
				[3]: updateVisual_upvr (readonly)
			]]
			var15_upvw = true
			var12_upvr:Play()
			updateVisual_upvr()
		end)
		arg1.MouseButton1Up:Connect(function() -- Line 111
			--[[ Upvalues[2]:
				[1]: var15_upvw (read and write)
				[2]: updateVisual_upvr (readonly)
			]]
			var15_upvw = false
			updateVisual_upvr()
		end)
		arg1.Destroying:Connect(function() -- Line 116
			--[[ Upvalues[2]:
				[1]: tbl_upvr (copied, readonly)
				[2]: arg1 (readonly)
			]]
			tbl_upvr[arg1] = nil
		end)
	end
end
;(function(arg1) -- Line 121, Named "scanForButtons"
	--[[ Upvalues[1]:
		[1]: setupButton_upvr (readonly)
	]]
	for _, v in ipairs(arg1:GetDescendants()) do
		local children_2 = v:IsA("TextButton")
		if not children_2 then
			children_2 = v:IsA("ImageButton")
		end
		if children_2 then
			setupButton_upvr(v)
		end
	end
end)(PlayerGui)
PlayerGui.DescendantAdded:Connect(function(arg1) -- Line 131
	--[[ Upvalues[1]:
		[1]: setupButton_upvr (readonly)
	]]
	local children_3 = arg1:IsA("TextButton")
	if not children_3 then
		children_3 = arg1:IsA("ImageButton")
	end
	if children_3 then
		setupButton_upvr(arg1)
	end
end)
