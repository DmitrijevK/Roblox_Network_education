local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ModulesFolder = ReplicatedStorage:FindFirstChild("Modules") or Instance.new("Folder")
ModulesFolder.Name = "Modules"
ModulesFolder.Parent = ReplicatedStorage

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote(remoteType, name)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new(remoteType)
		remote.Name = name
		remote.Parent = remotesFolder
	end
	return remote
end

local remotes = {
	PlaceItem = ensureRemote("RemoteEvent", "PlaceItem"),
	ConfirmPlace = ensureRemote("RemoteEvent", "ConfirmPlace"),
	RequestCatalog = ensureRemote("RemoteEvent", "RequestCatalog"),
	StartMinigame = ensureRemote("RemoteEvent", "StartMinigame"),
	TerminalCommand = ensureRemote("RemoteEvent", "TerminalCommand"),
	InvitePlayer = ensureRemote("RemoteEvent", "InvitePlayer"),
	AcceptInvite = ensureRemote("RemoteEvent", "AcceptInvite"),
}

local controllersFolder = ServerScriptService:FindFirstChild("Controllers")
if not controllersFolder then
	error("[Bootstrap] Controllers folder missing.")
end

local DataController = require(controllersFolder:WaitForChild("DataController"))
local CurrencyController = require(controllersFolder:WaitForChild("CurrencyController"))
local PlacementController = require(controllersFolder:WaitForChild("PlacementController"))
local MinigameController = require(controllersFolder:WaitForChild("MinigameController"))

local controllerContext = {
	remotes = remotes,
}

CurrencyController.init(controllerContext)
PlacementController.init(controllerContext, CurrencyController)
MinigameController.init(controllerContext, PlacementController)
DataController.init(controllerContext, CurrencyController, PlacementController)

Players.PlayerRemoving:Connect(function(player)
	PlacementController.cleanup(player)
	CurrencyController.cleanup(player)
	DataController.cleanup(player)
	MinigameController.cleanup(player)
end)

