--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = ReplicatedStorage.Configuration

local Types = require(Configuration.Types)

return {
    Gunshot = {
        Id = 1583819337,
        Volume = 0.5,
        Looped = false,
    }
} :: {[string]: Types.Sound}