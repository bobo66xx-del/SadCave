-- Modern TextChatService Handler
-- This script handles custom chat styling using the modern TextChatService API

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local CONFIG = script.Parent:FindFirstChild("Custom Chat Script")
local USERS_FOLDER = CONFIG and CONFIG:FindFirstChild("Users") or nil
local FRIENDS_FOLDER = CONFIG and CONFIG:FindFirstChild("AllUserFriends") or nil
local GAMEPASSES_FOLDER = CONFIG and CONFIG:FindFirstChild("Gamepasses") or nil

local playerChatData = {}

local function getChatData(player)
    if playerChatData[player.UserId] then
        return playerChatData[player.UserId]
    end

    local data = {
        nameColor = nil,
        chatColor = nil,
        tags = {},
    }

    if USERS_FOLDER then
        for _, userConfig in USERS_FOLDER:GetChildren() do
            if userConfig:IsA("NumberValue") and userConfig.Value == player.UserId then
                local nameColor = userConfig:FindFirstChild("NameColor")
                local chatColor = userConfig:FindFirstChild("ChatColor")
                local tag = userConfig:FindFirstChild("Tag")

                if nameColor and nameColor:FindFirstChild("Enabled") and nameColor.Enabled.Value then
                    data.nameColor = nameColor.Value
                end
                if chatColor and chatColor:FindFirstChild("Enabled") and chatColor.Enabled.Value then
                    data.chatColor = chatColor.Value
                end
                if tag and tag:FindFirstChild("Enabled") and tag.Enabled.Value then
                    local tagColor = tag:FindFirstChild("Color")
                    table.insert(data.tags, {
                        TagText = tag.Value,
                        TagColor = tagColor and tagColor.Value or Color3.new(1, 1, 1),
                    })
                end
            end
        end
    end

    if FRIENDS_FOLDER then
        for _, friendConfig in FRIENDS_FOLDER:GetChildren() do
            if friendConfig:IsA("NumberValue") and friendConfig.Value ~= 0 and player:IsFriendsWith(friendConfig.Value) then
                local nameColor = friendConfig:FindFirstChild("NameColor")
                local chatColor = friendConfig:FindFirstChild("ChatColor")
                local tag = friendConfig:FindFirstChild("Tag")

                if nameColor and nameColor:FindFirstChild("Enabled") and nameColor.Enabled.Value then
                    data.nameColor = nameColor.Value
                end
                if chatColor and chatColor:FindFirstChild("Enabled") and chatColor.Enabled.Value then
                    data.chatColor = chatColor.Value
                end
                if tag and tag:FindFirstChild("Enabled") and tag.Enabled.Value then
                    local tagColor = tag:FindFirstChild("Color")
                    table.insert(data.tags, {
                        TagText = tag.Value,
                        TagColor = tagColor and tagColor.Value or Color3.new(1, 1, 1),
                    })
                end
            end
        end
    end

    if GAMEPASSES_FOLDER then
        for _, gamepassConfig in GAMEPASSES_FOLDER:GetChildren() do
            if gamepassConfig:IsA("NumberValue") and gamepassConfig.Value ~= 0 then
                local success, hasGamepass = pcall(function()
                    return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassConfig.Value)
                end)

                if success and hasGamepass then
                    local nameColor = gamepassConfig:FindFirstChild("NameColor")
                    local chatColor = gamepassConfig:FindFirstChild("ChatColor")
                    local tag = gamepassConfig:FindFirstChild("Tag")

                    if nameColor and nameColor:FindFirstChild("Enabled") and nameColor.Enabled.Value then
                        data.nameColor = nameColor.Value
                    end
                    if chatColor and chatColor:FindFirstChild("Enabled") and chatColor.Enabled.Value then
                        data.chatColor = chatColor.Value
                    end
                    if tag and tag:FindFirstChild("Enabled") and tag.Enabled.Value then
                        local tagColor = tag:FindFirstChild("Color")
                        table.insert(data.tags, {
                            TagText = tag.Value,
                            TagColor = tagColor and tagColor.Value or Color3.new(1, 1, 1),
                        })
                    end
                end
            end
        end
    end

    playerChatData[player.UserId] = data
    return data
end

local function onIncomingMessage(textChatMessage, _textChannel)
    if not textChatMessage.TextSource then
        return
    end

    local player = Players:GetPlayerByUserId(textChatMessage.TextSource.UserId)
    if not player then
        return
    end

    local chatData = getChatData(player)

    if chatData.nameColor then
        textChatMessage.PrefixText = string.format(
            "<font color=\"rgb(%d,%d,%d)\">%s</font>",
            math.floor(chatData.nameColor.R * 255),
            math.floor(chatData.nameColor.G * 255),
            math.floor(chatData.nameColor.B * 255),
            textChatMessage.PrefixText
        )
    end

    if chatData.chatColor then
        textChatMessage.Text = string.format(
            "<font color=\"rgb(%d,%d,%d)\">%s</font>",
            math.floor(chatData.chatColor.R * 255),
            math.floor(chatData.chatColor.G * 255),
            math.floor(chatData.chatColor.B * 255),
            textChatMessage.Text
        )
    end

    if #chatData.tags > 0 then
        local tagString = ""
        for _, tag in ipairs(chatData.tags) do
            tagString = tagString .. string.format(
                "<font color=\"rgb(%d,%d,%d)\">[%s]</font> ",
                math.floor(tag.TagColor.R * 255),
                math.floor(tag.TagColor.G * 255),
                math.floor(tag.TagColor.B * 255),
                tag.TagText
            )
        end
        textChatMessage.PrefixText = tagString .. textChatMessage.PrefixText
    end
end

local function setupChannel(channel)
    if channel:IsA("TextChannel") then
        channel.OnIncomingMessage = onIncomingMessage
    end
end

for _, child in ipairs(TextChatService:GetChildren()) do
    setupChannel(child)
end

TextChatService.ChildAdded:Connect(setupChannel)

Players.PlayerRemoving:Connect(function(player)
    playerChatData[player.UserId] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    getChatData(player)
end

print("[TextChatService] Modern chat system initialized")
