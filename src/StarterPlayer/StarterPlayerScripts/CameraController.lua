-- CameraController.lua
-- Zoom controls, FOV scaling by snake size, pinch/pan for mobile

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local CameraController = {}
CameraController.ZoomLevel = 50 -- Starting zoom distance
CameraController.MinZoom = 20
CameraController.MaxZoom = 150
CameraController.TargetPosition = Vector3.new(0, 0, 0)
CameraController._initialized = false

-- Initialize camera
function CameraController:Initialize()
	if self._initialized then
		return
	end
	self._initialized = true

	camera.CameraType = Enum.CameraType.Scriptable

	-- Desktop zoom (mouse wheel)
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			self.ZoomLevel = math.clamp(self.ZoomLevel - input.Position.Z * 5, self.MinZoom, self.MaxZoom)
		end
	end)

	-- Mobile pinch zoom
	if UserInputService.TouchEnabled then
		self:_setupMobilePinchZoom()
	end

	-- Update camera every frame
	RunService.RenderStepped:Connect(function(dt)
		self:_updateCamera(dt)
	end)

	print("[CameraController] Initialized")
end

-- Updates camera position
function CameraController:_updateCamera(dt)
	-- Get local player's snake head from Snakes folder
	local snakesFolder = workspace:FindFirstChild("Snakes")
	if snakesFolder then
		local snakeHead = snakesFolder:FindFirstChild(player.Name .. "_Head")
		if snakeHead then
			self.TargetPosition = snakeHead.Position
		end
	end

	-- Set camera position (top-down view)
	local cameraPos = self.TargetPosition + Vector3.new(0, self.ZoomLevel, 0)
	camera.CFrame = CFrame.new(cameraPos, self.TargetPosition)

	-- Adjust FOV based on zoom (wider FOV when zoomed out)
	local fov = math.clamp(50 + (self.ZoomLevel - 50) * 0.3, 40, 90)
	camera.FieldOfView = fov
end

-- Sets target position (called by SnakeRenderer)
function CameraController:SetTargetPosition(position)
	self.TargetPosition = position
end

-- Mobile pinch zoom setup
function CameraController:_setupMobilePinchZoom()
	local lastPinchDistance = nil

	UserInputService.TouchPinch:Connect(function(touchPositions, scale, velocity, state)
		if state == Enum.UserInputState.Begin then
			lastPinchDistance = (touchPositions[1] - touchPositions[2]).Magnitude
		elseif state == Enum.UserInputState.Change then
			local currentDistance = (touchPositions[1] - touchPositions[2]).Magnitude
			local delta = currentDistance - lastPinchDistance
			self.ZoomLevel = math.clamp(self.ZoomLevel - delta * 0.1, self.MinZoom, self.MaxZoom)
			lastPinchDistance = currentDistance
		end
	end)
end

return CameraController
