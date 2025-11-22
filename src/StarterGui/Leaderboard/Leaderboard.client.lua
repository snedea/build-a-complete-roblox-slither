-- Leaderboard.client.lua
-- Displays top players with monthly/all-time tabs

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameEvent")

-- Create leaderboard UI
local screenGui = script.Parent.Parent
local leaderboardFrame = Instance.new("Frame")
leaderboardFrame.Name = "LeaderboardFrame"
leaderboardFrame.Size = UDim2.new(0, 250, 0, 400)
leaderboardFrame.Position = UDim2.new(1, -270, 0, 20)
leaderboardFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
leaderboardFrame.BackgroundTransparency = 0.3
leaderboardFrame.BorderSizePixel = 0
leaderboardFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = leaderboardFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "LEADERBOARD"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = leaderboardFrame

-- Tab buttons
local tabFrame = Instance.new("Frame")
tabFrame.Name = "TabFrame"
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 45)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = leaderboardFrame

local monthlyButton = Instance.new("TextButton")
monthlyButton.Name = "MonthlyButton"
monthlyButton.Size = UDim2.new(0.48, 0, 1, 0)
monthlyButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
monthlyButton.BorderSizePixel = 0
monthlyButton.Text = "Monthly"
monthlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
monthlyButton.TextSize = 16
monthlyButton.Font = Enum.Font.GothamBold
monthlyButton.Parent = tabFrame

local monthlyCorner = Instance.new("UICorner")
monthlyCorner.CornerRadius = UDim.new(0, 5)
monthlyCorner.Parent = monthlyButton

local alltimeButton = Instance.new("TextButton")
alltimeButton.Name = "AlltimeButton"
alltimeButton.Size = UDim2.new(0.48, 0, 1, 0)
alltimeButton.Position = UDim2.new(0.52, 0, 0, 0)
alltimeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
alltimeButton.BorderSizePixel = 0
alltimeButton.Text = "All-Time"
alltimeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
alltimeButton.TextSize = 16
alltimeButton.Font = Enum.Font.Gotham
alltimeButton.Parent = tabFrame

local alltimeCorner = Instance.new("UICorner")
alltimeCorner.CornerRadius = UDim.new(0, 5)
alltimeCorner.Parent = alltimeButton

-- Scrolling frame for entries
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -20, 1, -95)
scrollFrame.Position = UDim2.new(0, 10, 0, 85)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = leaderboardFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

-- State
local currentScope = "monthly"
local currentStat = "kills"

-- Creates a leaderboard entry
local function createEntry(rank, username, value)
	local entry = Instance.new("Frame")
	entry.Name = "Entry_" .. rank
	entry.Size = UDim2.new(1, -10, 0, 35)
	entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	entry.BorderSizePixel = 0

	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 5)
	entryCorner.Parent = entry

	-- Rank number
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Size = UDim2.new(0, 30, 1, 0)
	rankLabel.Position = UDim2.new(0, 5, 0, 0)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = "#" .. rank
	rankLabel.TextColor3 = rank <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
	rankLabel.TextSize = 16
	rankLabel.Font = Enum.Font.GothamBold
	rankLabel.TextXAlignment = Enum.TextXAlignment.Left
	rankLabel.Parent = entry

	-- Username
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -80, 1, 0)
	nameLabel.Position = UDim2.new(0, 40, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = username
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = entry

	-- Value
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 1, 0)
	valueLabel.Position = UDim2.new(1, -55, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(value)
	valueLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	valueLabel.TextSize = 14
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = entry

	return entry
end

-- Updates leaderboard
local function updateLeaderboard()
	-- Clear existing entries
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Request data from server
	remoteEvent:FireServer("RequestLeaderboard", currentStat, currentScope)
end

-- Listen for leaderboard data
remoteEvent.OnClientEvent:Connect(function(eventType, data)
	if eventType == "LeaderboardData" then
		-- Clear existing entries
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		-- Create entries
		for _, entry in ipairs(data) do
			local username = Players:GetNameFromUserIdAsync(entry.userId) or "Unknown"
			local entryFrame = createEntry(entry.rank, username, entry.value)
			entryFrame.Parent = scrollFrame
		end

		-- Update canvas size
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end
end)

-- Tab button handlers
monthlyButton.MouseButton1Click:Connect(function()
	currentScope = "monthly"
	monthlyButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	monthlyButton.Font = Enum.Font.GothamBold
	alltimeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	alltimeButton.Font = Enum.Font.Gotham
	updateLeaderboard()
end)

alltimeButton.MouseButton1Click:Connect(function()
	currentScope = "alltime"
	alltimeButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	alltimeButton.Font = Enum.Font.GothamBold
	monthlyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	monthlyButton.Font = Enum.Font.Gotham
	updateLeaderboard()
end)

-- Initial update
task.wait(2)
updateLeaderboard()

-- Refresh every 30 seconds
task.spawn(function()
	while true do
		task.wait(30)
		updateLeaderboard()
	end
end)

print("[Leaderboard] Initialized")
