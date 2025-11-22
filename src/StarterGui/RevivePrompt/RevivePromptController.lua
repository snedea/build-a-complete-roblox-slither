--[[
	RevivePromptController.lua
	Donut revival prompt

	Show revival UI when player dies
	Author: Context Foundry Builder
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage.RemoteEvents

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local RevivePromptController = {}

local promptGui = nil
local donutCountLabel = nil

-- Initialize revival prompt
function RevivePromptController:Initialize()
	self:CreatePrompt()

	-- Listen for revival prompt from server
	RemoteEvents.ShowRevivalPrompt.OnClientEvent:Connect(function(donutCount)
		self:Show(donutCount)
	end)
end

-- Create revival prompt GUI
function RevivePromptController:CreatePrompt()
	promptGui = Instance.new("ScreenGui")
	promptGui.Name = "RevivePrompt"
	promptGui.ResetOnSpawn = false
	promptGui.Enabled = false
	promptGui.Parent = PlayerGui

	-- Container
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 300, 0, 200)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	container.BorderSizePixel = 0
	container.Parent = promptGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = container

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "YOU DIED!"
	title.TextColor3 = Color3.fromRGB(255, 100, 100)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = container

	-- Donut count label
	donutCountLabel = Instance.new("TextLabel")
	donutCountLabel.Size = UDim2.new(1, -20, 0, 40)
	donutCountLabel.Position = UDim2.new(0, 10, 0, 60)
	donutCountLabel.BackgroundTransparency = 1
	donutCountLabel.Text = "Donuts: 0"
	donutCountLabel.TextColor3 = Color3.fromRGB(255, 192, 203)
	donutCountLabel.TextScaled = true
	donutCountLabel.Font = Enum.Font.Gotham
	donutCountLabel.Parent = container

	-- Revive button
	local reviveButton = Instance.new("TextButton")
	reviveButton.Size = UDim2.new(0, 150, 0, 50)
	reviveButton.Position = UDim2.new(0.5, 0, 0, 120)
	reviveButton.AnchorPoint = Vector2.new(0.5, 0)
	reviveButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
	reviveButton.Text = "REVIVE"
	reviveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	reviveButton.TextScaled = true
	reviveButton.Font = Enum.Font.GothamBold
	reviveButton.Parent = container

	reviveButton.Activated:Connect(function()
		RemoteEvents.RequestRevival:FireServer()
		promptGui.Enabled = false
	end)
end

-- Show revival prompt
function RevivePromptController:Show(donutCount)
	donutCountLabel.Text = "Donuts: " .. tostring(donutCount)
	promptGui.Enabled = true

	-- Auto-hide after 10 seconds
	task.delay(10, function()
		promptGui.Enabled = false
	end)
end

-- Start controller
RevivePromptController:Initialize()

return RevivePromptController
