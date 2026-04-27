local PresenceTick = {}

function PresenceTick.GetTickAmount(_player, state, sourceConfig)
	if state.isAFK then
		return sourceConfig.PRESENCE_AFK_XP, "afk"
	end

	if state.seatedAt then
		local elapsed = os.time() - state.seatedAt
		if elapsed >= sourceConfig.SITTING_THRESHOLD_SECONDS then
			return sourceConfig.PRESENCE_SITTING_XP, "sitting"
		end
	end

	return sourceConfig.PRESENCE_ACTIVE_XP, "active"
end

return PresenceTick
