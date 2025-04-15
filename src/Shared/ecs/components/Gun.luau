local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)

return Matter.component("Gun", {})
