--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage.Packages

local Components = require(ReplicatedStorage.ecs.components)
local Matter = require(Packages.Matter)

local RNG = Random.new(workspace:GetServerTimeNow())

local function targetsMove(world: Matter.World)
	local now = DateTime.now().UnixTimestampMillis
	for eid, target: Components.Target, renderable: Components.Renderable<Model> in
		world:query(Components.Target, Components.Renderable)
	do
		-- Wait for the previous move to finish before starting a new one.
		if
			(target.moveTween == nil or target.moveTween.PlaybackState == Enum.PlaybackState.Completed)
			and not target.falling
		then
			if not target.expirationTimeMs then
				target = target:patch({
					expirationTimeMs = now + target.lifetimeMs,
				})
				world:insert(eid, target)
			end

			local renderablePrimaryPart = renderable.pvInstance.PrimaryPart :: BasePart
			local currentPosition = renderablePrimaryPart.Position

			local targetPosition = currentPosition + (RNG:NextUnitVector() * target.radius)
			local timeToArrive = (currentPosition - targetPosition).Magnitude / target.speed
			local targetTweenInfo = TweenInfo.new(timeToArrive, target.easingStyle, target.easingDirection)
			local tweenGoals = {
				Position = targetPosition,
			}

			local targetTween = TweenService:Create(renderablePrimaryPart, targetTweenInfo, tweenGoals)
			target = target:patch({
				moveTween = targetTween,
			})
			targetTween:Play()

			world:insert(eid, target)
		end
	end
end

return targetsMove
