local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DatastoreModule = require(ReplicatedStorage.Modules.DatastoreModule)

local DataController = {}

local PROFILE_STORE = "PracticeSysAdminProfiles"
local datastore = DatastoreModule.new(PROFILE_STORE)
local playerProfiles = {}

local PlacementController
local CurrencyController
local remotes

local function getProfileKey(player)
	return ("DC_%d_Profile"):format(player.UserId)
end

function DataController.init(context, currencyController, placementController)
	remotes = context.remotes
	CurrencyController = currencyController
	PlacementController = placementController

	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			local profile = datastore:LoadProfile(getProfileKey(player))
			playerProfiles[player] = profile
			CurrencyController.loadProfile(player, profile.currency or 0)
			player:SetAttribute("Level", profile.level or 1)
			player:SetAttribute("XP", profile.xp or 0)
			PlacementController.restorePlacements(player, profile.placements or {})
			context.remotes.RequestCatalog:FireClient(player, profile.level or 1)
		end)
	end)

	remotes.RequestCatalog.OnServerEvent:Connect(function(player)
		local profile = playerProfiles[player]
		local level = profile and profile.level or 1
		remotes.RequestCatalog:FireClient(player, level)
	end)
end

local function serializePlacementsForPlayer(player)
	local placements = {}
	for _, record in ipairs(PlacementController.getPlacementRecords(player)) do
		table.insert(placements, record)
	end
	return placements
end

function DataController.cleanup(player)
	local profile = playerProfiles[player]
	if not profile then
		return
	end

	profile.currency = CurrencyController.getBalance(player)
	profile.level = player:GetAttribute("Level") or profile.level or 1
	profile.xp = player:GetAttribute("XP") or profile.xp or 0
	profile.placements = serializePlacementsForPlayer(player)

	local success = datastore:SaveProfile(getProfileKey(player), profile)
	if not success then
		warn("[DataController] Failed to save profile for", player)
	end
	playerProfiles[player] = nil
end

function DataController.registerPlacement(player, record)
	local profile = playerProfiles[player]
	if not profile then
		return
	end
	table.insert(profile.placements, record)
end

function DataController.getProfile(player)
	return playerProfiles[player]
end

return DataController

