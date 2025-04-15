--!strict

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts

local App = require(PlayerScripts.ui.App)

local InterfaceController = {
	Name = "InterfaceController",
}

function InterfaceController:KnitStart()
	local newApp = App({})
	newApp.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

return InterfaceController
