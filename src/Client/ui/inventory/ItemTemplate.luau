--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Packages = ReplicatedStorage.Packages
local Controllers = LocalPlayer.PlayerScripts.Controllers

local Types = require(ReplicatedStorage.Configuration.Types)
local Fusion = require(Packages.Fusion)
local InventoryUtility = require(ReplicatedStorage.Utilities.InventoryUtility)
local InventoryController = require(Controllers.InventoryController)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

export type ItemTemplateProps = {
	isEquipped: boolean,
	itemName: string,
	layoutOrder: number,
	itemUUID: string,
}

local function ItemTemplate(props: ItemTemplateProps)
	return New("Frame")({
		Name = "itemTemplate",
		BackgroundColor3 = props.isEquipped and Color3.fromRGB(33, 155, 33) or Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,

		[Children] = {
			New("TextButton")({
				Name = "equipButton",
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				Text = props.itemName,
				TextColor3 = props.isEquipped and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
				TextScaled = true,
				TextSize = 14,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),

				[OnEvent("Activated")] = function()
					-- let's do some client side prediction!

					local oldInventory = InventoryController:GetInventory()
					if not oldInventory then
						return
					end

					local equippedInventory = not props.isEquipped
							and InventoryUtility.EquipItem(oldInventory, props.itemUUID)
						or InventoryUtility.UnequipItem(oldInventory, props.itemUUID)
					InventoryController:SetInventory(equippedInventory)

					if not props.isEquipped then
						InventoryController.InventoryService
							:EquipItem(props.itemUUID)
							:andThen(function(response: Types.NetworkResponse)
								if response.Success == false then
									-- revert the inventory to the old one if we failed to equip the item on the server.
									InventoryController:SetInventory(oldInventory)
								end
							end)
							:catch(function(err)
								warn(tostring(err))
								-- revert the inventory to the old one if we failed to equip the item on the server.
								InventoryController:SetInventory(oldInventory)
							end)
					else
						InventoryController.InventoryService
							:UnequipItem(props.itemUUID)
							:andThen(function(response: Types.NetworkResponse)
								if response.Success == false then
									-- revert the inventory to the old one if we failed to equip the item on the server.
									InventoryController:SetInventory(oldInventory)
								end
							end)
							:catch(function(err)
								warn(tostring(err))
								-- revert the inventory to the old one if we failed to equip the item on the server.
								InventoryController:SetInventory(oldInventory)
							end)
					end
				end,
			}),
		},
	})
end

return ItemTemplate
