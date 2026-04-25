local TitleConfig = {}

TitleConfig.DEFAULT_TITLE_ID = "newcomer"
TitleConfig.TITLE_PACK_GAMEPASS_ID = 1797105034

local SPECIAL_REQUIREMENT_TEXT = "special access"
local VALID_CATEGORIES = {
    level = true,
    shop = true,
    gamepass = true,
    special = true,
}
local VALID_EFFECT_TYPES = {
    none = true,
    tint = true,
    pulse = true,
    shimmer = true,
    flicker = true,
    glow = true,
}
local NONE_EFFECT = {
    type = "none",
}

local function cloneTable(source)
    if type(source) ~= "table" then
        return nil
    end

    local clone = {}
    for key, value in pairs(source) do
        clone[key] = value
    end
    return clone
end

local function makeEffect(effectType, options)
    local effect = cloneTable(options) or {}
    effect.type = VALID_EFFECT_TYPES[effectType] and effectType or "none"
    return effect
end

local function makeLevelTitle(id, displayName, requiredLevel, legacyAliases)
    return {
        id = id,
        displayName = displayName,
        category = "level",
        requiredLevel = requiredLevel,
        requirementText = string.format("level %d", requiredLevel),
        legacyAliases = legacyAliases,
    }
end

local function makeGamePassTitle(id, displayName, legacyAliases)
    return {
        id = id,
        displayName = displayName,
        category = "gamepass",
        requirementText = "title pack",
        legacyAliases = legacyAliases,
    }
end

local function makeShopTitle(id, displayName, priceShards, legacyAliases)
    return {
        id = id,
        displayName = displayName,
        category = "shop",
        priceShards = priceShards,
        requirementText = "buy in shop",
        legacyAliases = legacyAliases,
    }
end

local function makeSpecialTitle(id, displayName, attributeName)
    return {
        id = id,
        displayName = displayName,
        category = "special",
        requirementText = SPECIAL_REQUIREMENT_TEXT,
        attributeName = attributeName,
    }
end

