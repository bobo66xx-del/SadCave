local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")

local TitleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))
local nametagTemplate = ReplicatedStorage:FindFirstChild("NameTag")
if not nametagTemplate then
    warn("[NameTagScript] ReplicatedStorage.NameTag missing")
    return
end

local templateLowerText = nametagTemplate:FindFirstChild("LowerText", true)
if not templateLowerText then
    warn("[NameTagScript] ReplicatedStorage.NameTag.LowerText missing")
    return
end

local rebuildEvent = ReplicatedStorage:FindFirstChild("RebuildOverheadTags")
if not rebuildEvent then
    rebuildEvent = Instance.new("BindableEvent")
    rebuildEvent.Name = "RebuildOverheadTags"
    rebuildEvent.Parent = ReplicatedStorage
end

local tagToggle = ReplicatedStorage:FindFirstChild("OverheadTagsEnabled")
if not tagToggle then
    tagToggle = Instance.new("BoolValue")
    tagToggle.Name = "OverheadTagsEnabled"
    tagToggle.Value = true
    tagToggle.Parent = ReplicatedStorage
end

local NAMETAG_NAME = "NameTag"
local MIN_NAMETAG_OFFSET_Y = 1.75
local NAMETAG_CLEARANCE_Y = 0.2
local BUBBLE_CHAT_VERTICAL_OFFSET = 1.5
local TITLE_EFFECT_PREFIX = "TitleEffect_"
local TITLE_EFFECT_ATTRIBUTE = "AppliedTitleEffectKey"
local BASE_TITLE_STYLE = {
    TextColor3 = templateLowerText.TextColor3,
    TextTransparency = templateLowerText.TextTransparency,
    TextStrokeColor3 = templateLowerText.TextStrokeColor3,
    TextStrokeTransparency = templateLowerText.TextStrokeTransparency,
    Rotation = templateLowerText.Rotation,
    Position = templateLowerText.Position,
    Size = templateLowerText.Size,
    RichText = templateLowerText.RichText,
}

local playerStates = {}

local function getPlayerState(player)
    local state = playerStates[player]
    if not state then
        state = {
            levelConnections = {},
            equippedValue = nil,
            equippedConnection = nil,
            refreshVersion = 0,
            titleEffectToken = 0,
        }
        playerStates[player] = state
    end
    return state
end

local function ensureLegacyFolder()
    local folder = workspace:FindFirstChild("NameTags")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "NameTags"
        folder.Parent = workspace
    end
    return folder
end

ensureLegacyFolder()

local bubbleChatConfiguration = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration") or TextChatService:FindFirstChild("BubbleChatConfiguration")
if bubbleChatConfiguration then
    bubbleChatConfiguration.VerticalStudsOffset = BUBBLE_CHAT_VERTICAL_OFFSET
end

local function clampNumber(value, minimum, maximum, fallback)
    local numericValue = tonumber(value)
    if numericValue == nil then
        return fallback
    end
    return math.clamp(numericValue, minimum, maximum)
end

local function lerpColor(colorA, colorB, alpha)
    return Color3.new(
        colorA.R + ((colorB.R - colorA.R) * alpha),
        colorA.G + ((colorB.G - colorA.G) * alpha),
        colorA.B + ((colorB.B - colorA.B) * alpha)
    )
end

local function getDisplayName(player)
    if player.DisplayName and player.DisplayName ~= "" then
        return player.DisplayName
    end
    return player.Name
end

local function getLevel(player)
    local levelValue = player:FindFirstChild("Level")
    if levelValue and levelValue:IsA("IntValue") then
        return levelValue.Value
    end

    local leaderstats = player:FindFirstChild("leaderstats")
    local leaderstatsLevel = leaderstats and leaderstats:FindFirstChild("Level")
    if leaderstatsLevel and leaderstatsLevel:IsA("IntValue") then
        return leaderstatsLevel.Value
    end

    return 0
end

