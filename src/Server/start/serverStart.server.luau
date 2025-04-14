--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Services
local Packages = ReplicatedStorage.Packages

local bootstrapCollections = require(ReplicatedStorage.ecs.BootstrapCollections)
local ecsStart = require(ServerScriptService.ecs.start)
local Components = require(ReplicatedStorage.ecs.components)
local Knit = require(Packages.Knit)

local SYSTEM_CONTAINERS = {
	ServerScriptService.ecs.systems,
} :: any
local COLLECTION_COMPONENTS = {
	TargetZone = {
		Components.TargetZone,
	},
	Target = {
		Components.Target,
	},
}

local function AddServicesCustom(parent: Instance)
	local services = {}
	for _, v in parent:GetChildren() do
		if v:IsA("ModuleScript") and v.Name:match("Service$") then
			local service = require(v) :: any
			table.insert(services, Knit.CreateService(service))
		end
	end
	return services
end

local services = AddServicesCustom(Services)

Knit.Start()

local world = ecsStart(SYSTEM_CONTAINERS, services)
bootstrapCollections(world, COLLECTION_COMPONENTS, { workspace })
