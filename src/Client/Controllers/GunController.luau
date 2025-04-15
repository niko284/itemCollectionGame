--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utilities = ReplicatedStorage.Utilities
local Packages = ReplicatedStorage.Packages

local VFXUtility = require(Utilities.VFXUtility)
local Knit = require(Packages.Knit)

local GunService = Knit.GetService("GunService")

local GunController = {
    Name = "GunController"
}

function GunController:KnitInit()
    GunService.GunShot:Connect(function(Player: Player, HitPart: BasePart)
        VFXUtility.Gunshot(Player.Character :: Model, HitPart.Position)
    end)
end

return GunController