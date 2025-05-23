--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)
local Plasma = require(Packages.Plasma)
local Spark = require(Packages.Spark)

local InputState = Spark.InputState
local Actions = Spark.Actions :: any
local InputMap = Spark.InputMap

function Actions:justPressed(action: string): boolean
	local signal = self:justPressedSignal(action)
	local iterator = Matter.useEvent(action, signal)

	return iterator() ~= nil
end

function Actions:justReleased(action: string): boolean
	local signal = self:justReleasedSignal(action)
	local iterator = Matter.useEvent(action, signal)

	return iterator() ~= nil
end

local function start(systemsContainers: { Instance }, controllers)
	local state = {
		inputState = InputState.new(),
		actions = Actions.new({ "shoot" }),
		inputMap = InputMap.new():insert("shoot", Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR1, Enum.KeyCode.F),
	}

	local debugger = Matter.Debugger.new(Plasma) -- Pass Plasma into the debugger!
	local widgets = debugger:getWidgets()

	local world = Matter.World.new()
	local loop = Matter.Loop.new(world, state, widgets)

	debugger:autoInitialize(loop)

	local systems = {}
	for _, systemContainer in ipairs(systemsContainers) do
		for _, system in systemContainer:GetChildren() do
			table.insert(systems, require(system) :: any)
		end
	end
	for _, controller in controllers do
		controller.World = world -- inject the world into the controller for easy access
	end

	loop:scheduleSystems(systems)

	loop:begin({
		default = RunService.Heartbeat,
		RenderStepped = RunService.RenderStepped,
		Heartbeat = RunService.Heartbeat,
		Stepped = RunService.Stepped,
	})

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.RightBracket then
			debugger:toggle()
		end
	end)

	return world
end

return start