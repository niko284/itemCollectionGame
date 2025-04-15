--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService.Services
local Packages = ReplicatedStorage.Packages
local Utilities = ReplicatedStorage.Utilities
local Configuration = ReplicatedStorage.Configuration

local Assets = ServerStorage:FindFirstChild("assets") :: Folder 
local ItemsFolder = Assets:FindFirstChild("items") :: Folder

local ItemUtility = require(Utilities.ItemUtility)
local InventoryService = require(Services.InventoryService)
local Types = require(Configuration.Types)
local Items = require(Configuration.ItemConfig)
local GunConfig = require(Configuration.GunConfig)
local Matter = require(Packages.Matter)
local Freeze = require(Packages.Freeze)
local Components = require(ReplicatedStorage.ecs.components)


local EquipmentService = {
    Name = "EquipmentService",
    Client = {},
    World = nil :: Matter.World?,
}

function EquipmentService:KnitInit()

    InventoryService.InventoryLoaded:Connect(function(Player: Player, Inventory: Types.Inventory)
        for _, equippedItem in Inventory.Equipped do
            local itemInfo = ItemUtility.GetItemInfoFromName(equippedItem.Name)
            if itemInfo then
                EquipmentService:HandleItemEquipped(Player, equippedItem, itemInfo)
            end
        end
    end)

    InventoryService.ItemEquipped:Connect(function(Player, ItemUUID)
        local inventoryItem = InventoryService:GetItemFromUUID(Player, ItemUUID)

        if inventoryItem then
            local inventoryItemInfo = ItemUtility.GetItemInfoFromName(inventoryItem.Name)
            if inventoryItemInfo then
                EquipmentService:HandleItemEquipped(Player, inventoryItem, inventoryItemInfo)
            end
        end
    end)

    InventoryService.ItemUnequipped:Connect(function(Player, ItemUUID)
        local inventoryItem = InventoryService:GetItemFromUUID(Player, ItemUUID)

        if inventoryItem then
            local inventoryItemInfo = ItemUtility.GetItemInfoFromName(inventoryItem.Name)
            if inventoryItemInfo then
                EquipmentService:HandleItemUnequipped(Player, inventoryItem, inventoryItemInfo)
            end
        end
    end)
end

function EquipmentService:HandleItemEquipped(Player: Player, InventoryItem: Types.InventoryItem, ItemInfo: Types.ItemInfo)
    if ItemInfo.Type == "Gun" then
        -- Insert a gun component into our world.
        local world = EquipmentService.World
        if world then
            local gunData = table.clone(GunConfig[InventoryItem.Name])
            gunData.owner = Player -- Set the owner of the gun to the player.
            gunData.name = InventoryItem.Name
            world:spawn(Components.Gun(gunData))
        end
    end
end

function EquipmentService:HandleItemUnequipped(Player: Player, InventoryItem: Types.InventoryItem, ItemInfo: Types.ItemInfo)
    if ItemInfo.Type == "Gun" then
        -- Remove the gun component from our world.
        local world = EquipmentService.World
        if world then
            local gunEntity 
            for entity, gun: Components.Gun in world:query(Components.Gun) do
                if gun.owner == Player and gun.name == InventoryItem.Name then
                    gunEntity = entity 
                    break
                end
            end
            if gunEntity then
                world:despawn(gunEntity)
            end
        end
    end
end

function EquipmentService:DropTargetLoot(targetPosition: Vector3)
    local amountOfLoot = math.random(1, 3)

    -- Get all items that can be dropped by a target.

    local droppableItems = Freeze.List.filter(Items, function(itemInfo: Types.ItemInfo)
        local itemTypeInfo = ItemUtility.GetItemTypeInfoFromName(itemInfo.Type)
        if not itemTypeInfo then
            return false
        end
        return itemTypeInfo.SpawnedByTarget == true
    end)

    local randomItems = {} :: {Types.ItemInfo}

    for _ = 1, amountOfLoot do
        local randomIndex = math.random(1, #droppableItems)
        local randomItem = droppableItems[randomIndex]
        table.insert(randomItems, randomItem)
    end

    -- Find each items renderable model and spawn it at the target position. These are like "Pickupable" items.=
    -- that will get tagged by our ECS collection bootstrapper.

    for _, item in randomItems do
        local itemFolder = ItemsFolder:FindFirstChild(item.Name, true) :: Folder?
        if not itemFolder then
            warn("Item folder " .. item.Name .. " not found in items.")
            continue
        end
        local itemPickupable = itemFolder:FindFirstChild("Pickupable") :: Model?
        if not itemPickupable then
            warn("Item pickupable model not found in " .. itemFolder:GetFullName())
            continue
        end
        local itemClone = itemPickupable:Clone()
        itemClone:AddTag("Pickupable")
        itemClone:PivotTo(CFrame.new(targetPosition))
        itemClone.Parent = workspace 
    end
end

return EquipmentService