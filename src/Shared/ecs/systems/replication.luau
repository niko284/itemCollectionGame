--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.ecs.components)
local MatterReplication = require(ReplicatedStorage.Packages.MatterReplication)

local REPLICATED_COMPONENTS = {
	Components.Gun,
	Components.Renderable,
	Components.Pickupable,
}

return MatterReplication.createReplicationSystem(REPLICATED_COMPONENTS)
