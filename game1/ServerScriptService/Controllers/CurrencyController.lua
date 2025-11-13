local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyManager = require(ReplicatedStorage.Modules.CurrencyManager)

local CurrencyController = {}

local currencyManager = CurrencyManager.new()
local remotes

function CurrencyController.init(context)
	remotes = context.remotes
end

function CurrencyController.loadProfile(player, startingBalance)
	currencyManager:SetBalance(player, startingBalance)
end

function CurrencyController.getBalance(player)
	return currencyManager:GetBalance(player)
end

function CurrencyController.purchase(player, cost)
	return currencyManager:Purchase(player, cost)
end

function CurrencyController.refund(player, amount)
	currencyManager:AddBalance(player, amount)
end

function CurrencyController.reward(player, amount)
	currencyManager:AddBalance(player, amount)
end

function CurrencyController.cleanup(player)
	currencyManager:RemovePlayer(player)
end

return CurrencyController