local orderedTitles = {
    makeLevelTitle("newcomer", "newcomer", 0),
    makeLevelTitle("visitor", "visitor", 75),
    makeLevelTitle("night_owl", "night owl *", 150),
    makeLevelTitle("late_arrival", "late arrival *", 225),
    makeLevelTitle("local", "local *", 300),
    makeLevelTitle("dim_room", "dim room *", 400),
    makeLevelTitle("city_kid", "wanderer *", 500, {"city kid *", "city kid"}),
    makeLevelTitle("half_known", "half-known +", 625),
    makeLevelTitle("regular", "regular", 750),
    makeLevelTitle("slow_burn", "slow burn +", 900),
    makeLevelTitle("after_dark", "after dark +", 1000),
    makeLevelTitle("hush_hour", "hush hour +", 1200),
    makeLevelTitle("socialite", "quiet soul +", 1400, {"socialite +", "socialite"}),
    makeLevelTitle("stillwater", "stillwater !", 1600),
    makeLevelTitle("spotlight", "soft glow !", 1800, {"spotlight !", "spotlight"}),
    makeLevelTitle("passing_lights", "passing lights !", 2100),
    makeLevelTitle("trendsetter", "dreamwalker !", 2400, {"trendsetter !", "trendsetter"}),
    makeLevelTitle("deep_end", "deep end !", 2700),
    makeLevelTitle("downtown", "blue hour !", 3000, {"downtown !", "downtown"}),
    makeLevelTitle("night_bloom", "night bloom ~", 3400),
    makeLevelTitle("runway", "moonlit ~", 3800, {"runway ~", "runway"}),
    makeLevelTitle("blackglass", "blackglass +", 4300),
    makeLevelTitle("icon", "ghostlight !", 5000, {"icon !", "icon"}),
    makeLevelTitle("cathedral_hush", "cathedral hush !", 5750),
    makeLevelTitle("city_icon", "hollow star +", 6500, {"city icon +", "city icon"}),
    makeLevelTitle("last_light", "last light !", 7500),
    makeLevelTitle("neon_soul", "neon soul +", 8500),
    makeLevelTitle("superstar", "silver night !", 12000, {"superstar !", "superstar"}),
    makeLevelTitle("prismatic", "prismatic ~", 18000),
    makeLevelTitle("divine", "divine !", 30000),
    makeLevelTitle("immortal", "immortal !", 50000),
    makeLevelTitle("legend", "legend !", 100000),

    makeGamePassTitle("goobert", "sleepwalker ~", {"goobert ~", "goobert"}),
    makeGamePassTitle("doobert", "lost soul ~", {"doobert ~", "doobert"}),
    makeGamePassTitle("main_character", "drifter !", {"main character !", "main character"}),
    makeGamePassTitle("after_hours", "after hours +"),
    makeGamePassTitle("starlight", "starlight *"),
    makeGamePassTitle("royalty", "velvet sky !", {"royalty !", "royalty"}),
    makeGamePassTitle("angel", "angel ~"),
    makeGamePassTitle("devil", "fallen light +", {"devil +", "devil"}),
    makeGamePassTitle("velvet", "velvet ~"),
    makeGamePassTitle("muse", "muse ~"),
    makeGamePassTitle("black_tie", "black tie !"),
    makeGamePassTitle("first_edition", "first edition +"),
    makeGamePassTitle("private_heaven", "private heaven ~"),
    makeGamePassTitle("marble_saint", "marble saint !"),

    makeShopTitle("soft_echo", "soft echo", 120),
    makeShopTitle("wallflower", "wallflower", 180),
    makeShopTitle("night_shift", "night shift", 240),
    makeShopTitle("rainkissed", "rainkissed", 320),
    makeShopTitle("static_heart", "static heart", 400),
    makeShopTitle("low_tide", "low tide", 480),
    makeShopTitle("afterglow", "afterglow", 650),
    makeShopTitle("hush_club", "hush club", 800),
    makeShopTitle("half_asleep", "half asleep", 250),
    makeShopTitle("paper_moon", "paper moon", 250),
    makeShopTitle("low_voice", "low voice", 325),
    makeShopTitle("closed_eyes", "closed eyes", 325),
    makeShopTitle("still_here", "still here", 400),
    makeShopTitle("back_row", "back row", 400),
    makeShopTitle("side_street", "side street", 550),
    makeShopTitle("late_train", "late train", 550),
    makeShopTitle("faint_signal", "faint signal", 700),
    makeShopTitle("empty_room", "empty room", 700),
    makeShopTitle("headlights", "headlights", 900),
    makeShopTitle("cornerlight", "cornerlight", 900),
    makeShopTitle("cold_hands", "cold hands", 1200),
    makeShopTitle("slow_dance", "slow dance", 1200),
    makeShopTitle("house_favorite", "house favorite", 1600),
    makeShopTitle("last_letter", "last letter", 1600),
    makeShopTitle("private_hour", "private hour", 2200),
    makeShopTitle("hotel_lobby", "hotel lobby", 2200),
    makeShopTitle("guest_list", "guest list", 3000),
    makeShopTitle("upper_room", "upper room", 3400),
    makeShopTitle("private_room", "private room", 4000),
    makeShopTitle("marble_room", "marble room", 4800),
    makeShopTitle("front_row", "front row", 5600),
    makeShopTitle("heirloom", "heirloom", 6500),

    makeSpecialTitle("developer_plus", "developer +", "SpecialTitle_developer_plus"),
    makeSpecialTitle("builder_plus", "builder +", "SpecialTitle_builder_plus"),
}

