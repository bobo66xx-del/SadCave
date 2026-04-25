local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TitleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))

local TitleEffectPreview = {}

local EFFECT_PREFIX = "TitleEffectPreview_"
local labelStates = setmetatable({}, {__mode = "k"})

local function clampNumber(value, minimum, maximum, fallback)
    local numericValue = tonumber(value)
    if numericValue == nil then
        return fallback
    end
    return math.clamp(numericValue, minimum, maximum)
end

local function blendColor(baseColor, targetColor, alpha)
    if typeof(baseColor) ~= "Color3" then
        baseColor = Color3.new(1, 1, 1)
    end
    if typeof(targetColor) ~= "Color3" then
        return baseColor
    end
    return baseColor:Lerp(targetColor, math.clamp(alpha or 0, 0, 1))
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

local function captureBaseStyle(label)
    return {
        TextColor3 = label.TextColor3,
        TextTransparency = label.TextTransparency,
        TextStrokeColor3 = label.TextStrokeColor3,
        TextStrokeTransparency = label.TextStrokeTransparency,
        Rotation = label.Rotation,
        Position = label.Position,
        Size = label.Size,
        RichText = label.RichText,
    }
end

local function getState(label)
    local state = labelStates[label]
    if not state then
        state = {
            token = 0,
            baseStyle = captureBaseStyle(label),
            artifacts = {},
            currentKey = nil,
        }
        labelStates[label] = state
    end
    return state
end

local function trackArtifact(state, instance)
    table.insert(state.artifacts, instance)
    return instance
end

local function destroyArtifacts(state)
    for _, instance in ipairs(state.artifacts) do
        if instance and instance.Parent then
            instance:Destroy()
        end
    end
    table.clear(state.artifacts)
end

local function resetLabelStyle(label, state)
    local baseStyle = state.baseStyle
    label.RichText = baseStyle.RichText
    label.TextColor3 = baseStyle.TextColor3
    label.TextTransparency = baseStyle.TextTransparency
    label.TextStrokeColor3 = baseStyle.TextStrokeColor3
    label.TextStrokeTransparency = baseStyle.TextStrokeTransparency
    label.Rotation = baseStyle.Rotation
    label.Position = baseStyle.Position
    label.Size = baseStyle.Size
end

local function resolvePreviewTitleId(titleOrId)
    if type(titleOrId) == "table" then
        local explicitId = titleOrId.LinkedTitleId or titleOrId.linkedTitleId or titleOrId.Id or titleOrId.id
        return TitleConfig.NormalizeTitleId(explicitId)
    end

    return TitleConfig.NormalizeTitleId(titleOrId)
end

local function isEffectActive(label, token)
    local state = labelStates[label]
    return label.Parent ~= nil and state ~= nil and state.token == token
end

local function applyPreviewTint(label, state, effect)
    local baseStyle = state.baseStyle
    local targetTransparency = clampNumber(effect.transparency, 0, 1, baseStyle.TextTransparency)
    local targetStrokeTransparency = clampNumber(effect.strokeTransparency, 0, 1, baseStyle.TextStrokeTransparency)

    label.TextColor3 = blendColor(baseStyle.TextColor3, effect.color, 0.55)
    label.TextTransparency = (baseStyle.TextTransparency * 0.75) + (targetTransparency * 0.25)
    label.TextStrokeColor3 = blendColor(baseStyle.TextStrokeColor3, effect.strokeColor, 0.45)
    label.TextStrokeTransparency = (baseStyle.TextStrokeTransparency * 0.75) + (targetStrokeTransparency * 0.25)
end

