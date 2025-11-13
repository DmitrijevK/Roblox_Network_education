local MinigameController = {}

local remotes
local placementController

local activeCrimps = {}

function MinigameController.init(context, placementCtrl)
	remotes = context.remotes
	placementController = placementCtrl

	remotes.StartMinigame.OnServerEvent:Connect(function(player, payload)
		if typeof(payload) ~= "table" or payload.type ~= "CRIMP_RESULT" then
			return
		end
		local session = activeCrimps[player]
		if not session or session.cableId ~= payload.cableId then
			return
		end
		activeCrimps[player] = nil
		local zone = placementController.getZone(player)
		if not zone then
			return
		end
		for _, model in ipairs(zone:GetChildren()) do
			if model:IsA("Model") and model.PrimaryPart and model:GetAttribute("RecordId") == payload.cableId then
				model.PrimaryPart:SetAttribute("CableHealth", payload.success and 1 or 0.3)
				break
			end
		end
	end)

	remotes.ConfirmPlace.OnClientEvent = nil
end

function MinigameController.registerCrimp(player, record)
	activeCrimps[player] = {
		cableId = record.id,
	}
end

function MinigameController.onPlacementConfirmed(player, response)
	if response.success and response.minigame and response.minigame.type == "CRIMP" then
		activeCrimps[player] = {
			cableId = response.recordId,
			duration = response.minigame.duration,
		}
		remotes.StartMinigame:FireClient(player, {
			type = "CRIMP_PROMPT",
			cableId = response.recordId,
			duration = response.minigame.duration,
		})
	end
end

function MinigameController.cleanup(player)
	activeCrimps[player] = nil
end

return MinigameController

