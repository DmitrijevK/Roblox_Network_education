local Players = game:GetService("Players")

local UIBinder = {}
UIBinder.__index = UIBinder

function UIBinder.new()
	local self = setmetatable({}, UIBinder)
	self._player = Players.LocalPlayer
	self._placementCallback = nil
	self._screenGui = Instance.new("ScreenGui")
	self._screenGui.Name = "PracticeSysAdminUI"
	self._screenGui.ResetOnSpawn = false
	self._screenGui.IgnoreGuiInset = true
	self._screenGui.Parent = self._player:WaitForChild("PlayerGui")

	self:_buildHUD()
	self:_buildCatalog()
	self:_buildMinigameOverlay()
	return self
end

function UIBinder:_buildHUD()
	local hudFrame = Instance.new("Frame")
	hudFrame.Name = "HUD"
	hudFrame.Size = UDim2.new(0, 250, 0, 110)
	hudFrame.BackgroundTransparency = 0.3
	hudFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
	hudFrame.BorderSizePixel = 0
	hudFrame.Position = UDim2.new(0, 12, 0, 12)
	hudFrame.Parent = self._screenGui

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Text = "SysAdmin Apprentice"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 10, 0, 8)
	title.Size = UDim2.new(1, -20, 0, 20)
	title.Parent = hudFrame

	local currencyLabel = Instance.new("TextLabel")
	currencyLabel.Name = "Currency"
	currencyLabel.Text = "Currency: 0"
	currencyLabel.Font = Enum.Font.Gotham
	currencyLabel.TextSize = 16
	currencyLabel.TextColor3 = Color3.fromRGB(226, 241, 255)
	currencyLabel.BackgroundTransparency = 1
	currencyLabel.Position = UDim2.new(0, 10, 0, 34)
	currencyLabel.Size = UDim2.new(1, -20, 0, 20)
	currencyLabel.Parent = hudFrame

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "Level"
	levelLabel.Text = "Level: 1"
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextSize = 16
	levelLabel.TextColor3 = Color3.fromRGB(226, 241, 255)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Position = UDim2.new(0, 10, 0, 56)
	levelLabel.Size = UDim2.new(1, -20, 0, 20)
	levelLabel.Parent = hudFrame

	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "Message"
	messageLabel.Text = ""
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextWrapped = true
	messageLabel.TextSize = 14
	messageLabel.TextColor3 = Color3.new(1, 1, 1)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Position = UDim2.new(0, 10, 0, 78)
	messageLabel.Size = UDim2.new(1, -20, 0, 24)
	messageLabel.Parent = hudFrame

	self._hud = {
		frame = hudFrame,
		currency = currencyLabel,
		level = levelLabel,
		message = messageLabel,
	}
end

function UIBinder:_buildCatalog()
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "CatalogToggle"
	toggleButton.Text = "Catalog"
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.TextSize = 18
	toggleButton.BackgroundColor3 = Color3.fromRGB(50, 96, 168)
	toggleButton.Size = UDim2.new(0, 140, 0, 40)
	toggleButton.Position = UDim2.new(1, -160, 1, -60)
	toggleButton.AnchorPoint = Vector2.new(0, 1)
	toggleButton.Parent = self._screenGui

	local catalogFrame = Instance.new("Frame")
	catalogFrame.Name = "Catalog"
	catalogFrame.Visible = false
	catalogFrame.Size = UDim2.new(0, 280, 0, 320)
	catalogFrame.Position = UDim2.new(1, -300, 1, -380)
	catalogFrame.AnchorPoint = Vector2.new(0, 1)
	catalogFrame.BackgroundTransparency = 0.2
	catalogFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
	catalogFrame.BorderSizePixel = 0
	catalogFrame.Parent = self._screenGui

	local header = Instance.new("TextLabel")
	header.Text = "Build Catalog"
	header.Font = Enum.Font.GothamBold
	header.TextSize = 18
	header.TextColor3 = Color3.new(1, 1, 1)
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, -20, 0, 24)
	header.Position = UDim2.new(0, 10, 0, 10)
	header.Parent = catalogFrame

	local list = Instance.new("ScrollingFrame")
	list.Name = "List"
	list.Size = UDim2.new(1, -20, 1, -50)
	list.Position = UDim2.new(0, 10, 0, 44)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.ScrollBarThickness = 6
	list.Parent = catalogFrame

	toggleButton.MouseButton1Click:Connect(function()
		catalogFrame.Visible = not catalogFrame.Visible
	end)

	self._catalog = {
		frame = catalogFrame,
		list = list,
		toggle = toggleButton,
	}
end

