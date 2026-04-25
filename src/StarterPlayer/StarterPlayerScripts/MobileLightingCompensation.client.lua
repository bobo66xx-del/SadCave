local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- Mobile-only readability compensation for Sad Cave.
-- This intentionally makes small client-side adjustments without changing the desktop look.

-- Device detection
-- We treat a player as probably mobile only when touch is available and desktop-style
-- keyboard/mouse inputs are not. This avoids misclassifying touchscreen laptops/hybrids.
local REQUIRE_TOUCH_INPUT = true
local REJECT_KEYBOARD_INPUT = true
local REJECT_MOUSE_INPUT = true

-- Global lighting compensation
-- Small lifts only: enough to help mobile readability without flattening the mood.
local MOBILE_BRIGHTNESS_DELTA = 0.14
local MOBILE_EXPOSURE_DELTA = 0.16
local MOBILE_AMBIENT_LERP_ALPHA = 0.08
local MOBILE_OUTDOOR_AMBIENT_LERP_ALPHA = 0.08

-- Atmosphere / post-processing compensation
-- Mobile screens tend to lose detail in dark midtones, so we ease the heaviest depth/haze.
local MOBILE_ATMOSPHERE_DENSITY_DELTA = -0.02
local MOBILE_ATMOSPHERE_HAZE_DELTA = -0.04
local MOBILE_COLOR_BRIGHTNESS_DELTA = 0.02
local MOBILE_COLOR_CONTRAST_DELTA = -0.01
local MOBILE_BLOOM_INTENSITY_SCALE = 0.8
local MOBILE_SUNRAYS_INTENSITY_SCALE = 0.7
local MOBILE_DOF_FAR_SCALE = 0.5
local MOBILE_DOF_RADIUS_DELTA = 10
local MOBILE_BLUR_SIZE_OVERRIDE = 0

local function clamp(value, minimum, maximum)
	return math.clamp(value, minimum, maximum)
end

local function lerpTowardWhite(color, alpha)
	return color:Lerp(Color3.new(1, 1, 1), alpha)
end

local function isProbablyMobileClient()
	if REQUIRE_TOUCH_INPUT and not UserInputService.TouchEnabled then
		return false
	end

	if REJECT_KEYBOARD_INPUT and UserInputService.KeyboardEnabled then
		return false
	end

	if REJECT_MOUSE_INPUT and UserInputService.MouseEnabled then
		return false
	end

	return true
end

local function getFirstEffect(name, className)
	local namedEffect = Lighting:FindFirstChild(name)
	if namedEffect and namedEffect:IsA(className) then
		return namedEffect
	end

	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA(className) then
			return child
		end
	end

	return nil
end

local function applyMobileLightingCompensation()
	-- Slightly lift the darkest walkable areas on small mobile screens.
	Lighting.Brightness = Lighting.Brightness + MOBILE_BRIGHTNESS_DELTA
	Lighting.ExposureCompensation = Lighting.ExposureCompensation + MOBILE_EXPOSURE_DELTA
	Lighting.Ambient = lerpTowardWhite(Lighting.Ambient, MOBILE_AMBIENT_LERP_ALPHA)
	Lighting.OutdoorAmbient = lerpTowardWhite(Lighting.OutdoorAmbient, MOBILE_OUTDOOR_AMBIENT_LERP_ALPHA)

	local atmosphere = getFirstEffect("SanctuaryAtmosphere", "Atmosphere")
	if atmosphere then
		atmosphere.Density = clamp(atmosphere.Density + MOBILE_ATMOSPHERE_DENSITY_DELTA, 0, 1)
		atmosphere.Haze = clamp(atmosphere.Haze + MOBILE_ATMOSPHERE_HAZE_DELTA, 0, 10)
	end

	local colorCorrection = getFirstEffect("SanctuaryColor", "ColorCorrectionEffect")
	if colorCorrection then
		colorCorrection.Brightness = clamp(colorCorrection.Brightness + MOBILE_COLOR_BRIGHTNESS_DELTA, -1, 1)
		colorCorrection.Contrast = clamp(colorCorrection.Contrast + MOBILE_COLOR_CONTRAST_DELTA, -1, 1)
	end

	local bloom = getFirstEffect("SanctuaryBloom", "BloomEffect")
	if bloom then
		bloom.Intensity = bloom.Intensity * MOBILE_BLOOM_INTENSITY_SCALE
	end

	local sunRays = getFirstEffect("SanctuaryRays", "SunRaysEffect")
	if sunRays then
		sunRays.Intensity = sunRays.Intensity * MOBILE_SUNRAYS_INTENSITY_SCALE
	end

	local depthOfField = getFirstEffect("DepthOfField", "DepthOfFieldEffect")
	if depthOfField then
		depthOfField.FarIntensity = depthOfField.FarIntensity * MOBILE_DOF_FAR_SCALE
		depthOfField.InFocusRadius = depthOfField.InFocusRadius + MOBILE_DOF_RADIUS_DELTA
	end

	local blur = getFirstEffect("SanctuaryBlur", "BlurEffect")
	if blur then
		blur.Size = MOBILE_BLUR_SIZE_OVERRIDE
	end
end

if not isProbablyMobileClient() then
	return
end

applyMobileLightingCompensation()