local titleEffectDefinitions = {
    goobert = makeEffect("shimmer", {
        color = Color3.fromRGB(162, 186, 104),
        secondaryColor = Color3.fromRGB(86, 106, 54),
        accentColor = Color3.fromRGB(198, 210, 167),
        transparency = 0.2,
        strokeColor = Color3.fromRGB(52, 62, 34),
        strokeTransparency = 0.94,
        speed = 6.9,
        rotation = -8,
        pause = 0.76,
    }),
    doobert = makeEffect("shimmer", {
        color = Color3.fromRGB(134, 188, 198),
        secondaryColor = Color3.fromRGB(67, 110, 119),
        accentColor = Color3.fromRGB(190, 215, 220),
        transparency = 0.2,
        strokeColor = Color3.fromRGB(44, 73, 79),
        strokeTransparency = 0.94,
        speed = 6.8,
        rotation = -8,
        pause = 0.74,
    }),
    main_character = makeEffect("shimmer", {
        color = Color3.fromRGB(212, 192, 154),
        secondaryColor = Color3.fromRGB(131, 109, 75),
        accentColor = Color3.fromRGB(228, 213, 187),
        transparency = 0.19,
        strokeColor = Color3.fromRGB(79, 64, 42),
        strokeTransparency = 0.93,
        speed = 6.7,
        rotation = -10,
        pause = 0.68,
    }),
    after_hours = makeEffect("shimmer", {
        color = Color3.fromRGB(123, 127, 171),
        secondaryColor = Color3.fromRGB(62, 66, 101),
        accentColor = Color3.fromRGB(164, 170, 205),
        transparency = 0.2,
        strokeColor = Color3.fromRGB(39, 42, 66),
        strokeTransparency = 0.94,
        speed = 7,
        rotation = -9,
        pause = 0.8,
    }),
    starlight = makeEffect("shimmer", {
        color = Color3.fromRGB(203, 217, 227),
        secondaryColor = Color3.fromRGB(122, 141, 159),
        accentColor = Color3.fromRGB(228, 235, 240),
        transparency = 0.19,
        strokeColor = Color3.fromRGB(72, 86, 99),
        strokeTransparency = 0.94,
        speed = 6.6,
        rotation = -9,
        pause = 0.69,
    }),
    royalty = makeEffect("shimmer", {
        color = Color3.fromRGB(150, 127, 186),
        secondaryColor = Color3.fromRGB(84, 65, 111),
        accentColor = Color3.fromRGB(191, 176, 208),
        transparency = 0.2,
        strokeColor = Color3.fromRGB(58, 45, 77),
        strokeTransparency = 0.94,
        speed = 6.8,
        rotation = -11,
        pause = 0.76,
    }),
    angel = makeEffect("shimmer", {
        color = Color3.fromRGB(223, 221, 214),
        secondaryColor = Color3.fromRGB(151, 147, 138),
        accentColor = Color3.fromRGB(239, 237, 232),
        transparency = 0.19,
        strokeColor = Color3.fromRGB(95, 91, 84),
        strokeTransparency = 0.94,
        speed = 6.6,
        rotation = -9,
        pause = 0.7,
    }),
    devil = makeEffect("shimmer", {
        color = Color3.fromRGB(168, 95, 101),
        secondaryColor = Color3.fromRGB(97, 44, 50),
        accentColor = Color3.fromRGB(200, 148, 152),
        transparency = 0.2,
        strokeColor = Color3.fromRGB(62, 29, 34),
        strokeTransparency = 0.94,
        speed = 6.9,
        rotation = -10,
        pause = 0.77,
    }),
    velvet = makeEffect("shimmer", {
        color = Color3.fromRGB(130, 77, 91),
        secondaryColor = Color3.fromRGB(74, 38, 48),
        accentColor = Color3.fromRGB(169, 125, 137),
        transparency = 0.2,
        strokeColor = Color3.fromRGB(49, 24, 31),
        strokeTransparency = 0.94,
        speed = 6.8,
        rotation = -11,
        pause = 0.79,
    }),
    muse = makeEffect("shimmer", {
        color = Color3.fromRGB(198, 168, 158),
        secondaryColor = Color3.fromRGB(126, 94, 84),
        accentColor = Color3.fromRGB(221, 198, 190),
        transparency = 0.19,
        strokeColor = Color3.fromRGB(78, 58, 51),
        strokeTransparency = 0.93,
        speed = 6.7,
        rotation = -9,
        pause = 0.68,
    }),
    black_tie = makeEffect("shimmer", {
        color = Color3.fromRGB(196, 200, 207),
        secondaryColor = Color3.fromRGB(123, 127, 135),
        accentColor = Color3.fromRGB(228, 231, 236),
        transparency = 0.19,
        strokeColor = Color3.fromRGB(74, 78, 84),
        strokeTransparency = 0.93,
        speed = 6.6,
        rotation = -12,
        pause = 0.66,
    }),
    first_edition = makeEffect("shimmer", {
        color = Color3.fromRGB(184, 160, 112),
        secondaryColor = Color3.fromRGB(114, 91, 52),
        accentColor = Color3.fromRGB(209, 189, 154),
        transparency = 0.19,
        strokeColor = Color3.fromRGB(69, 54, 32),
        strokeTransparency = 0.93,
        speed = 6.7,
        rotation = -10,
        pause = 0.68,
    }),
    private_heaven = makeEffect("shimmer", {
        color = Color3.fromRGB(218, 199, 202),
        secondaryColor = Color3.fromRGB(149, 127, 132),
        accentColor = Color3.fromRGB(233, 223, 224),
        transparency = 0.19,
        strokeColor = Color3.fromRGB(93, 77, 81),
        strokeTransparency = 0.93,
        speed = 6.6,
        rotation = -8,
        pause = 0.69,
    }),
    marble_saint = makeEffect("shimmer", {
        color = Color3.fromRGB(220, 218, 211),
        secondaryColor = Color3.fromRGB(149, 146, 137),
        accentColor = Color3.fromRGB(236, 234, 229),
        transparency = 0.19,
        strokeColor = Color3.fromRGB(95, 92, 85),
        strokeTransparency = 0.93,
        speed = 6.6,
        rotation = -9,
        pause = 0.68,
    }),
    neon_soul = makeEffect("shimmer", {
        color = Color3.fromRGB(171, 205, 225),
        secondaryColor = Color3.fromRGB(86, 115, 145),
        accentColor = Color3.fromRGB(226, 238, 247),
        transparency = 0.095,
        strokeColor = Color3.fromRGB(43, 58, 78),
        strokeTransparency = 0.83,
        speed = 4.2,
        rotation = -10,
        pause = 0.27,
    }),
    silver_night = makeEffect("shimmer", {
        color = Color3.fromRGB(214, 220, 228),
        secondaryColor = Color3.fromRGB(126, 134, 147),
        accentColor = Color3.fromRGB(244, 246, 249),
        transparency = 0.085,
        strokeColor = Color3.fromRGB(60, 66, 76),
        strokeTransparency = 0.81,
        speed = 4.1,
        rotation = -13,
        pause = 0.26,
    }),
    prismatic = makeEffect("shimmer", {
        color = Color3.fromRGB(206, 204, 220),
        secondaryColor = Color3.fromRGB(132, 129, 154),
        accentColor = Color3.fromRGB(234, 236, 245),
        transparency = 0.102,
        strokeColor = Color3.fromRGB(67, 66, 82),
        strokeTransparency = 0.83,
        speed = 4.7,
        rotation = -8,
        pause = 0.32,
    }),
    divine = makeEffect("shimmer", {
        color = Color3.fromRGB(234, 230, 216),
        secondaryColor = Color3.fromRGB(151, 138, 104),
        accentColor = Color3.fromRGB(246, 240, 224),
        transparency = 0.076,
        strokeColor = Color3.fromRGB(86, 75, 49),
        strokeTransparency = 0.79,
        speed = 4.35,
        rotation = -11,
        pause = 0.3,
    }),
    immortal = makeEffect("shimmer", {
        color = Color3.fromRGB(205, 216, 230),
        secondaryColor = Color3.fromRGB(116, 129, 149),
        accentColor = Color3.fromRGB(237, 242, 247),
        transparency = 0.085,
        strokeColor = Color3.fromRGB(59, 70, 86),
        strokeTransparency = 0.8,
        speed = 4.6,
        rotation = -9,
        pause = 0.35,
    }),
    legend = makeEffect("shimmer", {
        color = Color3.fromRGB(220, 214, 195),
        secondaryColor = Color3.fromRGB(146, 136, 109),
        accentColor = Color3.fromRGB(245, 238, 221),
        transparency = 0.085,
        strokeColor = Color3.fromRGB(80, 71, 47),
        strokeTransparency = 0.8,
        speed = 4.5,
        rotation = -14,
        pause = 0.34,
    }),
    developer_plus = makeEffect("shimmer", {
        color = Color3.fromRGB(198, 227, 236),
        secondaryColor = Color3.fromRGB(108, 140, 153),
        accentColor = Color3.fromRGB(233, 244, 247),
        transparency = 0.095,
        strokeColor = Color3.fromRGB(63, 92, 104),
        strokeTransparency = 0.82,
        speed = 4.3,
        rotation = -9,
        pause = 0.29,
    }),
    heirloom = makeEffect("shimmer", {
        color = Color3.fromRGB(223, 213, 192),
        secondaryColor = Color3.fromRGB(148, 130, 97),
        accentColor = Color3.fromRGB(244, 235, 214),
        transparency = 0.11,
        strokeColor = Color3.fromRGB(86, 72, 45),
        strokeTransparency = 0.86,
        speed = 5.1,
        rotation = -12,
        pause = 0.39,
    }),
    front_row = makeEffect("shimmer", {
        color = Color3.fromRGB(217, 205, 190),
        secondaryColor = Color3.fromRGB(142, 122, 95),
        accentColor = Color3.fromRGB(241, 230, 216),
        transparency = 0.11,
        strokeColor = Color3.fromRGB(82, 67, 47),
        strokeTransparency = 0.86,
        speed = 4.9,
        rotation = -11,
        pause = 0.35,
    }),
    marble_room = makeEffect("shimmer", {
        color = Color3.fromRGB(226, 227, 229),
        secondaryColor = Color3.fromRGB(144, 145, 151),
        accentColor = Color3.fromRGB(244, 244, 246),
        transparency = 0.1,
        strokeColor = Color3.fromRGB(88, 89, 97),
        strokeTransparency = 0.85,
        speed = 5,
        rotation = -10,
        pause = 0.37,
    }),
}


