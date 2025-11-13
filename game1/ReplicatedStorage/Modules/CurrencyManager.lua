local CurrencyManager = {}
CurrencyManager.__index = CurrencyManager

local DEFAULT_BALANCE = 1000

function CurrencyManager.new()
	local self = setmetatable({}, CurrencyManager)
	self._balances = {}
	return self
end

function CurrencyManager:GetBalance(player)
	return self._balances[player] or DEFAULT_BALANCE
end

function CurrencyManager:SetBalance(player, amount)
	self._balances[player] = amount
	player:SetAttribute("Currency", amount)
end

function CurrencyManager:AddBalance(player, delta)
	local newBalance = self:GetBalance(player) + delta
	self:SetBalance(player, math.max(newBalance, 0))
	return self:GetBalance(player)
end

function CurrencyManager:CanAfford(player, cost)
	return self:GetBalance(player) >= cost
end

function CurrencyManager:Purchase(player, cost)
	if self:CanAfford(player, cost) then
		self:AddBalance(player, -cost)
		return true
	end
	return false
end

function CurrencyManager:RemovePlayer(player)
	self._balances[player] = nil
end

return CurrencyManager

