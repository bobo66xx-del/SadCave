local ShopCatalog = {}

local orderedItems = {
    {
        id = "soft_echo",
        category = "title",
        displayName = "soft echo",
        description = "A soft-spoken title for quiet regulars.",
        priceShards = 120,
        linkedTitleId = "soft_echo",
        sortOrder = 1,
        visible = true,
    },
    {
        id = "wallflower",
        category = "title",
        displayName = "wallflower",
        description = "A shy title that fits Sad Cave's mood.",
        priceShards = 180,
        linkedTitleId = "wallflower",
        sortOrder = 2,
        visible = true,
    },
    {
        id = "night_shift",
        category = "title",
        displayName = "night shift",
        description = "For the players who stay a little later.",
        priceShards = 240,
        linkedTitleId = "night_shift",
        sortOrder = 3,
        visible = true,
    },
    {
        id = "rainkissed",
        category = "title",
        displayName = "rainkissed",
        description = "A moody title with a softer edge.",
        priceShards = 320,
        linkedTitleId = "rainkissed",
        sortOrder = 4,
        visible = true,
    },
    {
        id = "static_heart",
        category = "title",
        displayName = "static heart",
        description = "For players who linger in the glow.",
        priceShards = 400,
        linkedTitleId = "static_heart",
        sortOrder = 5,
        visible = true,
    },
    {
        id = "low_tide",
        category = "title",
        displayName = "low tide",
        description = "A slower title for the late crowd.",
        priceShards = 480,
        linkedTitleId = "low_tide",
        sortOrder = 6,
        visible = true,
    },
    {
        id = "afterglow",
        category = "title",
        displayName = "afterglow",
        description = "A brighter title for dedicated regulars.",
        priceShards = 650,
        linkedTitleId = "afterglow",
        sortOrder = 7,
        visible = true,
    },
    {
        id = "hush_club",
        category = "title",
        displayName = "hush club",
        description = "A premium title for the true cave dwellers.",
        priceShards = 800,
        linkedTitleId = "hush_club",
        sortOrder = 8,
        visible = true,
    },
    {
        id = "half_asleep",
        category = "title",
        displayName = "half asleep",
        description = "A sleepy title for players who stay a little longer.",
        priceShards = 250,
        linkedTitleId = "half_asleep",
        sortOrder = 9,
        visible = true,
    },
    {
        id = "paper_moon",
        category = "title",
        displayName = "paper moon",
        description = "Soft and delicate with a late-night glow.",
        priceShards = 250,
        linkedTitleId = "paper_moon",
        sortOrder = 10,
        visible = true,
    },
    {
        id = "low_voice",
        category = "title",
        displayName = "low voice",
        description = "Quiet, close, and easy to wear.",
        priceShards = 325,
        linkedTitleId = "low_voice",
        sortOrder = 11,
        visible = true,
    },
    {
        id = "closed_eyes",
        category = "title",
        displayName = "closed eyes",
        description = "A calm title with a distant edge.",
        priceShards = 325,
        linkedTitleId = "closed_eyes",
        sortOrder = 12,
        visible = true,
    },
    {
        id = "still_here",
        category = "title",
        displayName = "still here",
        description = "Simple, understated, and quietly loyal.",
        priceShards = 400,
        linkedTitleId = "still_here",
        sortOrder = 13,
        visible = true,
    },
    {
        id = "back_row",
        category = "title",
        displayName = "back row",
        description = "For players who prefer to watch from the dark.",
        priceShards = 400,
        linkedTitleId = "back_row",
        sortOrder = 14,
        visible = true,
    },
    {
        id = "side_street",
        category = "title",
        displayName = "side street",
        description = "A city-night title with a cooler mood.",
        priceShards = 550,
        linkedTitleId = "side_street",
        sortOrder = 15,
        visible = true,
    },
    {
        id = "late_train",
        category = "title",
        displayName = "late train",
        description = "For the players catching the last ride home.",
        priceShards = 550,
        linkedTitleId = "late_train",
        sortOrder = 16,
        visible = true,
    },
    {
        id = "faint_signal",
        category = "title",
        displayName = "faint signal",
        description = "A low-glow title that feels almost out of reach.",
        priceShards = 700,
        linkedTitleId = "faint_signal",
        sortOrder = 17,
        visible = true,
    },
    {
        id = "empty_room",
        category = "title",
        displayName = "empty room",
        description = "Quiet and cinematic in the right way.",
        priceShards = 700,
        linkedTitleId = "empty_room",
        sortOrder = 18,
        visible = true,
    },
    {
        id = "headlights",
        category = "title",
        displayName = "headlights",
        description = "A sharper title for players with presence.",
        priceShards = 900,
        linkedTitleId = "headlights",
        sortOrder = 19,
        visible = true,
    },
    {
        id = "cornerlight",
        category = "title",
        displayName = "cornerlight",
        description = "A city-lit title with a clean silhouette.",
        priceShards = 900,
        linkedTitleId = "cornerlight",
        sortOrder = 20,
        visible = true,
    },
    {
        id = "cold_hands",
        category = "title",
        displayName = "cold hands",
        description = "Soft, intimate, and a little distant.",
        priceShards = 1200,
        linkedTitleId = "cold_hands",
        sortOrder = 21,
        visible = true,
    },
    {
        id = "slow_dance",
        category = "title",
        displayName = "slow dance",
        description = "A closer title with a softer flex.",
        priceShards = 1200,
        linkedTitleId = "slow_dance",
        sortOrder = 22,
        visible = true,
    },
    {
        id = "house_favorite",
        category = "title",
        displayName = "house favorite",
        description = "Feels known, wanted, and invited back.",
        priceShards = 1600,
        linkedTitleId = "house_favorite",
        sortOrder = 23,
        visible = true,
    },
    {
        id = "last_letter",
        category = "title",
        displayName = "last letter",
        description = "Tender, polished, and slightly tragic.",
        priceShards = 1600,
        linkedTitleId = "last_letter",
        sortOrder = 24,
        visible = true,
    },
    {
        id = "private_hour",
        category = "title",
        displayName = "private hour",
        description = "An elevated title with a private feel.",
        priceShards = 2200,
        linkedTitleId = "private_hour",
        sortOrder = 25,
        visible = true,
    },
    {
        id = "hotel_lobby",
        category = "title",
        displayName = "hotel lobby",
        description = "Smooth, social, and deliberately expensive.",
        priceShards = 2200,
        linkedTitleId = "hotel_lobby",
        sortOrder = 26,
        visible = true,
    },
    {
        id = "guest_list",
        category = "title",
        displayName = "guest list",
        description = "A clear flex for players with taste.",
        priceShards = 3000,
        linkedTitleId = "guest_list",
        sortOrder = 27,
        visible = true,
    },
    {
        id = "upper_room",
        category = "title",
        displayName = "upper room",
        description = "Private and polished with status.",
        priceShards = 3400,
        linkedTitleId = "upper_room",
        sortOrder = 28,
        visible = true,
    },
    {
        id = "private_room",
        category = "title",
        displayName = "private room",
        description = "An exclusive title with real presence.",
        priceShards = 4000,
        linkedTitleId = "private_room",
        sortOrder = 29,
        visible = true,
    },
    {
        id = "marble_room",
        category = "title",
        displayName = "marble room",
        description = "Cold, expensive, and hard to ignore.",
        priceShards = 4800,
        linkedTitleId = "marble_room",
        sortOrder = 30,
        visible = true,
    },
    {
        id = "front_row",
        category = "title",
        displayName = "front row",
        description = "For players who want the attention without the noise.",
        priceShards = 5600,
        linkedTitleId = "front_row",
        sortOrder = 31,
        visible = true,
    },
    {
        id = "heirloom",
        category = "title",
        displayName = "heirloom",
        description = "A prestige title that feels rare and lasting.",
        priceShards = 6500,
        linkedTitleId = "heirloom",
        sortOrder = 32,
        visible = true,
    },
}

local itemsById = {}
local itemsByTitleId = {}

for index, item in ipairs(orderedItems) do
    item.sortOrder = item.sortOrder or index
    itemsById[item.id] = item
    if item.linkedTitleId then
        itemsByTitleId[item.linkedTitleId] = item
    end
end

function ShopCatalog.GetOrderedItems()
    return orderedItems
end

function ShopCatalog.GetItemById(itemId)
    if type(itemId) ~= "string" then
        return nil
    end
    return itemsById[itemId]
end

function ShopCatalog.GetItemForTitleId(titleId)
    if type(titleId) ~= "string" then
        return nil
    end
    return itemsByTitleId[titleId]
end

function ShopCatalog.IsPurchasable(itemId)
    local item = ShopCatalog.GetItemById(itemId)
    return item ~= nil and item.visible ~= false
end

return ShopCatalog
