--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)
local Components = require(ReplicatedStorage.ecs.components)

local function processHits(world: Matter.World)
    for eid, gun: Components.Gun in world:query(Components.Gun) do
        local hitQueue = gun.hitQueue 
        if hitQueue and #hitQueue > 0 then
            for _, hitEntry in hitQueue do
                local hitPart = hitEntry.part

                -- For hits, we get the exact PART we hit. The potential renderable entity id associated with the model itself.
                local renderableModel = hitPart:FindFirstAncestorOfClass("Model") :: Model 
                print(renderableModel)
                if not renderableModel then
                    continue 
                end 

                local hitEntityId = renderableModel:GetAttribute("serverEntityId")

                if hitEntityId then
                    -- if we hit a part that has a server entity id, we can assume some kind of interaction.
                    -- we can then branch into different callbacks based on the type of entity we hit.

                    local target: Components.Target? = world:get(hitEntityId, Components.Target)

                    if target then
                        -- Targets take damage.
                        local targetHealth: Components.Health = world:get(hitEntityId, Components.Health)
                        targetHealth = targetHealth:patch({
                            current = math.max(0, targetHealth.current - gun.damage)
                        })
                        world:insert(hitEntityId, targetHealth)
                    end
                end
            end
            -- Clear the hit queue after processing.
            gun = gun:patch({
                hitQueue = {}
            })
            world:insert(eid, gun)
        end
    end
end

return processHits 