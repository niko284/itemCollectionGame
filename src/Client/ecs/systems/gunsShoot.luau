--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Packages = ReplicatedStorage.Packages
local Utilities = ReplicatedStorage.Utilities

local Components = require(ReplicatedStorage.ecs.components)
local Matter = require(Packages.Matter)
local MatterReplication = require(Packages.MatterReplication)
local Knit = require(Packages.Knit)
local VFXUtility = require(Utilities.VFXUtility)

local GunService = Knit.GetService("GunService")

local function gunsShoot(world: Matter.World, state)
	local actions = state.actions

	local isShooting = actions:pressed("shoot")

	for entity, gun: Components.Gun, serverEntity in world:query(Components.Gun, MatterReplication.ServerEntity):without(Components.Cooldown) do
		if gun.owner == LocalPlayer and isShooting then
			local mouseLocation = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
			local viewportPointRay = workspace.CurrentCamera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)

			local bulletFilter = { gun.owner.Character :: Model } :: { Instance }

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = bulletFilter
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local hitPart = workspace:Raycast(viewportPointRay.Origin, viewportPointRay.Direction * 1000, raycastParams)

			if hitPart and hitPart.Instance then
				local origin = LocalPlayer.Character:WaitForChild("RightHand").Position
				local dirFromRightHand = (hitPart.Position - LocalPlayer.Character:WaitForChild("RightHand").Position).Unit

				local newCapacity = gun.ammo - 1
				if newCapacity < 0 then
					newCapacity = gun.capacity
				end

				gun = gun:patch({
					ammo = newCapacity,
				})
				world:insert(entity, gun)

				local timeNow = DateTime.now()
				local cooldownMillis = newCapacity == 0 and gun.reloadTimeMillis or gun.cooldownMillis

				world:insert(
					entity,
					Components.Cooldown({
						expiry = timeNow.UnixTimestampMillis + cooldownMillis,
					})
				)

				-- Other clients will get this fired to them, do it here for instant feedback for high-ping users.
				VFXUtility.Gunshot(LocalPlayer.Character, hitPart.Position)
				
				GunService.GunShot:Fire(serverEntity.id, hitPart.Instance)
			end
		end
	end
end

return gunsShoot