local function getEquippedTitleId(player)
    local equippedValue = player:FindFirstChild("EquippedTitle")
    local titleId = equippedValue and equippedValue:IsA("StringValue") and equippedValue.Value or TitleConfig.DEFAULT_TITLE_ID
    return TitleConfig.NormalizeTitleId(titleId) or TitleConfig.DEFAULT_TITLE_ID
end

local function getEquippedTitleText(player)
    return TitleConfig.GetDisplayName(getEquippedTitleId(player))
end

local function ensurePlayerValueFromTemplate(player, templateName, className)
    local template = ReplicatedStorage:FindFirstChild(templateName)
    if not template or template.ClassName ~= className then
        return nil
    end

    local existing = player:FindFirstChild(templateName)
    if existing and existing.ClassName ~= className then
        existing:Destroy()
        existing = nil
    end

    if not existing then
        existing = template:Clone()
        existing.Name = templateName
        existing.Parent = player
    end

    return existing
end

local function syncPlayerDisplayNameValue(player)
    local displayNameValue = ensurePlayerValueFromTemplate(player, "NameValue", "StringValue")
    if displayNameValue then
        displayNameValue.Value = getDisplayName(player)
    end
end

local function ensureRunValue(player)
    ensurePlayerValueFromTemplate(player, "RunValue", "NumberValue")
end

local function getPartTopY(part)
    local extentsY = part.ExtentsSize.Y
    if extentsY <= 0 then
        extentsY = part.Size.Y
    end
    return part.Position.Y + (extentsY * 0.5)
end

local function getHeadStackTopY(character, head)
    local highestY = getPartTopY(head)

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                local attachedToHead = false
                for _, descendant in ipairs(handle:GetDescendants()) do
                    if descendant:IsA("Attachment") and head:FindFirstChild(descendant.Name) then
                        attachedToHead = true
                        break
                    end
                end

                if attachedToHead then
                    highestY = math.max(highestY, getPartTopY(handle))
                end
            end
        end
    end

    return highestY
end

local function computeNametagStudsOffset(character, head, tagGui)
    local tagHeight = tagGui.Size.Y.Scale
    if tagHeight <= 0 then
        tagHeight = 1.2
    end

    local headStackTopY = getHeadStackTopY(character, head)
    local computedOffset = (headStackTopY - head.Position.Y) + NAMETAG_CLEARANCE_Y + (tagHeight * 0.5)
    return math.max(MIN_NAMETAG_OFFSET_Y, computedOffset)
end

local function removeLegacyNametag(playerName)
    local folder = workspace:FindFirstChild("NameTags")
    if not folder then
        return
    end

    local legacyTag = folder:FindFirstChild(playerName)
    if legacyTag then
        legacyTag:Destroy()
    end
end

local function removeNametag(character)
    if not character then
        return
    end

    local head = character:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("BillboardGui") and child.Name == NAMETAG_NAME then
                child:Destroy()
            end
        end
    end

    removeLegacyNametag(character.Name)
end

local function getActiveTag(player)
    local character = player.Character
    if not character then
        return nil
    end

    local head = character:FindFirstChild("Head")
    if not head then
        return nil
    end

    return head:FindFirstChild(NAMETAG_NAME)
end

local function getTitleLabel(tag)
    if not tag then
        return nil
    end
    return tag:FindFirstChild("LowerText", true)
end

