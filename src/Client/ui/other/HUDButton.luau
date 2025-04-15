--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local GlobalState = require(script.Parent.Parent.GlobalState)

local Children = Fusion.Children
local New = Fusion.New
local OnEvent = Fusion.OnEvent

type HUDButtonProps = {
	image: string,
	size: UDim2,
	hudName: string,
	onPressed: (() -> ())?,
}
local function HUDButton(props: HUDButtonProps)
	return New("Frame")({
		Name = "HUDButton",
		BackgroundColor3 = Color3.fromRGB(53, 53, 53),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = props.size,

		[Children] = {
			New("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0.25, 0),
			}),

			New("UIStroke")({
				Name = "UIStroke",
				Color = Color3.fromRGB(255, 255, 255),
			}),

			New("ImageButton")({
				Name = "button",
				Image = props.image,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.13, 0.13),
				Size = UDim2.fromScale(0.74, 0.74),
				[OnEvent("Activated")] = function()
					if props.onPressed then
						props.onPressed()
					end
					if GlobalState.currentHUD:get() == props.hudName then
						GlobalState.currentHUD:set(nil)
					else
						GlobalState.currentHUD:set(props.hudName)
					end
				end,
			}),
		},
	})
end

return HUDButton
