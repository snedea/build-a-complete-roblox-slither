--[[
	LeaderboardUI.lua
	Top players display

	Show leaderboards for kills, length, food
	Author: Context Foundry Builder
]]

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LeaderboardUI = {}

local leaderboardGui = nil
local scrollingFrame = nil

-- Initialize leaderboard UI
function LeaderboardUI:Initialize()
	self:CreateLeaderboard()
	self:StartUpdateLoop()
end

-- Create leaderboard GUI
function LeaderboardUI:CreateLeaderboard()
	leaderboardGui = Instance.new("ScreenGui")
	leaderboardGui.Name = "Leaderboard"
	leaderboardGui.ResetOnSpawn = false
	leaderboardGui.Parent = PlayerGui

	-- Container frame
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 200, 0, 300)
	container.Position = UDim2.new(1, -220, 0, 10)
	container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	container.BackgroundTransparency = 0.3
	container.BorderSizePixel = 0
	container.Parent = leaderboardGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = container

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundTransparency = 1
	title.Text = "TOP PLAYERS"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = container

	-- Scrolling frame for player list
	scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, -10, 1, -40)
	scrollingFrame.Position = UDim2.new(0, 5, 0, 35)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.Parent = container
end

-- Update leaderboard (would query server)
function LeaderboardUI:UpdateLeaderboard()
	-- Clear existing entries
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	-- In production, query server for top players
	-- For now, placeholder entries
	local placeholderPlayers = {
		{name = "Player1", kills = 50},
		{name = "Player2", kills = 40},
		{name = "Player3", kills = 30},
	}

	for i, playerData in ipairs(placeholderPlayers) do
		local entry = Instance.new("TextLabel")
		entry.Size = UDim2.new(1, -10, 0, 25)
		entry.Position = UDim2.new(0, 5, 0, (i - 1) * 30)
		entry.BackgroundTransparency = 1
		entry.Text = i .. ". " .. playerData.name .. " - " .. playerData.kills
		entry.TextColor3 = Color3.fromRGB(255, 255, 255)
		entry.TextScaled = true
		entry.Font = Enum.Font.Gotham
		entry.TextXAlignment = Enum.TextXAlignment.Left
		entry.Parent = scrollingFrame
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #placeholderPlayers * 30)
end

-- Start update loop (every 30 seconds)
function LeaderboardUI:StartUpdateLoop()
	task.spawn(function()
		while true do
			self:UpdateLeaderboard()
			task.wait(30)
		end
	end)
end

-- Start UI
LeaderboardUI:Initialize()

return LeaderboardUI
