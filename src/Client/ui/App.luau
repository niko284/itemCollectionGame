--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)
local Inventory = require(script.Parent.inventory)
local HUDButton = require(script.Parent.other.HUDButton)

local New = Fusion.New
local Children = Fusion.Children

local function App(_props)
	return New("ScreenGui")({
		Name = "Inventory",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		[Children] = {
			Inventory({}),

			New("Frame")({
				Name = "HUDButtonHolder",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.0274, 0.282),
				Size = UDim2.fromScale(0.0859, 0.435),

				[Children] = {
					New("UIListLayout")({
						Name = "UIListLayout",
						Padding = UDim.new(0.03, 0),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					HUDButton({
						image = "http://www.roblox.com/asset/?id=107711744983118",
						size = UDim2.fromScale(0.603, 0.248),
						hudName = "Inventory",
					}),
				},
			}),
		},
	})
end

return App