TitleConfig.SpecialAssignments = {
    developer_plus = {
        userIds = {1132193781},
        attributeName = "SpecialTitle_developer_plus",
    },
    builder_plus = {
        userIds = {},
        attributeName = "SpecialTitle_builder_plus",
    },
}

local titlesById = {}
local normalizedLookups = {}

local function normalizeLookupKey(key)
    if type(key) ~= "string" then
        return nil
    end

    local normalized = string.lower(key)
    normalized = string.gsub(normalized, "^%s*(.-)%s*$", "%1")
    normalized = string.gsub(normalized, "%s+", " ")
    if normalized == "" then
        return nil
    end

    return normalized
end

local function slugifyKey(key)
    local normalized = normalizeLookupKey(key)
    if not normalized then
        return nil
    end

    normalized = string.gsub(normalized, "[%*%!%+%~]", "")
    normalized = string.gsub(normalized, "[^%w%s_%-]", "")
    normalized = string.gsub(normalized, "[%s%-]+", "_")
    normalized = string.gsub(normalized, "_+", "_")
    normalized = string.gsub(normalized, "^_*(.-)_*$", "%1")

    if normalized == "" then
        return nil
    end

    return normalized
end

local function addLookupKey(rawKey, resolvedId)
    local normalizedKey = normalizeLookupKey(rawKey)
    if normalizedKey then
        normalizedLookups[normalizedKey] = resolvedId
    end

    local slugKey = slugifyKey(rawKey)
    if slugKey then
        normalizedLookups[slugKey] = resolvedId
    end
