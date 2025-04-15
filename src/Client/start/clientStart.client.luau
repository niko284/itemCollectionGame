--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Packages = ReplicatedStorage.Packages
local Controllers = LocalPlayer.PlayerScripts:FindFirstChild("Controllers") :: Folder

local bootstrapCollections = require(ReplicatedStorage.ecs.BootstrapCollections)
local ecsStart = require(LocalPlayer.PlayerScripts.ecs.start) :: any
local Knit = require(Packages.Knit)

local SYSTEM_CONTAINERS = {
	LocalPlayer.PlayerScripts.ecs.systems,
	ReplicatedStorage.ecs.systems,
} :: any
local COLLECTION_COMPONENTS = {}

local function AddControllersCustom(parent: Instance)
	local controllers = {}
	for _, v in parent:GetChildren() do
		if v:IsA("ModuleScript") and v.Name:match("Controller$") then
			local controller = require(v) :: any
			table.insert(controllers, Knit.CreateController(controller))
		end
	end
	return controllers
end

local controllers = AddControllersCustom(Controllers)

Knit.Start()

local world = ecsStart(SYSTEM_CONTAINERS, controllers)
bootstrapCollections(world, COLLECTION_COMPONENTS, { workspace })

print("Started client")
