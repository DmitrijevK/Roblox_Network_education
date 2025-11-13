local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local PlacementSystem = {}
PlacementSystem.__index = PlacementSystem

local ROTATION_INCREMENT = 90
local SNAP_INCREMENT = 2
local MAX_DISTANCE = 150

function PlacementSystem.new(remotes, catalog, uiBinder)
	local self = setmetatable({}, PlacementSystem)
	self._player = Players.LocalPlayer
	self._mouse = self._player:GetMouse()
	self._remotes = remotes
	self._catalog = catalog
	self._ui = uiBinder
	self._currentItem = nil
	self._ghost = nil
	self._rotation = 0
	self._connectionHandles = {}
	self._busy = false
	return self
end

function PlacementSystem:_destroyGhost()
	if self._ghost then
		self._ghost:Destroy()
		self._ghost = nil
	end
	self._ui:ShowPlacementHint(nil)
end

function PlacementSystem:_createGhost(itemName)
	self:_destroyGhost()
	local item = self._catalog.GetItem(itemName)
	if not item then
		return
	end
	local part = Instance.new("Part")
	part.Name = "Ghost_" .. itemName
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.6
	part.Size = item.placement.size or Vector3.new(4, 4, 4)
	part.Material = Enum.Material.ForceField
	part.Color = Color3.fromRGB(115, 149, 255)
	part.Parent = workspace.Terrain -- invisible parent until placed
	self._ghost = part
	self._ui:ShowPlacementHint("Click to place • Right Click/Esc to cancel • R to rotate")
end

function PlacementSystem:_alignToGrid(position, increment)
	local grid = increment or SNAP_INCREMENT
	return Vector3.new(
		math.floor(position.X / grid + 0.5) * grid,
		math.floor(position.Y / grid + 0.5) * grid,
		math.floor(position.Z / grid + 0.5) * grid
	)
end

function PlacementSystem:_updateGhost()
	if not self._ghost or not self._currentItem then
		return
	end
	local unitRay = workspace.CurrentCamera:ScreenPointToRay(
		UserInputService:GetMouseLocation().X,
		UserInputService:GetMouseLocation().Y
	)

	local ray = Ray.new(unitRay.Origin, unitRay.Direction * MAX_DISTANCE)
	local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {self._player.Character, self._ghost})
	if not position then
		position = unitRay.Origin + unitRay.Direction * 15
	end

	local item = self._catalog.GetItem(self._currentItem)
	local snapped = self:_alignToGrid(position, item.placement.grid or SNAP_INCREMENT)
	local cframe = CFrame.new(snapped) * CFrame.Angles(0, math.rad(self._rotation), 0)
	self._ghost.CFrame = cframe
end

function PlacementSystem:_sendPlacement()
	if not self._ghost or not self._currentItem then
		return
	end
	local item = self._catalog.GetItem(self._currentItem)
	if not item then
		return
	end
	self._busy = true
	self._ui:ShowPlacementHint("Validating placement...")
	self._remotes.PlaceItem:FireServer({
		itemName = self._currentItem,
		cframe = self._ghost.CFrame,
		size = self._ghost.Size,
	})
end

function PlacementSystem:_cancelPlacement()
	self._currentItem = nil
	self._busy = false
	self._rotation = 0
	self:_destroyGhost()
end

function PlacementSystem:Bind()
	table.insert(self._connectionHandles, RunService.RenderStepped:Connect(function()
		if self._currentItem and not self._busy then
			self:_updateGhost()
		end
	end))

	table.insert(self._connectionHandles, UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not self._currentItem then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:_sendPlacement()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2
			or input.KeyCode == Enum.KeyCode.Escape then
			self:_cancelPlacement()
		elseif input.KeyCode == Enum.KeyCode.R then
			self._rotation = (self._rotation + ROTATION_INCREMENT) % 360
		end
	end))

	self._remotes.ConfirmPlace.OnClientEvent:Connect(function(result)
		self._busy = false
		if result.success then
			self:_destroyGhost()
			self._currentItem = nil
			self._ui:ShowMessage(("Placed %s (-%d)"):format(result.itemName, result.cost or 0))
		else
			self._ui:ShowMessage(result.reason or "Placement blocked", Color3.fromRGB(255, 96, 96))
		end
	end)
end

function PlacementSystem:BeginPlacement(itemName)
	if self._busy then
		return
	end
	self._currentItem = itemName
	self._rotation = 0
	self:_createGhost(itemName)
end

function PlacementSystem:Destroy()
	self:_cancelPlacement()
	for _, connection in ipairs(self._connectionHandles) do
		connection:Disconnect()
	end
	self._connectionHandles = {}
end

return PlacementSystem

