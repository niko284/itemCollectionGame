local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)
local Plasma = require(Packages.Plasma)

local function start(systemsContainers: { Instance }, services)
	print("Starting ECS")
	local world = Matter.World.new()

	local debugger = Matter.Debugger.new(Plasma) -- Pass Plasma into the debugger!
	local widgets = debugger:getWidgets()

	local loop = Matter.Loop.new(world, {
		services = services,
	}, widgets)

	debugger:autoInitialize(loop)

	debugger.authorize = function()
		return true
	end

	local systems = {}
	for _, systemContainer in ipairs(systemsContainers) do
		for _, system in systemContainer:GetChildren() do
			table.insert(systems, require(system))
		end
	end
	for _, service in services do
		service.World = world -- inject the world into the service for easy access
	end

	loop:scheduleSystems(systems)

	loop:begin({
		default = RunService.Heartbeat,
		stepped = RunService.Stepped,
	})

	return world
end

return start
