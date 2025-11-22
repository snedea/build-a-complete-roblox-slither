-- MobileControls.lua
-- Dynamic thumbstick + boost/brake buttons (mobile only)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameEvent")

local MobileControls = {}
MobileControls.Enabled = false
MobileControls.ThumbstickPosition = Vector2.new(0, 0)
MobileControls.ActiveTouch = nil
MobileControls._initialized = false
MobileControls._snakeController = nil

-- Check if mobile device
local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Creates mobile UI
function MobileControls:CreateUI()
	if not isMobile() then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MobileControls"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player:WaitForChild("PlayerGui")

	-- Thumbstick background
	local thumbstickBg = Instance.new("Frame")
	thumbstickBg.Name = "ThumbstickBackground"
	thumbstickBg.Size = UDim2.new(0, 150, 0, 150)
	thumbstickBg.Position = UDim2.new(0, 50, 1, -200)
	thumbstickBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	thumbstickBg.BackgroundTransparency = 0.5
	thumbstickBg.BorderSizePixel = 0
	thumbstickBg.Parent = screenGui

	-- Round corners
	local corner1 = Instance.new("UICorner")
	corner1.CornerRadius = UDim.new(1, 0)
	corner1.Parent = thumbstickBg

	-- Thumbstick knob
	local thumbstickKnob = Instance.new("Frame")
	thumbstickKnob.Name = "ThumbstickKnob"
	thumbstickKnob.Size = UDim2.new(0, 60, 0, 60)
	thumbstickKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
	thumbstickKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumbstickKnob.BackgroundTransparency = 0.3
	thumbstickKnob.BorderSizePixel = 0
	thumbstickKnob.Parent = thumbstickBg

	local corner2 = Instance.new("UICorner")
	corner2.CornerRadius = UDim.new(1, 0)
	corner2.Parent = thumbstickKnob

	-- Boost button
	local boostButton = Instance.new("TextButton")
	boostButton.Name = "BoostButton"
	boostButton.Size = UDim2.new(0, 100, 0, 100)
	boostButton.Position = UDim2.new(1, -150, 1, -200)
	boostButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
	boostButton.BackgroundTransparency = 0.3
	boostButton.BorderSizePixel = 0
	boostButton.Text = "BOOST"
	boostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	boostButton.TextSize = 20
	boostButton.Font = Enum.Font.GothamBold
	boostButton.Parent = screenGui

	local corner3 = Instance.new("UICorner")
	corner3.CornerRadius = UDim.new(0.5, 0)
	corner3.Parent = boostButton

	-- Brake button
	local brakeButton = Instance.new("TextButton")
	brakeButton.Name = "BrakeButton"
	brakeButton.Size = UDim2.new(0, 100, 0, 100)
	brakeButton.Position = UDim2.new(1, -150, 1, -320)
	brakeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	brakeButton.BackgroundTransparency = 0.3
	brakeButton.BorderSizePixel = 0
	brakeButton.Text = "BRAKE"
	brakeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	brakeButton.TextSize = 20
	brakeButton.Font = Enum.Font.GothamBold
	brakeButton.Parent = screenGui

	local corner4 = Instance.new("UICorner")
	corner4.CornerRadius = UDim.new(0.5, 0)
	corner4.Parent = brakeButton

	-- Thumbstick input
	thumbstickBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self.ActiveTouch = input
		end
	end)

	thumbstickBg.InputChanged:Connect(function(input)
		if input == self.ActiveTouch then
			self:_updateThumbstick(input, thumbstickBg, thumbstickKnob)
		end
	end)

	thumbstickBg.InputEnded:Connect(function(input)
		if input == self.ActiveTouch then
			self.ActiveTouch = nil
			self.ThumbstickPosition = Vector2.new(0, 0)
			thumbstickKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
		end
	end)

	-- Button inputs
	boostButton.MouseButton1Click:Connect(function()
		remoteEvent:FireServer("ActivateBoost")
	end)

	brakeButton.MouseButton1Click:Connect(function()
		remoteEvent:FireServer("ActivateBrake")
	end)

	self.Enabled = true
	print("[MobileControls] Mobile UI created")
end

-- Updates thumbstick position
function MobileControls:_updateThumbstick(input, background, knob)
	local bgPosition = background.AbsolutePosition + background.AbsoluteSize / 2
	local touchPosition = input.Position

	local delta = touchPosition - bgPosition
	local distance = delta.Magnitude
	local maxDistance = background.AbsoluteSize.X / 2

	-- Clamp to circle
	if distance > maxDistance then
		delta = delta.Unit * maxDistance
		distance = maxDistance
	end

	-- Update knob position
	knob.Position = UDim2.new(0.5, delta.X - 30, 0.5, delta.Y - 30)

	-- Store normalized thumbstick position
	self.ThumbstickPosition = delta / maxDistance
end

-- Gets direction vector from thumbstick
function MobileControls:GetDirection()
	if self.ThumbstickPosition.Magnitude > 0.1 then
		return Vector3.new(self.ThumbstickPosition.X, 0, self.ThumbstickPosition.Y)
	end
	return Vector3.new(0, 0, 0)
end

-- Initialize
function MobileControls:Initialize(snakeController)
	if self._initialized then
		return
	end
	self._initialized = true
	self._snakeController = snakeController

	if isMobile() then
		self:CreateUI()

		-- Update SnakeController with thumbstick direction
		RunService.Heartbeat:Connect(function()
			local direction = self:GetDirection()
			if direction.Magnitude > 0.1 then
				local controller = self._snakeController or require(script.Parent.SnakeController)
				controller:SetDirection(direction)
			end
		end)
	end
end

return MobileControls
