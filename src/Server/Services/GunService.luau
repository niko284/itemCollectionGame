--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Matter = require(Packages.Matter)
local Components = require(ReplicatedStorage.ecs.components)

local GunService = {
    Name = "GunService",
    Client = {
        GunShot = Knit.CreateSignal(),
    },
    World = nil :: Matter.World?,
}

function GunService:KnitInit()
    self.Client.GunShot:Connect(function(player: Player, gunEntityId: any, hitPart: any)
        if typeof(gunEntityId) ~= "number" or gunEntityId < 0 or typeof(hitPart) ~= "Instance" or hitPart:IsA("PVInstance") == false then
            return
        end

        local world = self.World :: Matter.World -- injected by start process

        if world:contains(gunEntityId) == false then
            return
        end

        local gun: Components.Gun? = world:get(gunEntityId, Components.Gun)
        if gun == nil then
            return -- EntityId not associated with a gun
        end

        if world:get(gunEntityId, Components.Cooldown) then
            return -- Gun is on cooldown (reloading or otherwise)
        end

        if gun.owner ~= player then
            return -- Gun is not owned by the player
        end

        -- We can insert the part we hit in a queue associated with the gun. A system can then process this queue.
        
        local hitEntry = {
            part = hitPart,
        }

        local newHitQueue = gun.hitQueue and table.clone(gun.hitQueue) or {}
        table.insert(newHitQueue, hitEntry)
        gun = gun:patch({
            hitQueue = newHitQueue
        })

        world:insert(gunEntityId, gun)

        self.Client.GunShot:FireExcept(player, player, hitPart) -- Play VFX on all clients except the invoker, who already played them.
    end)
end

return GunService