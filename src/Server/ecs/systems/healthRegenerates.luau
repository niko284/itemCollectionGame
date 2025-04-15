--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)
local Components = require(ReplicatedStorage.ecs.components)

local function healthRegenerates(world: Matter.World)
    -- Regenerate health over time.
    local deltaTime = Matter.useDeltaTime()
    for eid, health: Components.Health in world:query(Components.Health) do
        local newHealth = health:patch({
            current = math.min(health.max, health.current + health.healthPerSecond * deltaTime),
        })

        world:insert(eid, newHealth)
    end
end

return healthRegenerates