local function destroyEffectArtifacts(tag)
    if not tag then
        return
    end

    for _, descendant in ipairs(tag:GetDescendants()) do
        if string.sub(descendant.Name, 1, #TITLE_EFFECT_PREFIX) == TITLE_EFFECT_PREFIX then
            descendant:Destroy()
        end
    end
end

local function resetTitleLabelStyle(label)
    if not label then
        return
    end

    label.RichText = BASE_TITLE_STYLE.RichText
    label.TextColor3 = BASE_TITLE_STYLE.TextColor3
    label.TextTransparency = BASE_TITLE_STYLE.TextTransparency
    label.TextStrokeColor3 = BASE_TITLE_STYLE.TextStrokeColor3
    label.TextStrokeTransparency = BASE_TITLE_STYLE.TextStrokeTransparency
    label.Rotation = BASE_TITLE_STYLE.Rotation
    label.Position = BASE_TITLE_STYLE.Position
    label.Size = BASE_TITLE_STYLE.Size
end

local function clearTitleEffect(player, tag, label)
    local state = getPlayerState(player)
    state.titleEffectToken += 1

    if tag then
        tag:SetAttribute(TITLE_EFFECT_ATTRIBUTE, nil)
        destroyEffectArtifacts(tag)
    end

    resetTitleLabelStyle(label or getTitleLabel(tag))
end

local function ensureEffectChild(parent, className, name)
    local child = parent:FindFirstChild(name)
    if child and child.ClassName ~= className then
        child:Destroy()
        child = nil
    end

    if not child then
        child = Instance.new(className)
        child.Name = name
        child.Parent = parent
    end

    return child
end

local function isEffectActive(player, token, label)
    return label and label.Parent and getPlayerState(player).titleEffectToken == token
end

local function makeColorSequence(colors)
    if #colors == 0 then
        return ColorSequence.new(Color3.new(1, 1, 1))
    end

    if #colors == 1 then
        return ColorSequence.new(colors[1])
    end

    local keypoints = {}
    for index, color in ipairs(colors) do
        local time = (index - 1) / (#colors - 1)
        keypoints[index] = ColorSequenceKeypoint.new(time, color)
    end
    return ColorSequence.new(keypoints)
end

local function createGlowShadow(label, effect)
    local shadow = label:Clone()
    shadow.Name = TITLE_EFFECT_PREFIX .. "Shadow"

    for _, child in ipairs(shadow:GetChildren()) do
        child:Destroy()
    end

    local position = label.Position
    shadow.Position = UDim2.new(
        position.X.Scale,
        position.X.Offset + (effect.shadowOffsetX or 0),
        position.Y.Scale,
        position.Y.Offset + (effect.shadowOffsetY or 1)
    )

    local size = label.Size
    shadow.Size = UDim2.new(
        size.X.Scale,
        size.X.Offset + (effect.shadowGrowX or 0),
        size.Y.Scale,
        size.Y.Offset + (effect.shadowGrowY or 0)
    )

    shadow.ZIndex = math.max(0, label.ZIndex - 1)
    shadow.BackgroundTransparency = 1
    shadow.TextColor3 = effect.glowColor or effect.color or label.TextColor3
    shadow.TextTransparency = clampNumber(effect.glowTransparencyHigh, 0, 1, 0.84)
    shadow.TextStrokeTransparency = 1
    shadow.Parent = label.Parent
    return shadow
end

local function applyTintStyle(label, effect)
    label.TextColor3 = effect.color or BASE_TITLE_STYLE.TextColor3
    label.TextTransparency = clampNumber(effect.transparency, 0, 1, BASE_TITLE_STYLE.TextTransparency)
    label.TextStrokeColor3 = effect.strokeColor or BASE_TITLE_STYLE.TextStrokeColor3
    label.TextStrokeTransparency = clampNumber(effect.strokeTransparency, 0, 1, BASE_TITLE_STYLE.TextStrokeTransparency)
end

local function startShimmerEffect(player, label, effect, token)
    applyTintStyle(label, effect)

    local baseColor = effect.color or label.TextColor3
    local secondaryColor = effect.secondaryColor or lerpColor(baseColor, Color3.new(0, 0, 0), 0.35)
    local accentColor = effect.accentColor or lerpColor(baseColor, Color3.new(1, 1, 1), 0.28)

    local gradient = ensureEffectChild(label, "UIGradient", TITLE_EFFECT_PREFIX .. "Gradient")
    gradient.Rotation = tonumber(effect.rotation) or -12
    gradient.Color = makeColorSequence({secondaryColor, baseColor, accentColor, baseColor, secondaryColor})
    gradient.Offset = Vector2.new(-1.15, 0)

    local duration = math.max(2.4, tonumber(effect.speed) or 5)
    local pauseDuration = math.max(0.15, tonumber(effect.pause) or 0.4)

    task.spawn(function()
        while isEffectActive(player, token, label) do
            gradient.Offset = Vector2.new(-1.15, 0)

            local tween = TweenService:Create(
                gradient,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Offset = Vector2.new(1.15, 0)}
            )
            tween:Play()
            tween.Completed:Wait()

            if not isEffectActive(player, token, label) then
                break
            end

            task.wait(pauseDuration)
        end
    end)
end

local function startPulseEffect(player, label, effect, token)
    applyTintStyle(label, effect)

    local colorA = effect.color or label.TextColor3
    local colorB = effect.secondaryColor or lerpColor(colorA, Color3.new(1, 1, 1), 0.18)
    local lowTransparency = clampNumber(effect.transparencyLow, 0, 1, math.max(0, BASE_TITLE_STYLE.TextTransparency - 0.08))
    local highTransparency = clampNumber(effect.transparencyHigh, 0, 1, BASE_TITLE_STYLE.TextTransparency + 0.05)
    local lowStroke = clampNumber(effect.strokeTransparencyLow, 0, 1, clampNumber(effect.strokeTransparency, 0, 1, BASE_TITLE_STYLE.TextStrokeTransparency))
    local highStroke = clampNumber(effect.strokeTransparencyHigh, 0, 1, math.min(1, lowStroke + 0.06))
    local glowLow = clampNumber(effect.glowTransparencyLow, 0, 1, 0.82)
    local glowHigh = clampNumber(effect.glowTransparencyHigh, 0, 1, 0.9)
    local duration = math.max(1.8, tonumber(effect.speed) or 2.8)
    local shadow = effect.glowColor and createGlowShadow(label, effect) or nil

    task.spawn(function()
        while isEffectActive(player, token, label) do
            local tweenIn = TweenService:Create(
                label,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    TextTransparency = lowTransparency,
                    TextStrokeTransparency = lowStroke,
                    TextColor3 = colorB,
                }
            )
            tweenIn:Play()

            if shadow then
                TweenService:Create(
                    shadow,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {TextTransparency = glowLow}
                ):Play()
            end

            tweenIn.Completed:Wait()
            if not isEffectActive(player, token, label) then
                break
            end

            local tweenOut = TweenService:Create(
                label,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    TextTransparency = highTransparency,
                    TextStrokeTransparency = highStroke,
                    TextColor3 = colorA,
                }
            )
            tweenOut:Play()

            if shadow then
                TweenService:Create(
                    shadow,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {TextTransparency = glowHigh}
                ):Play()
            end

            tweenOut.Completed:Wait()
        end
    end)
