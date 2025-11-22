-- HUD.client.lua
-- Displays gold, rank, length, kills, and progress bars

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameEvent")
local RankConfig = require(ReplicatedStorage.Modules.RankConfig)

-- Create HUD UI
local screenGui = script.Parent.Parent
local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUDFrame"
hudFrame.Size = UDim2.new(0, 300, 0, 200)
hudFrame.Position = UDim2.new(0, 20, 0, 20)
hudFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hudFrame.BackgroundTransparency = 0.3
hudFrame.BorderSizePixel = 0
hudFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = hudFrame

-- Gold display
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

-- Rank display
local rankLabel = Instance.new("TextLabel")
rankLabel.Name = "RankLabel"
rankLabel.Size = UDim2.new(1, -20, 0, 30)
rankLabel.Position = UDim2.new(0, 10, 0, 45)
rankLabel.BackgroundTransparency = 1
rankLabel.Text = "Rank: 1 - Worm"
rankLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
rankLabel.TextSize = 18
rankLabel.Font = Enum.Font.Gotham
rankLabel.TextXAlignment = Enum.TextXAlignment.Left
rankLabel.Parent = hudFrame

-- Progress bar
local progressFrame = Instance.new("Frame")
progressFrame.Name = "ProgressFrame"
progressFrame.Size = UDim2.new(1, -20, 0, 20)
progressFrame.Position = UDim2.new(0, 10, 0, 80)
progressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
progressFrame.BorderSizePixel = 0
progressFrame.Parent = hudFrame

local progressBar = Instance.new("Frame")
progressBar.Name = "ProgressBar"
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressFrame

local progressCorner1 = Instance.new("UICorner")
progressCorner1.CornerRadius = UDim.new(0, 5)
progressCorner1.Parent = progressFrame

local progressCorner2 = Instance.new("UICorner")
progressCorner2.CornerRadius = UDim.new(0, 5)
progressCorner2.Parent = progressBar

-- Length display
local lengthLabel = Instance.new("TextLabel")
lengthLabel.Name = "LengthLabel"
lengthLabel.Size = UDim2.new(1, -20, 0, 25)
lengthLabel.Position = UDim2.new(0, 10, 0, 110)
lengthLabel.BackgroundTransparency = 1
lengthLabel.Text = "Length: 5"
lengthLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
lengthLabel.TextSize = 16
lengthLabel.Font = Enum.Font.Gotham
lengthLabel.TextXAlignment = Enum.TextXAlignment.Left
lengthLabel.Parent = hudFrame

-- Kills display
local killsLabel = Instance.new("TextLabel")
killsLabel.Name = "KillsLabel"
killsLabel.Size = UDim2.new(1, -20, 0, 25)
killsLabel.Position = UDim2.new(0, 10, 0, 140)
killsLabel.BackgroundTransparency = 1
killsLabel.Text = "Kills: 0"
killsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
killsLabel.TextSize = 16
killsLabel.Font = Enum.Font.Gotham
killsLabel.TextXAlignment = Enum.TextXAlignment.Left
killsLabel.Parent = hudFrame

-- Donuts display
local donutsLabel = Instance.new("TextLabel")
donutsLabel.Name = "DonutsLabel"
donutsLabel.Size = UDim2.new(1, -20, 0, 25)
donutsLabel.Position = UDim2.new(0, 10, 0, 170)
donutsLabel.BackgroundTransparency = 1
donutsLabel.Text = "Donuts: 3"
donutsLabel.TextColor3 = Color3.fromRGB(255, 200, 150)
donutsLabel.TextSize = 16
donutsLabel.Font = Enum.Font.Gotham
donutsLabel.TextXAlignment = Enum.TextXAlignment.Left
donutsLabel.Parent = hudFrame

-- State
local currentGold = 0
local currentRank = 1
local currentLength = 5
local currentKills = 0
local currentDonuts = 3

-- Update functions
local function updateGold(gold)
	currentGold = gold
	goldLabel.Text = "Gold: " .. gold
	updateProgressBar()
end

local function updateRank(rank)
	currentRank = rank
	local rankData = RankConfig.GetRankData(rank)
	rankLabel.Text = string.format("Rank: %d - %s", rank, rankData.name)
	updateProgressBar()
end

local function updateLength(length)
	currentLength = length
	lengthLabel.Text = "Length: " .. length
end

local function updateKills(kills)
	currentKills = kills
	killsLabel.Text = "Kills: " .. kills
end

local function updateDonuts(donuts)
	currentDonuts = donuts
	donutsLabel.Text = "Donuts: " .. donuts
end

local function updateProgressBar()
	local nextThreshold = RankConfig.GetNextRankThreshold(currentRank)
	if nextThreshold then
		local currentThreshold = RankConfig.GetRankThreshold(currentRank)
		local progress = (currentGold - currentThreshold) / (nextThreshold - currentThreshold)
		progressBar.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
	else
		-- Max rank
		progressBar.Size = UDim2.new(1, 0, 1, 0)
	end
end

-- Listen for server events
remoteEvent.OnClientEvent:Connect(function(eventType, data)
	if eventType == "InitialData" then
		updateGold(data.gold or 0)
		updateRank(data.rank or 1)
		updateDonuts(data.reviveDonuts or 3)
		updateKills(data.stats and data.stats.totalKills or 0)

	elseif eventType == "GoldUpdated" then
		updateGold(data)

	elseif eventType == "RankUp" then
		updateRank(data)

	elseif eventType == "FoodCollected" then
		-- Animate gold increase
		task.spawn(function()
			for i = 1, 5 do
				goldLabel.TextSize = 20 + i
				task.wait(0.02)
			end
			for i = 5, 1, -1 do
				goldLabel.TextSize = 20 + i
				task.wait(0.02)
			end
			goldLabel.TextSize = 20
		end)

	elseif eventType == "UpdateSnakes" then
		-- Update local player's length
		local localData = data[player.UserId]
		if localData then
			updateLength(localData.length)
		end
	end
end)

print("[HUD] Initialized")