local function createShadow(label, state, effect, transparency)
    local shadow = label:Clone()
    shadow.Name = EFFECT_PREFIX .. "Shadow"

    for _, child in ipairs(shadow:GetChildren()) do
        child:Destroy()
    end

    shadow.Position = UDim2.new(
        label.Position.X.Scale,
        label.Position.X.Offset + (effect.shadowOffsetX or 0),
        label.Position.Y.Scale,
        label.Position.Y.Offset + (effect.shadowOffsetY or 1)
    )
    shadow.Size = label.Size
    shadow.ZIndex = math.max(0, label.ZIndex - 1)
    shadow.BackgroundTransparency = 1
    shadow.Text = label.Text
    shadow.TextColor3 = blendColor(label.TextColor3, effect.glowColor or effect.color, 0.55)
    shadow.TextTransparency = transparency
    shadow.TextStrokeTransparency = 1
    shadow.Parent = label.Parent
    trackArtifact(state, shadow)
    return shadow
end

local function startShimmer(label, state, effect, token)
    applyPreviewTint(label, state, effect)

    local baseColor = label.TextColor3
    local secondaryColor = blendColor(baseColor, effect.secondaryColor, 0.35)
    local accentColor = blendColor(baseColor, effect.accentColor or effect.color, 0.22)

    local gradient = Instance.new("UIGradient")
    gradient.Name = EFFECT_PREFIX .. "Gradient"
    gradient.Rotation = tonumber(effect.rotation) or -10
    gradient.Color = makeColorSequence({secondaryColor, baseColor, accentColor, baseColor, secondaryColor})
    gradient.Offset = Vector2.new(-1.05, 0)
    gradient.Parent = label
    trackArtifact(state, gradient)

    local duration = math.max(4.8, (tonumber(effect.speed) or 5) * 1.35)
    local pauseDuration = math.max(0.45, tonumber(effect.pause) or 0.6)

    task.spawn(function()
        while isEffectActive(label, token) do
            gradient.Offset = Vector2.new(-1.05, 0)
            local tween = TweenService:Create(
                gradient,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Offset = Vector2.new(1.05, 0)}
            )
            tween:Play()
            tween.Completed:Wait()
            if not isEffectActive(label, token) then
                break
            end
            task.wait(pauseDuration)
        end
    end)
end

local function startPulse(label, state, effect, token)
    applyPreviewTint(label, state, effect)

    local baseColor = label.TextColor3
    local pulseColor = blendColor(baseColor, effect.secondaryColor or effect.color, 0.18)
    local lowTransparency = math.max(0, label.TextTransparency - 0.03)
    local highTransparency = math.min(1, label.TextTransparency + 0.05)
    local lowStrokeTransparency = math.max(0, label.TextStrokeTransparency - 0.02)
    local highStrokeTransparency = math.min(1, label.TextStrokeTransparency + 0.03)
    local duration = math.max(3.3, (tonumber(effect.speed) or 3) * 1.4)
    local shadow = nil

    if typeof(effect.glowColor) == "Color3" or typeof(effect.color) == "Color3" then
        shadow = createShadow(label, state, effect, 0.93)
    end

    task.spawn(function()
        while isEffectActive(label, token) do
            local tweenIn = TweenService:Create(
                label,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    TextTransparency = lowTransparency,
                    TextStrokeTransparency = lowStrokeTransparency,
                    TextColor3 = pulseColor,
                }
            )
            tweenIn:Play()
            if shadow then
                TweenService:Create(
                    shadow,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {TextTransparency = 0.89}
                ):Play()
            end
            tweenIn.Completed:Wait()
            if not isEffectActive(label, token) then
                break
            end

            local tweenOut = TweenService:Create(
                label,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {
                    TextTransparency = highTransparency,
                    TextStrokeTransparency = highStrokeTransparency,
                    TextColor3 = baseColor,
                }
            )
            tweenOut:Play()
            if shadow then
                TweenService:Create(
                    shadow,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {TextTransparency = 0.94}
                ):Play()
            end
            tweenOut.Completed:Wait()
        end
    end)
end

