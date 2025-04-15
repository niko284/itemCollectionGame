--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Configuration = ReplicatedStorage.Configuration
local Packages = ReplicatedStorage.Packages
local Controllers = LocalPlayer.PlayerScripts.Controllers
local Utilities = ReplicatedStorage.Utilities

local InventoryUtility = require(Utilities.InventoryUtility)
local StringUtility = require(Utilities.StringUtility)
local Types = require(Configuration.Types)
local Fusion = require(Packages.Fusion)
local InventoryController = require(Controllers.InventoryController)
local ItemTemplate = require(script.ItemTemplate)
local GlobalState = require(script.Parent.GlobalState)
local Searchbar = require(script.Parent.other.Searchbar)

local Children = Fusion.Children
local New = Fusion.New
local Cleanup = Fusion.Cleanup
local Value = Fusion.Value
local Tween = Fusion.Tween
local ForPairs = Fusion.ForPairs
local Computed = Fusion.Computed

type InventoryProps = {}

local function Inventory(_props: InventoryProps)
	local currentInventory = Value(nil)
	local searchQuery = Value(nil)

	local isOpen = Computed(function()
		return GlobalState.currentHUD:get() == "Inventory"
	end)

	local inventoryPosition = Computed(function()
		if isOpen:get() then
			return UDim2.fromScale(0.332, 0.259)
		else
			return UDim2.fromScale(0.332, 1.5)
		end
	end)

	local positionTween = Tween(inventoryPosition, TweenInfo.new(1, Enum.EasingStyle.Quad))

	local inventoryChanged = InventoryController.InventoryChanged:Connect(function(newInventory: Types.Inventory)
		currentInventory:set(table.clone(newInventory))
	end)

	local inventoryItems = Computed(function()
		local items = {}
		local inventory = currentInventory:get()

		if inventory then
			for _, item in inventory.Equipped do
				if not StringUtility.MatchesSearch(item.Name, searchQuery:get() :: string?) then
					continue
				end
				table.insert(items, item)
			end
			for _, item in inventory.Storage do
				if not StringUtility.MatchesSearch(item.Name, searchQuery:get() :: string?) then
					continue
				end
				table.insert(items, item)
			end
		end

		return items
	end)

	return New("Frame")({
		Name = "inventoryMain",
		BackgroundColor3 = Color3.fromRGB(53, 53, 53),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = positionTween,
		Size = UDim2.fromScale(0.335, 0.481),

		[Cleanup] = function()
			inventoryChanged:Disconnect()
		end,

		[Children] = {
			Searchbar({
				size = UDim2.fromScale(0.34, 0.11),
				position = UDim2.fromScale(0.02, 0.037),
				onChange = function(newText: string)
					searchQuery:set(newText)
				end,
			}),

			New("ScrollingFrame")({
				Name = "itemScroll",
				ScrollBarThickness = 9,
				Active = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.0278, 0.198),
				Size = UDim2.fromScale(0.944, 0.759),
				CanvasSize = UDim2.fromScale(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,

				[Children] = {
					New("UIGridLayout")({
						Name = "UIGridLayout",
						CellSize = UDim2.fromOffset(125, 125),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					ForPairs(inventoryItems, function(index, item: Types.InventoryItem)
						return index,
							ItemTemplate({
								itemName = item.Name,
								layoutOrder = index,
								isEquipped = InventoryUtility.IsEquipped(currentInventory:get() :: any, item.UUID),
								itemUUID = item.UUID,
							}) :: any
					end, function(_, template)
						template:Destroy()
					end) :: any,
				},
			}),
		},
	})
end

return Inventory