end

local function startGlowEffect(player, label, effect, token)
    applyTintStyle(label, effect)
    label.TextTransparency = clampNumber(effect.transparency, 0, 1, math.max(0, BASE_TITLE_STYLE.TextTransparency - 0.08))

    local baseStrokeTransparency = clampNumber(effect.strokeTransparency, 0, 1, BASE_TITLE_STYLE.TextStrokeTransparency)
    local brighterStrokeTransparency = clampNumber(baseStrokeTransparency - 0.04, 0, 1, baseStrokeTransparency)
    local glowLow = clampNumber(effect.glowTransparencyLow, 0, 1, 0.74)
    local glowHigh = clampNumber(effect.glowTransparencyHigh, 0, 1, 0.84)
    local duration = math.max(2.4, tonumber(effect.speed) or 3.4)
    local shadow = createGlowShadow(label, effect)

    task.spawn(function()
        while isEffectActive(player, token, label) do
            local glowIn = TweenService:Create(
                shadow,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextTransparency = glowLow}
            )
            glowIn:Play()
            TweenService:Create(
                label,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextStrokeTransparency = brighterStrokeTransparency}
            ):Play()
            glowIn.Completed:Wait()
            if not isEffectActive(player, token, label) then
                break
            end

            local glowOut = TweenService:Create(
                shadow,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextTransparency = glowHigh}
            )
            glowOut:Play()
            TweenService:Create(
                label,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextStrokeTransparency = baseStrokeTransparency}
            ):Play()
            glowOut.Completed:Wait()
        end
    end)
