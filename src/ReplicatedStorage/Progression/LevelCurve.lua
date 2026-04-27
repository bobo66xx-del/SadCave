local SourceConfig = require(script.Parent.SourceConfig)

local LevelCurve = {}

-- XP required for a single level N (not cumulative).
function LevelCurve.GetXPForLevelDelta(level)
	if level < 1 then
		return 0
	end

	return math.floor(SourceConfig.CURVE_A + SourceConfig.CURVE_B * (level ^ SourceConfig.CURVE_C))
end

-- Cumulative XP required to reach level N.
local cumulativeCache = {}

function LevelCurve.GetXPForLevel(level)
	if level < 1 then
		return 0
	end

	if cumulativeCache[level] then
		return cumulativeCache[level]
	end

	local startLevel = 1
	local total = 0

	if cumulativeCache[level - 1] then
		startLevel = level
		total = cumulativeCache[level - 1]
	end

	for n = startLevel, level do
		total += LevelCurve.GetXPForLevelDelta(n)
		cumulativeCache[n] = total
	end

	return total
end

-- Given total XP, return the highest reached level.
function LevelCurve.GetLevel(totalXP)
	if totalXP < 0 then
		return 0
	end

	local level = 0
	while LevelCurve.GetXPForLevel(level + 1) <= totalXP do
		level += 1

		if level > 50000 then
			break
		end
	end

	return level
end

-- Returns: level, currentXPInLevel, xpRequiredForNextLevel.
function LevelCurve.GetLevelProgress(totalXP)
	local level = LevelCurve.GetLevel(totalXP)
	local xpAtCurrentLevel = LevelCurve.GetXPForLevel(level)
	local xpAtNextLevel = LevelCurve.GetXPForLevel(level + 1)
	local currentInLevel = totalXP - xpAtCurrentLevel
	local requiredForNext = xpAtNextLevel - xpAtCurrentLevel

	return level, currentInLevel, requiredForNext
end

return LevelCurve
