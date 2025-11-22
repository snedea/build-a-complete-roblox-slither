-- ShieldTimer.lua
-- Countdown overlay during spawn protection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create timer UI (initially hidden)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShieldTimer"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(0, 200, 0, 60)
timerLabel.Position = UDim2.new(0.5, -100, 0, 150)
timerLabel.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
timerLabel.BackgroundTransparency = 0.3
timerLabel.BorderSizePixel = 0
timerLabel.Text = "SHIELD: 10s"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 24
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Visible = false
timerLabel.Parent = screenGui

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0, 10)
labelCorner.Parent = timerLabel

-- Active timer coroutine
local activeTimer

-- Show shield timer
local function showShieldTimer(duration)
	timerLabel.Visible = true
	
	if activeTimer then
		task.cancel(activeTimer)
	end
	
	activeTimer = task.spawn(function()
		local timeLeft = duration
		
		while timeLeft > 0 do
			timerLabel.Text = string.format("SHIELD: %.1fs", timeLeft)
			task.wait(0.1)
			timeLeft -= 0.1
		end
		
		timerLabel.Visible = false
	end)
end

-- Hide shield timer
local function hideShieldTimer()
	timerLabel.Visible = false
	
	if activeTimer then
		task.cancel(activeTimer)
		activeTimer = nil
	end
end

-- Listen for shield events from server
local ShieldActivatedEvent = ReplicatedStorage:FindFirstChild("ShieldActivatedEvent")
if ShieldActivatedEvent then
	ShieldActivatedEvent.OnClientEvent:Connect(function(duration)
		showShieldTimer(duration)
	end)
end

local ShieldDeactivatedEvent = ReplicatedStorage:FindFirstChild("ShieldDeactivatedEvent")
if ShieldDeactivatedEvent then
	ShieldDeactivatedEvent.OnClientEvent:Connect(function()
		hideShieldTimer()
	end)
end

return {}
