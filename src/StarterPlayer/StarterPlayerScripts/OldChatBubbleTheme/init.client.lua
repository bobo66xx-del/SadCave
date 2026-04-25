
local ChatService = game:GetService("Chat")

local Settings = {
	BubbleDuration = 10,
	MaxBubbles = 3,
	BackgroundColor3 = Color3.fromRGB(15, 15, 15),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 22,
	Font = Enum.Font.SourceSansItalic,
	Transparency = 0,
	CornerRadius = UDim.new(0, 5),
	TailVisible = true,
	Padding = 6,
	MaxWidth = 300,
	VerticalStudsOffset = 1.5,
	BubblesSpacing = 9,
	MinimizeDistance = 40,
	MaxDistance = 100,
	AdorneeName = "Head",
}

pcall(function()
	ChatService.BubbleChatEnabled = true
	ChatService:SetBubbleChatSettings(Settings)
end)
