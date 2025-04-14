--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Configuration = ReplicatedStorage.Configuration
local Packages = ReplicatedStorage.Packages

local Types = require(Configuration.Types)
local Lapis = require(Packages.Lapis)
local t = require(Packages.t)
local Signal = require(Packages.Signal)

local collectionName = RunService:IsStudio() and "Documents_Studio!" or "ItemCollectionDocuments"

local collectionInternal = Lapis.createCollection(collectionName, {
	defaultData = require(script.DocumentSchema) :: Types.PlayerDocument,
	validate = t.strictInterface({
		Inventory = t.strictInterface({
			Storage = t.table,
			Equipped = t.table,
			GrantedDefaults = t.array(t.string),
		}),
	}),
})

local PlayerDataService = {
	Name = "PlayerDataService",
	Client = {},
	DocumentLoaded = Signal.new(),

	_documents = {},
	_collection = collectionInternal,
}

function PlayerDataService:KnitInit()
	for _, player in Players:GetPlayers() do
		PlayerDataService:LoadDocument(player)
	end
	Players.PlayerAdded:Connect(function(player: Player)
		PlayerDataService:LoadDocument(player)
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		PlayerDataService:CloseDocument(player)
	end)
end

function PlayerDataService:LoadDocument(Player: Player)
	local playerKey = string.format("Document_%d", Player.UserId)
	PlayerDataService._collection
		:load(playerKey)
		:andThen(function(document)
			if Player:IsDescendantOf(Players) == false then
				document:close():catch(warn)
				return
			end

			PlayerDataService._documents[Player.UserId] = document

			PlayerDataService.DocumentLoaded:Fire(Player, document)
		end)
		:catch(function(err: any)
			warn(`Player {Player.Name}'s data failed to load: {err}`)
			Player:Kick("Data failed to load.")
		end)
end

function PlayerDataService:GetDocument(Player: Player)
	return PlayerDataService._documents[Player.UserId]
end

function PlayerDataService:CloseDocument(Player: Player)
	local document = PlayerDataService._documents[Player.UserId]
	if document ~= nil then
		PlayerDataService._documents[Player.UserId] = nil
		document:close():catch(warn)
	end
end

return PlayerDataService
