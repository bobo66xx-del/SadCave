

game:GetService("RunService").RenderStepped:Connect(function()



	local cola = game.Lighting.AfterPulseColor.Value
	local children = game.Workspace.Theme:GetChildren()
	for _, child in pairs(children) do
		for _, child in pairs(child:GetChildren()) do
			table.insert(children, child)
		end


		if child:IsA('BasePart') or child:IsA("PointLight")then
			game.Workspace.PointLight.Color = Color3.new(cola.R, cola.G, cola.B)
			game.Workspace.PointLight.Color = Color3.new(cola.R, cola.G, cola.B)
			child.Color = Color3.new(cola.R, cola.G, cola.B)		
		end
	end
end)





