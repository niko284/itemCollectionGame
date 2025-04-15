--!strict

local AnimationUtility = {}

function AnimationUtility.PlayAnimation(Character: Model?, Animation: Animation): AnimationTrack?
	if not Character then
		return nil
	end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		return nil
	end
	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then
		return nil
	end
	local animationTrack = Animator:LoadAnimation(Animation)
	animationTrack:Play()
	return animationTrack
end

return AnimationUtility
