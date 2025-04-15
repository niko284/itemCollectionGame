--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utilities = ReplicatedStorage.Utilities
local Packages = ReplicatedStorage.Packages

local VFXUtility = require(Utilities.VFXUtility)
local Knit = require(Packages.Knit)

local GunController = {
	Name = "GunController",
}

function GunController:KnitStart()
	local GunService = Knit.GetService("GunService")
	GunService.GunShot:Connect(function(Player: Player, hitPosition: Vector3)
		VFXUtility.Gunshot(Player.Character :: Model, hitPosition)
	end)
end

return GunController