end

local function startFlickerEffect(player, label, effect, token)
    applyTintStyle(label, effect)

    local baseTransparency = clampNumber(effect.transparency, 0, 1, BASE_TITLE_STYLE.TextTransparency)
    local flickerTransparency = clampNumber(effect.flickerTransparency, 0, 1, math.min(1, baseTransparency + 0.14))
    local baseStrokeTransparency = clampNumber(effect.strokeTransparency, 0, 1, BASE_TITLE_STYLE.TextStrokeTransparency)
    local flickerStrokeTransparency = clampNumber(baseStrokeTransparency + 0.05, 0, 1, math.min(1, baseStrokeTransparency + 0.05))
    local jitterDegrees = tonumber(effect.jitterDegrees) or 0.6
    local intervalMin = math.max(1.2, tonumber(effect.intervalMin) or 2.2)
    local intervalMax = math.max(intervalMin + 0.1, tonumber(effect.intervalMax) or 5.1)
    local random = Random.new(player.UserId)

    label.TextTransparency = baseTransparency
    label.TextStrokeTransparency = baseStrokeTransparency

    task.spawn(function()
        while isEffectActive(player, token, label) do
            task.wait(random:NextNumber(intervalMin, intervalMax))
            if not isEffectActive(player, token, label) then
                break
            end

            local burstCount = random:NextInteger(2, 3)
            for _ = 1, burstCount do
                local flickerOut = TweenService:Create(
                    label,
                    TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {
                        TextTransparency = flickerTransparency,
                        TextStrokeTransparency = flickerStrokeTransparency,
                        Rotation = random:NextNumber(-jitterDegrees, jitterDegrees),
                    }
                )
                flickerOut:Play()
                flickerOut.Completed:Wait()

                if not isEffectActive(player, token, label) then
                    break
                end

                local flickerIn = TweenService:Create(
                    label,
                    TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {
                        TextTransparency = baseTransparency,
                        TextStrokeTransparency = baseStrokeTransparency,
                        Rotation = 0,
                    }
                )
                flickerIn:Play()
                flickerIn.Completed:Wait()

                if not isEffectActive(player, token, label) then
                    break
                end

                task.wait(random:NextNumber(0.03, 0.08))
            end
        end
    end)
end

local function applyTitleEffect(player, tag, titleId)
    local label = getTitleLabel(tag)
    if not label then
        return
    end

    local effect = TitleConfig.GetEffect(titleId)
    local normalizedTitleId = TitleConfig.NormalizeTitleId(titleId) or TitleConfig.DEFAULT_TITLE_ID
    local effectType = effect and effect.type or "none"
    local effectKey = string.format("%s:%s", normalizedTitleId, effectType)

    if tag:GetAttribute(TITLE_EFFECT_ATTRIBUTE) == effectKey then
        local shadow = tag:FindFirstChild(TITLE_EFFECT_PREFIX .. "Shadow", true)
        if shadow and shadow:IsA("TextLabel") then
            shadow.Text = label.Text
        end
        return
    end

    clearTitleEffect(player, tag, label)
    tag:SetAttribute(TITLE_EFFECT_ATTRIBUTE, effectKey)

    if effectType == "none" then
        return
    end

    local token = getPlayerState(player).titleEffectToken
    if effectType == "tint" then
        applyTintStyle(label, effect)
    elseif effectType == "pulse" then
        startPulseEffect(player, label, effect, token)
    elseif effectType == "shimmer" then
        startShimmerEffect(player, label, effect, token)
    elseif effectType == "flicker" then
        startFlickerEffect(player, label, effect, token)
    elseif effectType == "glow" then
        startGlowEffect(player, label, effect, token)
    else
        applyTintStyle(label, effect)
    end

    local shadow = tag:FindFirstChild(TITLE_EFFECT_PREFIX .. "Shadow", true)
    if shadow and shadow:IsA("TextLabel") then
        shadow.Text = label.Text
    end
