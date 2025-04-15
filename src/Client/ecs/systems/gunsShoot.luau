--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Packages = ReplicatedStorage.Packages
local Utilities = ReplicatedStorage.Utilities

local Assets = ReplicatedStorage:FindFirstChild("assets") :: Folder
local Animations = Assets:FindFirstChild("animations") :: Folder

local Components = require(ReplicatedStorage.ecs.components)
local Matter = require(Packages.Matter)
local MatterReplication = require(Packages.MatterReplication)
local Knit = require(Packages.Knit)
local VFXUtility = require(Utilities.VFXUtility)
local AnimationUtility = require(Utilities.AnimationUtility)

local SHOOT_ANIMATION = Animations:FindFirstChild("GunShoot") :: Animation

local GunService = Knit.GetService("GunService")

local function gunsShoot(world: Matter.World, state)
	local actions = state.actions

	local isShooting = actions:pressed("shoot")

	local character = LocalPlayer.Character :: Model

	for entity, gun: Components.Gun, serverEntity in
		world:query(Components.Gun, MatterReplication.ServerEntity):without(Components.Cooldown)
	do
		if gun.owner == LocalPlayer and isShooting then
			local mouseLocation = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
			local viewportPointRay = workspace.CurrentCamera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)

			local bulletFilter = { gun.owner.Character :: Model } :: { Instance }

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = bulletFilter
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local screenPart =
				workspace:Raycast(viewportPointRay.Origin, viewportPointRay.Direction * 1000, raycastParams)

			local rightHand = character:WaitForChild("RightHand") :: BasePart

			-- Idea here is to find the hit position of the screen raycast, then use that to find the direction from the right hand to the hit position.
			-- And raycast from the right hand to that direction, which will hit the first thing in that direction.
			-- since ViewportPointRay's origin is the screen's camera not the right hand.
			-- If the screen detects nothing, just make the end position twice the gun range using the ray direction.
			local endPosition = screenPart and screenPart.Position
				or (viewportPointRay.Origin + viewportPointRay.Direction.Unit * gun.range * 2)
			local dirFromRightHand = (endPosition - rightHand.Position).Unit

			local hitPart = workspace:Raycast(rightHand.Position, dirFromRightHand * gun.range, raycastParams)
			if hitPart then
				endPosition = hitPart.Position
			else
				endPosition = rightHand.Position + dirFromRightHand * gun.range
			end

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

			AnimationUtility.PlayAnimation(character, SHOOT_ANIMATION)

			-- Other clients will get this fired to them, do it here for instant feedback for high-ping users.
			VFXUtility.Gunshot(LocalPlayer.Character :: Model, endPosition)

			-- Instance can be nil if we missed, still send end position for visualizations on other clients.
			GunService.GunShot:Fire(serverEntity.id, endPosition, hitPart and hitPart.Instance)
		end
	end
end

return gunsShoot
