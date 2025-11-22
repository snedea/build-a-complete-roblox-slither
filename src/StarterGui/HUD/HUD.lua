-- HUD.lua
-- Display gold, rank, length, kills

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create HUD ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Container frame
local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUDFrame"
hudFrame.Size = UDim2.new(0, 300, 0, 150)
hudFrame.Position = UDim2.new(0, 20, 0, 20)
hudFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hudFrame.BackgroundTransparency = 0.3
hudFrame.BorderSizePixel = 0
hudFrame.Parent = screenGui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 10)
hudCorner.Parent = hudFrame

-- Gold label
local goldLabel = Instance.new("TextLabel")
goldLabel.Name = "GoldLabel"
goldLabel.Size = UDim2.new(1, -20, 0, 30)
goldLabel.Position = UDim2.new(0, 10, 0, 10)
goldLabel.BackgroundTransparency = 1
goldLabel.Text = "Gold: 0"
goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
goldLabel.TextSize = 20
goldLabel.Font = Enum.Font.GothamBold
goldLabel.TextXAlignment = Enum.TextXAlignment.Left
goldLabel.Parent = hudFrame

-- Rank label
local rankLabel = Instance.new("TextLabel")
rankLabel.Name = "RankLabel"
rankLabel.Size = UDim2.new(1, -20, 0, 30)
rankLabel.Position = UDim2.new(0, 10, 0, 45)
rankLabel.BackgroundTransparency = 1
rankLabel.Text = "Rank: 1"
rankLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
rankLabel.TextSize = 20
rankLabel.Font = Enum.Font.GothamBold
rankLabel.TextXAlignment = Enum.TextXAlignment.Left
rankLabel.Parent = hudFrame

-- Length label
local lengthLabel = Instance.new("TextLabel")
lengthLabel.Name = "LengthLabel"
lengthLabel.Size = UDim2.new(1, -20, 0, 30)
lengthLabel.Position = UDim2.new(0, 10, 0, 80)
lengthLabel.BackgroundTransparency = 1
lengthLabel.Text = "Length: 10"
lengthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
lengthLabel.TextSize = 20
lengthLabel.Font = Enum.Font.GothamBold
lengthLabel.TextXAlignment = Enum.TextXAlignment.Left
lengthLabel.Parent = hudFrame

-- Kills label
local killsLabel = Instance.new("TextLabel")
killsLabel.Name = "KillsLabel"
killsLabel.Size = UDim2.new(1, -20, 0, 30)
killsLabel.Position = UDim2.new(0, 10, 0, 115)
killsLabel.BackgroundTransparency = 1
killsLabel.Text = "Kills: 0"
killsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
killsLabel.TextSize = 20
killsLabel.Font = Enum.Font.GothamBold
killsLabel.TextXAlignment = Enum.TextXAlignment.Left
killsLabel.Parent = hudFrame

-- Update HUD with player data
local function updateHUD()
	-- This would normally fetch from a client-side data cache
	-- For now, placeholder values
	local gold = 0
	local rank = 1
	local length = 10
	local kills = 0
	
	goldLabel.Text = "Gold: " .. gold
	rankLabel.Text = "Rank: " .. rank
	lengthLabel.Text = "Length: " .. length
	killsLabel.Text = "Kills: " .. kills
end

-- Update loop (every second)
task.spawn(function()
	while task.wait(1) do
		updateHUD()
	end
end)

return {}