function UIBinder:_buildMinigameOverlay()
	local overlay = Instance.new("Frame")
	overlay.Name = "MinigameOverlay"
	overlay.Visible = false
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundTransparency = 0.4
	overlay.BackgroundColor3 = Color3.fromRGB(12, 12, 24)
	overlay.Parent = self._screenGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 360, 0, 220)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
	panel.BorderSizePixel = 0
	panel.Parent = overlay

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.new(0, 10, 0, 12)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Parent = panel

	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.Size = UDim2.new(1, -20, 0, 60)
	description.Position = UDim2.new(0, 10, 0, 52)
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.Gotham
	description.TextWrapped = true
	description.TextSize = 16
	description.TextColor3 = Color3.fromRGB(214, 226, 255)
	description.Parent = panel

	local barBackground = Instance.new("Frame")
	barBackground.Name = "ProgressBg"
	barBackground.Size = UDim2.new(1, -40, 0, 18)
	barBackground.Position = UDim2.new(0, 20, 0, 122)
	barBackground.BackgroundColor3 = Color3.fromRGB(12, 24, 52)
	barBackground.BorderSizePixel = 0
	barBackground.Parent = panel

	local barFill = Instance.new("Frame")
	barFill.Name = "ProgressFill"
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(88, 255, 132)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBackground

	local button = Instance.new("TextButton")
	button.Name = "Action"
	button.Size = UDim2.new(0, 180, 0, 42)
	button.Position = UDim2.new(0.5, -90, 0, 158)
	button.BackgroundColor3 = Color3.fromRGB(50, 96, 168)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 20
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Parent = panel

	self._minigame = {
		overlay = overlay,
		panel = panel,
		title = title,
		description = description,
		progressFill = barFill,
		progressBackground = barBackground,
		action = button,
		onClick = nil,
	}
end

function UIBinder:BindPlacementCallback(callback)
	self._placementCallback = callback
end

function UIBinder:PopulateCatalog(catalogData)
	for _, child in ipairs(self._catalog.list:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	local layout = self._catalog.list:FindFirstChild("UIListLayout")
	if not layout then
		layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.Parent = self._catalog.list
	end

	for itemName, itemData in pairs(catalogData) do
		local entry = Instance.new("Frame")
		entry.Size = UDim2.new(1, -8, 0, 60)
		entry.BackgroundColor3 = Color3.fromRGB(30, 34, 58)
		entry.BorderSizePixel = 0
		entry.Parent = self._catalog.list

		local label = Instance.new("TextLabel")
		label.Text = ("%s\n$%d • Lv%d"):format(itemData.displayName, itemData.cost, itemData.unlockLevel or 1)
		label.Font = Enum.Font.Gotham
		label.TextSize = 16
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextWrapped = true
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, -110, 1, -10)
		label.Position = UDim2.new(0, 10, 0, 5)
		label.Parent = entry

		local button = Instance.new("TextButton")
		button.Text = "Build"
		button.Font = Enum.Font.GothamBold
		button.TextSize = 16
		button.TextColor3 = Color3.new(1, 1, 1)
		button.BackgroundColor3 = Color3.fromRGB(50, 96, 168)
		button.Size = UDim2.new(0, 80, 0, 38)
		button.Position = UDim2.new(1, -90, 0.5, -19)
		button.Parent = entry

		button.MouseButton1Click:Connect(function()
			if self._placementCallback then
				self._placementCallback(itemName)
			end
		end)
	end
	local contentSize = layout.AbsoluteContentSize
	self._catalog.list.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 12)
end

function UIBinder:BindCurrencyAttributes()
	self._player:GetAttributeChangedSignal("Currency"):Connect(function()
		self._hud.currency.Text = ("Currency: %d"):format(self._player:GetAttribute("Currency") or 0)
	end)
	self._hud.currency.Text = ("Currency: %d"):format(self._player:GetAttribute("Currency") or 0)
	self._player:GetAttributeChangedSignal("Level"):Connect(function()
		self._hud.level.Text = ("Level: %d"):format(self._player:GetAttribute("Level") or 1)
	end)
	self._hud.level.Text = ("Level: %d"):format(self._player:GetAttribute("Level") or 1)
end

function UIBinder:ShowMessage(text, color)
	self._hud.message.Text = text or ""
	self._hud.message.TextColor3 = color or Color3.new(1, 1, 1)
	task.delay(3, function()
		if self._hud.message.Text == text then
			self._hud.message.Text = ""
		end
	end)
end

function UIBinder:ShowPlacementHint(text)
	self._hud.message.Text = text or ""
end

function UIBinder:ShowMinigame(config)
	self._minigame.overlay.Visible = true
	self._minigame.title.Text = config.title or "Mini-game"
	self._minigame.description.Text = config.description or ""
	self._minigame.action.Text = config.buttonText or "Confirm"
	if self._minigame.onClick then
		self._minigame.onClick:Disconnect()
	end
	self._minigame.onClick = self._minigame.action.MouseButton1Click:Connect(function()
		if config.onButton then
			config.onButton()
		end
	end)
	self:UpdateMinigameProgress(config.progress or 0)
end

function UIBinder:UpdateMinigameProgress(ratio)
	local clamped = math.clamp(ratio, 0, 1)
	self._minigame.progressFill.Size = UDim2.new(clamped, 0, 1, 0)
end

function UIBinder:HideMinigame()
	if self._minigame.onClick then
		self._minigame.onClick:Disconnect()
		self._minigame.onClick = nil
	end
	self._minigame.overlay.Visible = false
end

return UIBinder

