local RunService = game:GetService("RunService")

local CrimpMinigame = {}
CrimpMinigame.__index = CrimpMinigame

function CrimpMinigame.new(remotes, uiBinder)
	local self = setmetatable({}, CrimpMinigame)
	self._remotes = remotes
	self._ui = uiBinder
	self._activeSession = nil
	self._heartbeatConn = nil
	return self
end

function CrimpMinigame:Start(sessionData)
	if self._activeSession then
		self:Cancel()
	end
	self._activeSession = {
		cableId = sessionData.cableId,
		duration = sessionData.duration or 3,
		elapsed = 0,
	}
	self._ui:ShowMinigame({
		title = "Crimp Cable",
		description = "Hold steady – click the button when the bar turns green!",
		buttonText = "Crimp Now",
		progress = 0,
		onButton = function()
			self:Complete(true)
		end,
	})
	self._heartbeatConn = RunService.Heartbeat:Connect(function(dt)
		if not self._activeSession then
			return
		end
		self._activeSession.elapsed += dt
		local ratio = math.clamp(self._activeSession.elapsed / self._activeSession.duration, 0, 1)
		self._ui:UpdateMinigameProgress(ratio)
		if ratio >= 1 then
			self:Complete(false)
		end
	end)
end

function CrimpMinigame:Complete(success)
	if not self._activeSession then
		return
	end
	self:_disconnectHeartbeat()
	self._ui:HideMinigame()
	self._remotes.StartMinigame:FireServer({
		type = "CRIMP_RESULT",
		cableId = self._activeSession.cableId,
		success = success,
	})
	if success then
		self._ui:ShowMessage("Crimp successful! Cable health high.", Color3.fromRGB(122, 255, 122))
	else
		self._ui:ShowMessage("Crimp failed. Cable may be unstable.", Color3.fromRGB(255, 96, 96))
	end
	self._activeSession = nil
end

function CrimpMinigame:Cancel()
	self:_disconnectHeartbeat()
	self._ui:HideMinigame()
	self._activeSession = nil
end

function CrimpMinigame:_disconnectHeartbeat()
	if self._heartbeatConn then
		self._heartbeatConn:Disconnect()
		self._heartbeatConn = nil
	end
end

return CrimpMinigame