end

for index, title in ipairs(orderedTitles) do
    title.sortOrder = index
    titlesById[title.id] = title

    addLookupKey(title.id, title.id)
    addLookupKey(title.displayName, title.id)

    for _, alias in ipairs(title.legacyAliases or {}) do
        addLookupKey(alias, title.id)
    end
end

local function resolveNormalizedTitleId(titleId)
    local normalizedKey = normalizeLookupKey(titleId)
    if not normalizedKey then
        return nil
    end

    local resolvedId = normalizedLookups[normalizedKey]
    if resolvedId and titlesById[resolvedId] then
        return resolvedId
    end

    local slugKey = slugifyKey(titleId)
    resolvedId = slugKey and normalizedLookups[slugKey] or nil
    if resolvedId and titlesById[resolvedId] then
        return resolvedId
    end

    return nil
end

for rawTitleId, effectDefinition in pairs(titleEffectDefinitions) do
    local resolvedId = resolveNormalizedTitleId(rawTitleId)
    if resolvedId and titlesById[resolvedId] then
        titlesById[resolvedId].effect = makeEffect(effectDefinition.type, effectDefinition)
    end
end

function TitleConfig.GetOrderedTitles()
    return orderedTitles
end

function TitleConfig.NormalizeTitleId(titleId)
    return resolveNormalizedTitleId(titleId)
