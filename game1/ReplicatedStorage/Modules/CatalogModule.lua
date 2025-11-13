local CatalogModule = {}

-- Core catalog definition. Extend cost/unlockLevel as progression systems mature.
CatalogModule.Items = {
	["Rack"] = {
		displayName = "Rack",
		cost = 200,
		unlockLevel = 1,
		category = "Infrastructure",
		placement = {
			size = Vector3.new(4, 8, 4),
			grid = 4,
		},
		modelHook = "Placeholder_Rack", -- Replace with real model (see README).
	},
	["Server"] = {
		displayName = "Server Unit",
		cost = 150,
		unlockLevel = 1,
		category = "Compute",
		placement = {
			size = Vector3.new(4, 2, 4),
			grid = 4,
		},
		modelHook = "Placeholder_Server",
	},
	["Cable"] = {
		displayName = "Copper Cable",
		cost = 50,
		unlockLevel = 1,
		category = "Networking",
		placement = {
			size = Vector3.new(1, 1, 6),
			grid = 2,
		},
		modelHook = "Placeholder_Cable",
		triggersMinigame = true,
		minigameType = "CRIMP",
		duration = 3,
	},
}

function CatalogModule.GetAllItems()
	return CatalogModule.Items
end

function CatalogModule.GetItem(name)
	return CatalogModule.Items[name]
end

-- Helper for level-locked catalogs.
function CatalogModule.GetUnlockedItems(level)
	local unlocked = {}
	for name, data in pairs(CatalogModule.Items) do
		if level >= (data.unlockLevel or 1) then
			unlocked[name] = data
		end
	end
	return unlocked
end

return CatalogModule

