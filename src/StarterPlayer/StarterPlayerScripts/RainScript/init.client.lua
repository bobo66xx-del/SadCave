--!GENERATED
local Rain = require(script.Rain)

local rainEnabledState = script:FindFirstChild("RainEnabledState")
if not rainEnabledState then
	rainEnabledState = Instance.new("BoolValue")
	rainEnabledState.Name = "RainEnabledState"
	rainEnabledState.Parent = script
end

local setRainEnabled = script:FindFirstChild("SetRainEnabled")
if not setRainEnabled then
	setRainEnabled = Instance.new("BindableFunction")
	setRainEnabled.Name = "SetRainEnabled"
	setRainEnabled.Parent = script
end

local function syncRainEnabledState()
	rainEnabledState.Value = Rain:IsEnabled()
	script:SetAttribute("RainEnabled", rainEnabledState.Value)
end

setRainEnabled.OnInvoke = function(isEnabled)
	Rain:SetEnabled(isEnabled)
	syncRainEnabledState()
	return rainEnabledState.Value
end

syncRainEnabledState()

Rain:SetColor(Color3.fromRGB(script.Color.Value.x, script.Color.Value.y, script.Color.Value.z))
Rain:SetDirection(script.Direction.Value)

Rain:SetTransparency(script.Transparency.Value)
Rain:SetSpeedRatio(script.SpeedRatio.Value)
Rain:SetIntensityRatio(script.IntensityRatio.Value)
Rain:SetLightInfluence(script.LightInfluence.Value)
Rain:SetLightEmission(script.LightEmission.Value)

Rain:SetVolume(script.Volume.Value)

Rain:SetSoundId(script.SoundId.Value)
Rain:SetStraightTexture(script.StraightTexture.Value)
Rain:SetTopDownTexture(script.TopDownTexture.Value)
Rain:SetSplashTexture(script.SplashTexture.Value)

local threshold = script.TransparencyThreshold.Value
if script.TransparencyConstraint.Value and script.CanCollideConstraint.Value then
	Rain:SetCollisionMode(
		Rain.CollisionMode.Function,
		function(p)
			return p.Transparency <= threshold and p.CanCollide
		end
	)
elseif script.TransparencyConstraint.Value then
	Rain:SetCollisionMode(
		Rain.CollisionMode.Function,
		function(p)
			return p.Transparency <= threshold
		end
	)
elseif script.CanCollideConstraint.Value then
	Rain:SetCollisionMode(
		Rain.CollisionMode.Function,
		function(p)
			return p.CanCollide
		end
	)
end

Rain:Enable()
syncRainEnabledState()
