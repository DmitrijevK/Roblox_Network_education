local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local DatastoreModule = {}
DatastoreModule.__index = DatastoreModule

local MAX_RETRIES = 3
local RETRY_WAIT = 2
local PROFILE_TEMPLATE = {
	currency = 1000,
	level = 1,
	xp = 0,
	placements = {},
}

local function deepCopy(tbl)
	local clone = {}
	for key, value in pairs(tbl) do
		if typeof(value) == "table" then
			clone[key] = deepCopy(value)
		else
			clone[key] = value
		end
	end
	return clone
end

local function mergeTemplate(data)
	local merged = deepCopy(PROFILE_TEMPLATE)
	if type(data) ~= "table" then
		return merged
	end
	for key, value in pairs(data) do
		if typeof(value) == "table" then
			merged[key] = deepCopy(value)
		else
			merged[key] = value
		end
	end
	return merged
end

function DatastoreModule.new(storeName)
	local self = setmetatable({}, DatastoreModule)
	self._store = DataStoreService:GetDataStore(storeName)
	return self
end

function DatastoreModule:LoadProfile(key)
	local retries = 0
	while retries < MAX_RETRIES do
		retries += 1
		local success, data = pcall(function()
			return self._store:GetAsync(key)
		end)
		if success then
			return mergeTemplate(data or PROFILE_TEMPLATE)
		end
		warn(("[Datastore] Load failed for %s (%s). Retrying %d/%d")
			:format(key, data, retries, MAX_RETRIES))
		task.wait(RETRY_WAIT * retries)
	end
	if RunService:IsStudio() then
		warn("[Datastore] Falling back to template in Studio.")
		return deepCopy(PROFILE_TEMPLATE)
	end
	error("[Datastore] Unable to load profile for " .. key)
end

function DatastoreModule:SaveProfile(key, profile)
	local payload = deepCopy(profile)
	local retries = 0
	while retries < MAX_RETRIES do
		retries += 1
		local success, err = pcall(function()
			self._store:SetAsync(key, payload)
		end)
		if success then
			return true
		end
		warn(("[Datastore] Save failed for %s (%s). Retrying %d/%d")
			:format(key, err, retries, MAX_RETRIES))
		task.wait(RETRY_WAIT * retries)
	end
	return false
end

function DatastoreModule:SerializePlacement(instance, meta)
	local orientation = instance.CFrame - instance.CFrame.Position
	return {
		id = meta.id or HttpService:GenerateGUID(false),
		itemName = meta.itemName,
		position = {instance.Position.X, instance.Position.Y, instance.Position.Z},
		orientation = {orientation.X.X, orientation.X.Y, orientation.X.Z,
			orientation.Y.X, orientation.Y.Y, orientation.Y.Z,
			orientation.Z.X, orientation.Z.Y, orientation.Z.Z},
		attributes = meta.attributes or {},
	}
end

return DatastoreModule

