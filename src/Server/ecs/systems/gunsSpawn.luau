--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Assets = ServerStorage:FindFirstChild("assets") :: Folder 
local Items = Assets:FindFirstChild("items") :: Folder
local Guns = Items:FindFirstChild("guns") :: Folder

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.ecs.components)

local function gunsSpawn(world: Matter.World)
    
    -- Add renderables to guns without them (if it was just spawned)
    for eid, gun: Components.Gun in world:query(Components.Gun):without(Components.Renderable) do
        local gunFolder = Guns:FindFirstChild(gun.name) :: Folder 
        if gunFolder then
            local gunAttach = gunFolder:FindFirstChildOfClass("Accessory") :: Accessory 

            local ownerCharacter = gun.owner.Character 
            if ownerCharacter then
                
                local ownerHumanoid = ownerCharacter:FindFirstChildOfClass("Humanoid") :: Humanoid
                if ownerHumanoid then
                    local attachClone = gunAttach:Clone() :: Accessory 
                    ownerHumanoid:AddAccessory(attachClone)

                    world:insert(eid, Components.Renderable({
                        pvInstance = attachClone,
                    }))
                end
            end
        end
    end
end

return gunsSpawn 