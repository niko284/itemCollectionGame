--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Fusion = require(Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnChange = Fusion.OnChange

type SearchbarProps = {
	size: UDim2,
	onChange: (text: string) -> nil,
	position: UDim2,
}

local function Searchbar(props: SearchbarProps)
	return New("TextBox")({
		Name = "searchBox",
		CursorPosition = -1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
		PlaceholderColor3 = Color3.fromRGB(0, 0, 0),
		PlaceholderText = "Search...",
		Text = "",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 25,
		TextWrapped = true,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = props.position,
		Size = props.size,

		[OnChange("Text")] = function(text: string)
			props.onChange(text)
		end,

		[Children] = {
			New("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(1, 0),
			}),
		},
	})
end

return Searchbar