local function startGlow(label, state, effect, token)
    applyPreviewTint(label, state, effect)

    local shadow = createShadow(label, state, effect, 0.9)
    local baseStrokeTransparency = label.TextStrokeTransparency
    local duration = math.max(4.0, (tonumber(effect.speed) or 3.4) * 1.35)

    task.spawn(function()
        while isEffectActive(label, token) do
            local glowIn = TweenService:Create(
                shadow,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextTransparency = 0.84}
            )
            glowIn:Play()
            TweenService:Create(
                label,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextStrokeTransparency = math.max(0, baseStrokeTransparency - 0.03)}
            ):Play()
            glowIn.Completed:Wait()
            if not isEffectActive(label, token) then
                break
            end

            local glowOut = TweenService:Create(
                shadow,
                TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextTransparency = 0.91}
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

local function startFlicker(label, state, effect, token)
    applyPreviewTint(label, state, effect)

    local baseTransparency = label.TextTransparency
    local baseStrokeTransparency = label.TextStrokeTransparency
    local flickerTransparency = math.min(1, baseTransparency + 0.08)
    local flickerStrokeTransparency = math.min(1, baseStrokeTransparency + 0.05)
    local jitterDegrees = math.min(0.35, tonumber(effect.jitterDegrees) or 0.25)
    local intervalMin = math.max(3.4, (tonumber(effect.intervalMin) or 2.4) * 1.45)
    local intervalMax = math.max(intervalMin + 0.2, (tonumber(effect.intervalMax) or 5.3) * 1.35)
    local random = Random.new(label.AbsoluteSize.X + (label.AbsoluteSize.Y * 7) + string.len(label.Text or ""))

    task.spawn(function()
        while isEffectActive(label, token) do
            task.wait(random:NextNumber(intervalMin, intervalMax))
            if not isEffectActive(label, token) then
                break
            end

            local burstCount = random:NextInteger(1, 2)
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
                if not isEffectActive(label, token) then
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
                if not isEffectActive(label, token) then
                    break
                end
                task.wait(random:NextNumber(0.05, 0.1))
            end
        end
    end)
end

function TitleEffectPreview.Clear(label)
    if not (label and label:IsA("TextLabel")) then
        return
    end

    local state = getState(label)
    state.token += 1
    state.currentKey = nil
    destroyArtifacts(state)

    if label.Parent then
        resetLabelStyle(label, state)
    end
end

function TitleEffectPreview.ClearContainer(root)
    if not root then
        return
    end

    if root:IsA("TextLabel") then
        TitleEffectPreview.Clear(root)
    end

    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("TextLabel") and labelStates[descendant] then
            TitleEffectPreview.Clear(descendant)
        end
    end
end

function TitleEffectPreview.Apply(label, titleOrId)
    if not (label and label:IsA("TextLabel")) then
        return
    end

    local state = getState(label)
    local titleId = resolvePreviewTitleId(titleOrId)
    local effect = titleId and TitleConfig.GetEffect(titleId) or TitleConfig.GetEffect(nil)
    local effectType = (type(effect) == "table" and effect.type) or "none"
    local effectKey = string.format("%s:%s", titleId or "none", effectType)

    if state.currentKey == effectKey then
        for _, instance in ipairs(state.artifacts) do
            if instance and instance:IsA("TextLabel") then
                instance.Text = label.Text
            end
        end
        return
    end

    TitleEffectPreview.Clear(label)
    state = getState(label)
    state.currentKey = effectKey

    if effectType == "none" then
        return
    end

    local token = state.token
    if effectType == "tint" then
        applyPreviewTint(label, state, effect)
    elseif effectType == "pulse" then
        startPulse(label, state, effect, token)
    elseif effectType == "shimmer" then
        startShimmer(label, state, effect, token)
    elseif effectType == "flicker" then
        startFlicker(label, state, effect, token)
    elseif effectType == "glow" then
        startGlow(label, state, effect, token)
    else
        applyPreviewTint(label, state, effect)
    end
end

return TitleEffectPreview