end

function TitleConfig.GetTitleById(titleId)
    local normalizedId = TitleConfig.NormalizeTitleId(titleId)
    return normalizedId and titlesById[normalizedId] or nil
end

function TitleConfig.GetDisplayName(titleId)
    local title = TitleConfig.GetTitleById(titleId) or titlesById[TitleConfig.DEFAULT_TITLE_ID]
    return title and title.displayName or "newcomer"
end

function TitleConfig.GetRequirementText(titleOrId)
    local title = type(titleOrId) == "table" and titleOrId or TitleConfig.GetTitleById(titleOrId)
    return title and title.requirementText or ""
end

function TitleConfig.GetCategory(titleOrId)
    local title = type(titleOrId) == "table" and titleOrId or TitleConfig.GetTitleById(titleOrId)
    local category = title and title.category or nil
    return VALID_CATEGORIES[category] and category or nil
end

function TitleConfig.GetEffect(titleOrId)
    local title = type(titleOrId) == "table" and titleOrId or TitleConfig.GetTitleById(titleOrId)
    local effect = title and title.effect or nil
    if type(effect) ~= "table" or not VALID_EFFECT_TYPES[effect.type] then
        return NONE_EFFECT
    end
    return makeEffect(effect.type, effect)
end

function TitleConfig.GetBestLevelTitleId(level)
    local numericLevel = tonumber(level) or 0
    local bestTitleId = TitleConfig.DEFAULT_TITLE_ID

    for _, title in ipairs(orderedTitles) do
        if title.category == "level" and numericLevel >= (title.requiredLevel or 0) then
            bestTitleId = title.id
        end
    end

    return bestTitleId
end

function TitleConfig.PlayerHasSpecialAccess(player, titleId)
    local normalizedId = TitleConfig.NormalizeTitleId(titleId)
    local assignment = normalizedId and TitleConfig.SpecialAssignments[normalizedId] or nil
    if not assignment or not player then
        return false
    end

    if assignment.attributeName and player:GetAttribute(assignment.attributeName) == true then
        return true
    end

    for _, allowedUserId in ipairs(assignment.userIds or {}) do
        if allowedUserId == player.UserId then
            return true
        end
    end

    return false
end

return TitleConfig
