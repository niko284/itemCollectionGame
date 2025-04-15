--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = ReplicatedStorage.Configuration

local Types = require(Configuration.Types)

local SoundUtility = {
    _cache = {}
}

function SoundUtility.LoadSound(Sound: Types.Sound): Sound
    if SoundUtility._cache[Sound.Id] then
        return SoundUtility._cache[Sound.Id]
    end
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. Sound.Id
	sound.Looped = Sound.Looped
    sound.Volume = Sound.Volume
    SoundUtility._cache[Sound.Id] = sound
	return sound
end

function SoundUtility.PlaySoundOnInstance(Sound: Types.Sound, instance: Instance): ()
	local sound = SoundUtility.LoadSound(Sound):Clone()
	sound.Parent = instance
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
end


return SoundUtility