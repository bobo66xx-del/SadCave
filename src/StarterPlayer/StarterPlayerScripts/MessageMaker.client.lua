game.ReplicatedStorage.Remotes.Players.OnClientEvent:Connect(function(notice)

	game.StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "NOTICE: "..string.upper(notice),
		Color = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSansBold,
		TextSize = 20,
	})
end)
