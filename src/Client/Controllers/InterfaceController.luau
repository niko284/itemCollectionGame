--!strict

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts

local App = require(PlayerScripts.ui.App)

local InterfaceController = {
	Name = "InterfaceController",
}

print("Yes")
function InterfaceController:KnitStart()
	print("Start")
	local newApp = App({})
	newApp.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

return InterfaceController
