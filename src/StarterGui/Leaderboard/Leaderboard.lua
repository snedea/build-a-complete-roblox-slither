-- Leaderboard.lua
-- Monthly/all-time tabs, top 10 players

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create Leaderboard ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Leaderboard"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local leaderboardFrame = Instance.new("Frame")
leaderboardFrame.Name = "LeaderboardFrame"
leaderboardFrame.Size = UDim2.new(0, 400, 0, 500)
leaderboardFrame.Position = UDim2.new(1, -420, 0, 20)
leaderboardFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
leaderboardFrame.BackgroundTransparency = 0.2
leaderboardFrame.BorderSizePixel = 0
leaderboardFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = leaderboardFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "LEADERBOARD"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = leaderboardFrame

-- Tab buttons
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.Position = UDim2.new(0, 0, 0, 45)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = leaderboardFrame

local monthlyTab = Instance.new("TextButton")
monthlyTab.Name = "MonthlyTab"
monthlyTab.Size = UDim2.new(0.5, -5, 1, 0)
monthlyTab.Position = UDim2.new(0, 0, 0, 0)
monthlyTab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
monthlyTab.Text = "Monthly"
monthlyTab.TextColor3 = Color3.fromRGB(255, 255, 255)
monthlyTab.TextSize = 18
monthlyTab.Font = Enum.Font.GothamBold
monthlyTab.Parent = tabFrame

local allTimeTab = Instance.new("TextButton")
allTimeTab.Name = "AllTimeTab"
allTimeTab.Size = UDim2.new(0.5, -5, 1, 0)
allTimeTab.Position = UDim2.new(0.5, 5, 0, 0)
allTimeTab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
allTimeTab.Text = "All-Time"
allTimeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
allTimeTab.TextSize = 18
allTimeTab.Font = Enum.Font.GothamBold
allTimeTab.Parent = tabFrame

-- Content scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -100)
scrollFrame.Position = UDim2.new(0, 10, 0, 90)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = leaderboardFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

-- Create entry template
local function createEntry(rank, playerName, value)
	local entry = Instance.new("Frame")
	entry.Size = UDim2.new(1, -10, 0, 40)
	entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	entry.BackgroundTransparency = 0.5
	entry.BorderSizePixel = 0
	entry.LayoutOrder = rank
	
	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 5)
	entryCorner.Parent = entry
	
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Size = UDim2.new(0, 40, 1, 0)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = "#" .. rank
	rankLabel.TextColor3 = rank <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
	rankLabel.TextSize = 18
	rankLabel.Font = Enum.Font.GothamBold
	rankLabel.Parent = entry
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -150, 1, 0)
	nameLabel.Position = UDim2.new(0, 45, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = playerName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = entry
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 100, 1, 0)
	valueLabel.Position = UDim2.new(1, -105, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(value)
	valueLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	valueLabel.TextSize = 16
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = entry
	
	return entry
end

-- Populate leaderboard (placeholder)
local function populateLeaderboard(timeframe)
	-- Clear existing entries
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Placeholder data
	for i = 1, 10 do
		local entry = createEntry(i, "Player" .. i, 1000 - (i * 50))
		entry.Parent = scrollFrame
	end
end

-- Tab switching
monthlyTab.Activated:Connect(function()
	monthlyTab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	allTimeTab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	populateLeaderboard("Monthly")
end)

allTimeTab.Activated:Connect(function()
	allTimeTab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	monthlyTab.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	populateLeaderboard("AllTime")
end)

-- Initial populate
populateLeaderboard("Monthly")

return {}
