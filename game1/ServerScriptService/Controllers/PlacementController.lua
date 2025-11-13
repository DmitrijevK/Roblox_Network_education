local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local CatalogModule = require(ReplicatedStorage.Modules.CatalogModule)

local PlacementController = {}

local remotes
local currencyController

local playerZones = {}
local placementRecords = {}
local MAX_OBJECTS_PER_PLAYER = 200

local function getOrCreateZone(player)
	local root = Workspace:FindFirstChild("DataCenters")
	if not root then
		root = Instance.new("Folder")
		root.Name = "DataCenters"
		root.Parent = Workspace
	end
	local zone = root:FindFirstChild("DC_" .. player.UserId)
	if not zone then
		zone = Instance.new("Folder")
		zone.Name = "DC_" .. player.UserId
		zone.Parent = root
	end
	playerZones[player] = zone
	return zone
end

local function createPlaceholderPart(parent, size, name)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Metal
	part.Color = Color3.fromRGB(90, 122, 132)
	part.Parent = parent
	return part
end

-- Replace these functions with real model instantiation as assets become available.
local function createRack(parent, cframe)
	local model = Instance.new("Model")
	model.Name = "Rack"
	model.Parent = parent

	local base = createPlaceholderPart(model, Vector3.new(4, 8, 4), "Placeholder_Rack")
	base.CFrame = cframe

	model.PrimaryPart = base
	model:SetAttribute("RecordId", HttpService:GenerateGUID(false))
	return model
end

local function createServer(parent, cframe)
	local model = Instance.new("Model")
	model.Name = "ServerUnit"
	model.Parent = parent

	local base = createPlaceholderPart(model, Vector3.new(4, 2, 4), "Placeholder_Server")
	base.CFrame = cframe

	model.PrimaryPart = base
	model:SetAttribute("RecordId", HttpService:GenerateGUID(false))
	return model
end

local function createCable(parent, cframe)
	local model = Instance.new("Model")
	model.Name = "Cable"
	model.Parent = parent

	local cable = createPlaceholderPart(model, Vector3.new(1, 1, 6), "Placeholder_Cable")
	cable.Color = Color3.fromRGB(212, 165, 58)
	cable.CFrame = cframe
	cable:SetAttribute("CableHealth", 0)

	model.PrimaryPart = cable
	model:SetAttribute("RecordId", HttpService:GenerateGUID(false))
	return model
end

local itemFactories = {
	Rack = createRack,
	Server = createServer,
	Cable = createCable,
}

local function buildPlacementRecord(instance, itemName)
	local primary = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
	if not primary then
		return nil
	end
	local recordId = instance:GetAttribute("RecordId") or HttpService:GenerateGUID(false)
	return {
		id = recordId,
		itemName = itemName,
		position = {primary.Position.X, primary.Position.Y, primary.Position.Z},
		cframe = primary.CFrame,
		attributes = {
			CableHealth = primary:GetAttribute("CableHealth"),
		},
	}
end

local function getPlacementCount(player)
	local records = placementRecords[player]
	if not records then
		return 0
	end
	return #records
end

local function validatePlacement(player, payload)
	if typeof(payload) ~= "table" then
		return false, "Invalid payload."
	end
	local itemName = payload.itemName
	local itemData = CatalogModule.GetItem(itemName)
	if not itemData then
		return false, "Unknown item."
	end
	if getPlacementCount(player) >= MAX_OBJECTS_PER_PLAYER then
		return false, "Object limit reached."
	end
	local cframe = payload.cframe
	if typeof(cframe) ~= "CFrame" then
		return false, "Invalid transform."
	end
	local size = payload.size or itemData.placement.size
	if typeof(size) ~= "Vector3" then
		return false, "Invalid size."
	end
	local zone = getOrCreateZone(player)
	local region = Region3.new(
		(cframe.Position - size / 2),
		(cframe.Position + size / 2)
	)
	local parts = Workspace:FindPartsInRegion3WithIgnoreList(region, {zone}, 10)
	if #parts > 0 then
		return false, "Collision detected."
	end
	return true, itemData
end

function PlacementController.init(context, currencyCtrl)
	remotes = context.remotes
	currencyController = currencyCtrl

	remotes.PlaceItem.OnServerEvent:Connect(function(player, payload)
		local allowed, itemData = validatePlacement(player, payload)
		if not allowed then
			remotes.ConfirmPlace:FireClient(player, {
				success = false,
				reason = itemData,
			})
			return
		end

		local cost = itemData.cost or 0
		if cost > 0 and not currencyController.purchase(player, cost) then
			remotes.ConfirmPlace:FireClient(player, {
				success = false,
				reason = "Insufficient funds.",
			})
			return
		end

		local zone = getOrCreateZone(player)
		local factory = itemFactories[payload.itemName]
		if not factory then
			currencyController.refund(player, cost)
			remotes.ConfirmPlace:FireClient(player, {
				success = false,
				reason = "No factory for item.",
			})
			return
		end

		local model = factory(zone, payload.cframe)
		if not model then
			currencyController.refund(player, cost)
			remotes.ConfirmPlace:FireClient(player, {
				success = false,
				reason = "Failed to spawn item.",
			})
			return
		end

		local record = buildPlacementRecord(model, payload.itemName)
		placementRecords[player] = placementRecords[player] or {}
		table.insert(placementRecords[player], record)

		remotes.ConfirmPlace:FireClient(player, {
			success = true,
			itemName = payload.itemName,
			cost = cost,
			recordId = record.id,
			minigame = itemData.triggersMinigame and {
				type = itemData.minigameType,
				duration = itemData.duration,
				recordId = record.id,
			} or nil,
		})
	end)
end

function PlacementController.restorePlacements(player, placements)
	local zone = getOrCreateZone(player)
	placementRecords[player] = {}
	for _, placement in ipairs(placements) do
		local itemData = CatalogModule.GetItem(placement.itemName)
		if itemData and itemFactories[placement.itemName] then
			local model = itemFactories[placement.itemName](zone, placement.cframe)
			if model and model.PrimaryPart then
				if placement.attributes and placement.attributes.CableHealth then
					model.PrimaryPart:SetAttribute("CableHealth", placement.attributes.CableHealth)
				end
				table.insert(placementRecords[player], placement)
			end
		end
	end
end

function PlacementController.getPlacementRecords(player)
	return placementRecords[player] or {}
end

function PlacementController.getZone(player)
	return playerZones[player] or getOrCreateZone(player)
end

function PlacementController.cleanup(player)
	local zone = playerZones[player]
	if zone then
		zone:Destroy()
	end
	playerZones[player] = nil
	placementRecords[player] = nil
end

return PlacementController