end

local function applyThreeLineLayout(tag)
    local upperText = tag:FindFirstChild("UpperText", true)
    local lowerText = tag:FindFirstChild("LowerText", true)
    local handleText = tag:FindFirstChild("HandleTag", true)

    if upperText then
        upperText.Position = UDim2.fromScale(0.5, 0.25)
        upperText.Size = UDim2.fromScale(2.5, 0.45)
    end

    if lowerText then
        lowerText.Position = UDim2.fromScale(0.5, 0.55)
        lowerText.Size = UDim2.fromScale(2.5, 0.35)
        lowerText.Visible = true
    end

    if handleText then
        handleText.Position = UDim2.fromScale(0.5, 0.82)
        handleText.Size = UDim2.fromScale(2.5, 0.25)
    end
end

local function updateNametagText(player)
    syncPlayerDisplayNameValue(player)

    local tag = getActiveTag(player)
    if not tag then
        return
    end

    local upperText = tag:FindFirstChild("UpperText", true)
    local lowerText = tag:FindFirstChild("LowerText", true)
    local handleText = tag:FindFirstChild("HandleTag", true)
    local premiumIcon = tag:FindFirstChild("PremiumIcon", true)
    local equippedTitleId = getEquippedTitleId(player)

    if upperText then
        upperText.Text = getDisplayName(player)
    end

    if lowerText then
        lowerText.Text = TitleConfig.GetDisplayName(equippedTitleId)
        lowerText.Visible = lowerText.Text ~= ""
    end

    if handleText then
        handleText.Text = string.format("@%s  •  Lv. %d", player.Name, getLevel(player))
    end

    local hasPremium = player.MembershipType == Enum.MembershipType.Premium
    if premiumIcon then
        premiumIcon.Visible = hasPremium
    end

    tag:SetAttribute("HasPremium", hasPremium)
    applyThreeLineLayout(tag)
    applyTitleEffect(player, tag, equippedTitleId)
end

local function createNametag(player, character)
    if not character or not character.Parent then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    if not humanoid or not head then
        return false
    end

    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.NameDisplayDistance = 0
    humanoid.HealthDisplayDistance = 0
    humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion

    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("BillboardGui") and child.Name == NAMETAG_NAME then
            child:Destroy()
        end
    end

    local newTag = nametagTemplate:Clone()
    newTag.Name = NAMETAG_NAME
    newTag.Enabled = true
    newTag:SetAttribute("IsCustomNameTag", true)
    newTag.AlwaysOnTop = false
    newTag.MaxDistance = 28
    newTag.Adornee = head
    newTag.StudsOffset = Vector3.new(0, computeNametagStudsOffset(character, head, newTag), 0)
    newTag.Parent = head

    updateNametagText(player)
    return true
end

local function refreshNametag(player, character)
    local state = getPlayerState(player)
    state.refreshVersion += 1
    local refreshVersion = state.refreshVersion

    removeNametag(character)

    for _ = 1, 30 do
        if state.refreshVersion ~= refreshVersion then
            return
        end

        if not (character and character.Parent) then
            return
        end

        if createNametag(player, character) then
            if state.refreshVersion == refreshVersion then
                updateNametagText(player)
            end
            return
        end

        task.wait(0.1)
    end
end

local function requestNametagRefresh(player, character, delaySeconds)
    task.delay(delaySeconds or 0, function()
        if not player.Parent then
            return
        end
        if player.Character ~= character then
            return
        end
        refreshNametag(player, character)
    end)
end

