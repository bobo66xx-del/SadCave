local function C(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local function npc(text, speaker, characterId)
	return {
		speaker = speaker,
		characterId = characterId,
		text = text,
	}
end

local function npcLines(lines, speaker, characterId)
	return {
		speaker = speaker,
		characterId = characterId,
		lines = lines,
	}
end

local function playerLine(text, mode)
	return {
		speaker = "Player",
		mode = mode or "spoken",
		text = text,
	}
end

local function choice(id, prompt, choices, branches, timeout)
	return {
		kind = "choice",
		id = id,
		prompt = prompt,
		choices = choices,
		branches = branches,
		timeout = timeout,
	}
end

return {
	Global = {
		interactKey = Enum.KeyCode.E,
		checkInterval = 0.1,
		dialoguePointName = "DialoguePoint",
		fallbackTriggerDistance = 12,

		maxVisibleNpcLines = 2,

		dialogueFrontDistance = 1.3,
		dialogueFrontHeight = 0.68,

		npcDecayBase = 2.2,
		npcDecayPerWord = 0.24,
		npcDecayPerCharacter = 0.042,
		npcDecayMin = 2.8,
		npcDecayMax = 7.5,
	},

	Characters = {
		QuietKeeper = {
			displayName = "The Quiet Keeper",
			modelName = "QuietKeeperNPC",
			triggerDistance = 14,
			promptText = "Talk",
			typeSpeed = 0.04,
			dialogueRenderMode = "subtitle",
			style = {
				font = Enum.Font.GothamMedium,
				shadowFont = Enum.Font.GothamMedium,
				textColor = C(224, 221, 232),
				strokeColor = C(35, 31, 42),
				strokeTransparency = 0.5,
				shadowColor = C(8, 8, 12),
				shadowTransparency = 0.82,
				lineBackgroundColor = C(22, 19, 28),
				lineBackgroundTransparency = 0.30,
				lineBorderColor = C(94, 84, 112),
				lineBorderTransparency = 0.80,
				lineBorderThickness = 1,
				cornerRadius = 14,
				shadowOffset = Vector2.new(0, 2),
			},

			conversations = {
				start = {
					npc("You made it inside.", "The Quiet Keeper"),
					npc("This place is called Sad Cave.", "The Quiet Keeper"),
					npc("It is not here to rush you.", "The Quiet Keeper"),
					npc("It is here to give you somewhere quiet to exist for a while.", "The Quiet Keeper"),

					choice("quiet_keeper_intro_choice", "What do you say?", {
						{
							id = "what_is_this",
							text = "What is this place?",
						},
						{
							id = "need_quiet",
							text = "I just need somewhere quiet.",
						},
						{
							id = "explore",
							text = "I'm going to explore.",
						},
					}, {
						what_is_this = {
							playerLine("What is this place?"),
							npc("A cave for people carrying things they do not always want to explain.", "The Quiet Keeper"),
							npc("You can walk, sit, listen, or disappear into the dark for a bit.", "The Quiet Keeper"),
							npc("No one here needs you to perform.", "The Quiet Keeper"),
						},

						need_quiet = {
							playerLine("I just need somewhere quiet."),
							npc("Then you found the right place.", "The Quiet Keeper"),
							npc("You do not have to talk.", "The Quiet Keeper"),
							npc("Stay as long as you need.", "The Quiet Keeper"),
						},

						explore = {
							playerLine("I'm going to explore."),
							npc("Good.", "The Quiet Keeper"),
							npc("The cave has places meant for different moods.", "The Quiet Keeper"),
							npc("Some are darker. Some are softer. Find the one that feels right.", "The Quiet Keeper"),
						},

						default = {
							npc("No answer is fine.", "The Quiet Keeper"),
							npc("Silence fits this place too.", "The Quiet Keeper"),
						},
					}, 14),

					npc("When you are ready, keep walking deeper in.", "The Quiet Keeper"),
					npc("The cave opens up more than it first appears.", "The Quiet Keeper"),
				},

				returning = {
					npc("Back again.", "The Quiet Keeper"),
					npc("That is alright.", "The Quiet Keeper"),

					choice("quiet_keeper_return_choice", "What do you need?", {
						{
							id = "just_here",
							text = "Just here.",
						},
						{
							id = "where_go",
							text = "Where should I go?",
						},
					}, {
						just_here = {
							playerLine("Just here."),
							npc("Then just be here.", "The Quiet Keeper"),
							npc("That is enough.", "The Quiet Keeper"),
						},

						where_go = {
							playerLine("Where should I go?"),
							npc("Start with the lower path.", "The Quiet Keeper"),
							npc("It is quiet, but not empty.", "The Quiet Keeper"),
						},

						default = {
							npc("No rush.", "The Quiet Keeper"),
						},
					}, 12),
				},
			},

			defaultConversation = "start",

			allowedConversationIds = {
				"returning",
			},
		},
	},

	Player = {
		typeSpeed = 0.03,
		holdDuration = 1.05,
		betweenLinesDelay = 0.1,
		choiceTimeout = 18,
		soundsEnabled = false,
		ui = {
			subtitlePosition = UDim2.fromScale(0.5, 0.91),
			choicePosition = UDim2.fromScale(0.5, 0.95),
		},
		uiStyle = {
			panelCornerRadius = 16,
			subtitlePanelColor = C(20, 18, 25),
			subtitlePanelTransparency = 0.16,
			subtitleBorderColor = C(103, 94, 120),
			subtitleBorderTransparency = 0.56,
			subtitleShadowColor = C(6, 6, 8),
			subtitleShadowTransparency = 0.7,
			choicePanelColor = C(18, 17, 23),
			choicePanelTransparency = 0.14,
			choiceBorderColor = C(101, 92, 118),
			choiceBorderTransparency = 0.54,
			choiceShadowColor = C(6, 6, 8),
			choiceShadowTransparency = 0.72,
			choicePromptColor = C(191, 186, 202),
			choicePromptStrokeColor = C(27, 25, 33),
			choicePromptStrokeTransparency = 0.64,
		},
		styles = {
			spoken = {
				label = "You",
				textColor = C(229, 226, 236),
				strokeColor = C(34, 31, 41),
				strokeTransparency = 0.5,
			},
			thought = {
				label = "Thought",
				textColor = C(197, 194, 206),
				strokeColor = C(30, 28, 36),
				strokeTransparency = 0.6,
			},
			choice = {
				textColor = C(227, 224, 233),
				strokeColor = C(40, 36, 48),
				backgroundColor = C(35, 31, 41),
				backgroundTransparency = 0.18,
				borderColor = C(120, 110, 143),
				borderTransparency = 0.6,
				hoverBackgroundColor = C(42, 37, 49),
				hoverBackgroundTransparency = 0.12,
				hoverBorderColor = C(140, 130, 166),
				hoverBorderTransparency = 0.48,
				pressedBackgroundColor = C(29, 26, 34),
				pressedBackgroundTransparency = 0.08,
				pressedBorderColor = C(158, 148, 184),
				pressedBorderTransparency = 0.38,
			},
		},
	},
}