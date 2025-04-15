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
	self.Client.GunShot:Connect(function(player: Player, gunEntityId: any, hitPosition: Vector3?, hitPart: any?)
		if typeof(gunEntityId) ~= "number" or gunEntityId < 0 then
			return
		end
		if hitPart and hitPart:IsA("PVInstance") == false then
			return
		end
		if not hitPosition or typeof(hitPosition) ~= "Vector3" then
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

		local newCapacity = gun.ammo - 1
		if newCapacity < 0 then
			newCapacity = gun.capacity
		end
		gun = gun:patch({
			ammo = newCapacity,
		})
		world:insert(gunEntityId, gun)

		local timeNow = DateTime.now()
		local cooldownMillis = newCapacity == 0 and gun.reloadTimeMillis or gun.cooldownMillis

		world:insert(
			gunEntityId,
			Components.Cooldown({
				expiry = timeNow.UnixTimestampMillis + cooldownMillis,
			})
		)

		self.Client.GunShot:FireExcept(player, player, hitPosition) -- Play VFX on all clients except the invoker, who already played them.

		if hitPart then
			-- We can insert the part we hit in a queue associated with the gun. A system can then process this queue.

			local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not rootPart then
				return -- Player does not have a HumanoidRootPart, cannot proceed
			end
			if (hitPart.Position - rootPart.Position).Magnitude > gun.range * 1.2 then
				return -- Hit part is too far away from the gun to be valid
			end

			local hitEntry = {
				part = hitPart,
			}

			local newHitQueue = gun.hitQueue and table.clone(gun.hitQueue) or {}
			table.insert(newHitQueue, hitEntry)
			gun = gun:patch({
				hitQueue = newHitQueue,
			})

			world:insert(gunEntityId, gun)
		end
	end)
end

return GunService
