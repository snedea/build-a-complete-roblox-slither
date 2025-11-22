--[[
	CustomizationController.lua
	Color picker and style selection

	Manage snake customization UI
	Author: Context Foundry Builder
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomizationData = require(ReplicatedStorage.Modules.CustomizationData)
local RemoteEvents = ReplicatedStorage.RemoteEvents

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CustomizationController = {}

local customizationGui = nil
local currentCustomization = table.clone(CustomizationData.DEFAULT)

-- Initialize customization menu
function CustomizationController:Initialize()
	self:CreateCustomizationMenu()
end

-- Create customization GUI
function CustomizationController:CreateCustomizationMenu()
	customizationGui = Instance.new("ScreenGui")
	customizationGui.Name = "CustomizationMenu"
	customizationGui.ResetOnSpawn = false
	customizationGui.Enabled = false  -- Hidden by default
	customizationGui.Parent = PlayerGui

	-- Container
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 400, 0, 500)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	container.BorderSizePixel = 0
	container.Parent = customizationGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = container

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "CUSTOMIZE SNAKE"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = container

	-- Color picker (simplified)
	local colorLabel = Instance.new("TextLabel")
	colorLabel.Size = UDim2.new(1, -20, 0, 30)
	colorLabel.Position = UDim2.new(0, 10, 0, 60)
	colorLabel.BackgroundTransparency = 1
	colorLabel.Text = "Body Color:"
	colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	colorLabel.TextScaled = true
	colorLabel.Font = Enum.Font.Gotham
	colorLabel.TextXAlignment = Enum.TextXAlignment.Left
	colorLabel.Parent = container

	-- Create color buttons
	local colorY = 100
	for colorName, color in pairs(CustomizationData.BODY_COLORS) do
		local colorButton = Instance.new("TextButton")
		colorButton.Size = UDim2.new(0, 80, 0, 40)
		colorButton.Position = UDim2.new(0, 10, 0, colorY)
		colorButton.BackgroundColor3 = color
		colorButton.Text = colorName
		colorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		colorButton.TextScaled = true
		colorButton.Font = Enum.Font.GothamBold
		colorButton.Parent = container

		colorButton.Activated:Connect(function()
			currentCustomization.bodyColor = color
			self:SendCustomization()
		end)

		colorY = colorY + 50
	end

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 100, 0, 40)
	closeButton.Position = UDim2.new(0.5, 0, 1, -50)
	closeButton.AnchorPoint = Vector2.new(0.5, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.Text = "CLOSE"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextScaled = true
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = container

	closeButton.Activated:Connect(function()
		customizationGui.Enabled = false
	end)
end

-- Send customization to server
function CustomizationController:SendCustomization()
	RemoteEvents.UpdateCustomization:FireServer(currentCustomization)
end

-- Toggle customization menu
function CustomizationController:Toggle()
	customizationGui.Enabled = not customizationGui.Enabled
end

-- Start controller
CustomizationController:Initialize()

return CustomizationController
