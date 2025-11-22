-- ShieldTimer.client.lua
-- Countdown overlay during spawn protection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameEvent")

-- Create shield timer UI (hidden by default)
local screenGui = script.Parent.Parent
local shieldFrame = Instance.new("Frame")
shieldFrame.Name = "ShieldTimer"
shieldFrame.Size = UDim2.new(0, 200, 0, 60)
shieldFrame.Position = UDim2.new(0.5, -100, 0, 100)
shieldFrame.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
shieldFrame.BackgroundTransparency = 0.3
shieldFrame.BorderSizePixel = 0
shieldFrame.Visible = false
shieldFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = shieldFrame

-- Shield icon/text
local shieldLabel = Instance.new("TextLabel")
shieldLabel.Name = "ShieldLabel"
shieldLabel.Size = UDim2.new(1, 0, 0.5, 0)
shieldLabel.BackgroundTransparency = 1
shieldLabel.Text = "🛡️ SHIELD ACTIVE"
shieldLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
shieldLabel.TextSize = 18
shieldLabel.Font = Enum.Font.GothamBold
shieldLabel.Parent = shieldFrame

-- Countdown
local countdownLabel = Instance.new("TextLabel")
countdownLabel.Name = "Countdown"
countdownLabel.Size = UDim2.new(1, 0, 0.5, 0)
countdownLabel.Position = UDim2.new(0, 0, 0.5, 0)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Text = "10.0s"
countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countdownLabel.TextSize = 20
countdownLabel.Font = Enum.Font.GothamBold
countdownLabel.Parent = shieldFrame

-- State
local shieldEndTime = 0
local countdownActive = false

-- Activates shield timer
local function activateShield(duration)
	shieldEndTime = os.clock() + duration
	countdownActive = true
	shieldFrame.Visible = true

	-- Countdown loop
	task.spawn(function()
		while countdownActive and os.clock() < shieldEndTime do
			local remaining = shieldEndTime - os.clock()
			countdownLabel.Text = string.format("%.1fs", remaining)

			-- Flash warning at 3 seconds
			if remaining <= 3 then
				shieldFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
			end

			task.wait(0.1)
		end

		if countdownActive then
			deactivateShield()
		end
	end)
end

-- Deactivates shield timer
function deactivateShield()
	countdownActive = false
	shieldFrame.Visible = false
	shieldFrame.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
end

-- Listen for server events
remoteEvent.OnClientEvent:Connect(function(eventType, data)
	if eventType == "ShieldActivated" then
		activateShield(data)
	elseif eventType == "ShieldDeactivated" then
		deactivateShield()
	end
end)

print("[ShieldTimer] Initialized")
