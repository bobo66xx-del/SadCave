game.ReplicatedStorage.Remotes.LevelUp.OnClientEvent:Connect(function(level)

	game.StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "LEVEL UP: ",
		Color = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSansBold,
		TextSize = 20,
	})
end)
