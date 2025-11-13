local ReplicatedStorage = game:GetService("ReplicatedStorage")

local modules = ReplicatedStorage:WaitForChild("Modules")
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

local PlacementSystemModule = require(modules:WaitForChild("PlacementSystem"))
local CatalogModule = require(modules:WaitForChild("CatalogModule"))
local CrimpMinigameModule = require(modules:WaitForChild("CrimpMinigame"))
local UIBinderModule = require(modules:WaitForChild("UIBinder"))

local remotes = {
	PlaceItem = remotesFolder:WaitForChild("PlaceItem"),
	ConfirmPlace = remotesFolder:WaitForChild("ConfirmPlace"),
	RequestCatalog = remotesFolder:WaitForChild("RequestCatalog"),
	StartMinigame = remotesFolder:WaitForChild("StartMinigame"),
	TerminalCommand = remotesFolder:WaitForChild("TerminalCommand"),
	InvitePlayer = remotesFolder:WaitForChild("InvitePlayer"),
	AcceptInvite = remotesFolder:WaitForChild("AcceptInvite"),
}

local ui = UIBinderModule.new()
ui:BindCurrencyAttributes()

local placement = PlacementSystemModule.new(remotes, CatalogModule, ui)
placement:Bind()

ui:BindPlacementCallback(function(itemName)
	placement:BeginPlacement(itemName)
end)

remotes.RequestCatalog.OnClientEvent:Connect(function(levelOrCatalog)
	if typeof(levelOrCatalog) == "number" then
		ui:PopulateCatalog(CatalogModule.GetUnlockedItems(levelOrCatalog))
	else
		ui:PopulateCatalog(levelOrCatalog)
	end
end)

remotes.StartMinigame.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	if payload.type == "CRIMP_PROMPT" then
		local minigame = CrimpMinigameModule.new(remotes, ui)
		minigame:Start(payload)
	end
end)

-- Request initial catalog sync; server replies with level-based list.
remotes.RequestCatalog:FireServer()

