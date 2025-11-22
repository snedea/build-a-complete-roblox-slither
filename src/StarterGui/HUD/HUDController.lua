--[[
	HUDController.lua
	Gold, rank, length display

	Update HUD with player stats from server
	Author: Context Foundry Builder
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage.RemoteEvents
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local HUDController = {}

local hudGui = nil
local goldLabel = nil
local rankLabel = nil
local lengthLabel = nil

-- Initialize HUD
function HUDController:Initialize()
	self:CreateHUD()

	-- Listen for stat updates from server
	RemoteEvents.UpdateStats.OnClientEvent:Connect(function(stats)
		self:UpdateDisplay(stats)
	end)
end

-- Create HUD GUI
function HUDController:CreateHUD()
	hudGui = Instance.new("ScreenGui")
	hudGui.Name = "HUD"
	hudGui.ResetOnSpawn = false
	hudGui.Parent = PlayerGui

	-- Container frame
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 250, 0, 100)
	container.Position = UDim2.new(0, 10, 0, 10)
	container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	container.BackgroundTransparency = 0.3
	container.BorderSizePixel = 0
	container.Parent = hudGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = container

	-- Gold label
	goldLabel = Instance.new("TextLabel")
	goldLabel.Size = UDim2.new(1, -20, 0, 25)
	goldLabel.Position = UDim2.new(0, 10, 0, 5)
	goldLabel.BackgroundTransparency = 1
	goldLabel.Text = "Gold: 0"
	goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	goldLabel.TextScaled = true
	goldLabel.Font = Enum.Font.GothamBold
	goldLabel.TextXAlignment = Enum.TextXAlignment.Left
	goldLabel.Parent = container

	-- Rank label
	rankLabel = Instance.new("TextLabel")
	rankLabel.Size = UDim2.new(1, -20, 0, 25)
	rankLabel.Position = UDim2.new(0, 10, 0, 35)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = "Rank: 1"
	rankLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	rankLabel.TextScaled = true
	rankLabel.Font = Enum.Font.GothamBold
	rankLabel.TextXAlignment = Enum.TextXAlignment.Left
	rankLabel.Parent = container

	-- Length label
	lengthLabel = Instance.new("TextLabel")
	lengthLabel.Size = UDim2.new(1, -20, 0, 25)
	lengthLabel.Position = UDim2.new(0, 10, 0, 65)
	lengthLabel.BackgroundTransparency = 1
	lengthLabel.Text = "Length: 3"
	lengthLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	lengthLabel.TextScaled = true
	lengthLabel.Font = Enum.Font.GothamBold
	lengthLabel.TextXAlignment = Enum.TextXAlignment.Left
	lengthLabel.Parent = container
end

-- Update HUD display
function HUDController:UpdateDisplay(stats)
	if goldLabel then
		goldLabel.Text = "Gold: " .. tostring(stats.gold or 0)
	end

	if rankLabel then
		rankLabel.Text = "Rank: " .. tostring(stats.rank or 1)
	end

	if lengthLabel then
		lengthLabel.Text = "Length: " .. tostring(stats.length or 3)
	end
end

-- Start controller
HUDController:Initialize()

return HUDController