local function connectLevelSource(player, valueObject)
    local state = getPlayerState(player)
    if state.levelConnections[valueObject] then
        return
    end

    state.levelConnections[valueObject] = valueObject:GetPropertyChangedSignal("Value"):Connect(function()
        updateNametagText(player)
    end)
end

local function bindEquippedTitleValue(player, valueObject)
    local state = getPlayerState(player)
    if state.equippedValue == valueObject then
        return
    end

    if state.equippedConnection then
        state.equippedConnection:Disconnect()
        state.equippedConnection = nil
    end

    state.equippedValue = valueObject
    state.equippedConnection = valueObject:GetPropertyChangedSignal("Value"):Connect(function()
        updateNametagText(player)
    end)
end

local function hookPlayer(player)
    ensureLegacyFolder()
    ensureRunValue(player)
    syncPlayerDisplayNameValue(player)

    local function bindExistingLevelSources()
        local levelValue = player:FindFirstChild("Level")
        if levelValue and levelValue:IsA("IntValue") then
            connectLevelSource(player, levelValue)
        end

        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats and leaderstats:IsA("Folder") then
            local leaderstatsLevel = leaderstats:FindFirstChild("Level")
            if leaderstatsLevel and leaderstatsLevel:IsA("IntValue") then
                connectLevelSource(player, leaderstatsLevel)
            end

            leaderstats.ChildAdded:Connect(function(child)
                if child.Name == "Level" and child:IsA("IntValue") then
                    connectLevelSource(player, child)
                    updateNametagText(player)
                end
            end)
        end
    end

    bindExistingLevelSources()

    local equippedValue = player:FindFirstChild("EquippedTitle")
    if equippedValue and equippedValue:IsA("StringValue") then
        bindEquippedTitleValue(player, equippedValue)
    end

    player.ChildAdded:Connect(function(child)
        if child.Name == "Level" and child:IsA("IntValue") then
            connectLevelSource(player, child)
            updateNametagText(player)
        elseif child.Name == "leaderstats" and child:IsA("Folder") then
            local innerLevel = child:FindFirstChild("Level")
            if innerLevel and innerLevel:IsA("IntValue") then
                connectLevelSource(player, innerLevel)
            end

            child.ChildAdded:Connect(function(grandChild)
                if grandChild.Name == "Level" and grandChild:IsA("IntValue") then
                    connectLevelSource(player, grandChild)
                    updateNametagText(player)
                end
            end)
        elseif child.Name == "EquippedTitle" and child:IsA("StringValue") then
            bindEquippedTitleValue(player, child)
            updateNametagText(player)
        end
    end)

    player:GetPropertyChangedSignal("DisplayName"):Connect(function()
        updateNametagText(player)
    end)

    player.CharacterAdded:Connect(function(character)
        requestNametagRefresh(player, character, 0)

        character.ChildAdded:Connect(function(child)
            if child.Name == "Head" or child:IsA("Humanoid") then
                requestNametagRefresh(player, character, 0)
            elseif child:IsA("Accessory") then
                requestNametagRefresh(player, character, 0.1)
            end
        end)

        character.ChildRemoved:Connect(function(child)
            if child:IsA("Accessory") then
                requestNametagRefresh(player, character, 0)
            end
        end)
    end)

    player.CharacterAppearanceLoaded:Connect(function(character)
        if character == player.Character then
            requestNametagRefresh(player, character, 0)
        end
    end)

    if player.Character then
        requestNametagRefresh(player, player.Character, 0)
    end
end

Players.PlayerAdded:Connect(hookPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    hookPlayer(player)
end

rebuildEvent.Event:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            requestNametagRefresh(player, player.Character, 0)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeLegacyNametag(player.Name)

    local state = playerStates[player]
    if not state then
        return
    end

    state.titleEffectToken += 1

    for _, connection in pairs(state.levelConnections) do
        if connection then
            connection:Disconnect()
        end
    end

    if state.equippedConnection then
        state.equippedConnection:Disconnect()
    end

    playerStates[player] = nil
end)
