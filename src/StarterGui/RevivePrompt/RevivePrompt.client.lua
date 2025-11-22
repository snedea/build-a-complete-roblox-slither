-- RevivePrompt.client.lua
-- Revival UI on death with donut consumption

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameEvent")

-- Create revival prompt (hidden by default)
local screenGui = script.Parent.Parent
local promptFrame = Instance.new("Frame")
promptFrame.Name = "RevivePrompt"
promptFrame.Size = UDim2.new(0, 400, 0, 250)
promptFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
promptFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
promptFrame.BackgroundTransparency = 0.1
promptFrame.BorderSizePixel = 0
promptFrame.Visible = false
promptFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = promptFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 60)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "YOU DIED!"
titleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
titleLabel.TextSize = 32
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = promptFrame

-- Message
local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "Message"
messageLabel.Size = UDim2.new(1, -40, 0, 80)
messageLabel.Position = UDim2.new(0, 20, 0, 65)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = "Would you like to revive using a donut?\nYou have 3 donuts remaining."
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.TextSize = 16
messageLabel.Font = Enum.Font.Gotham
messageLabel.TextWrapped = true
messageLabel.Parent = promptFrame

-- Revive button
local reviveButton = Instance.new("TextButton")
reviveButton.Name = "ReviveButton"
reviveButton.Size = UDim2.new(0, 160, 0, 50)
reviveButton.Position = UDim2.new(0.5, -170, 1, -70)
reviveButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
reviveButton.BorderSizePixel = 0
reviveButton.Text = "REVIVE (1 🍩)"
reviveButton.TextColor3 = Color3.fromRGB(0, 0, 0)
reviveButton.TextSize = 18
reviveButton.Font = Enum.Font.GothamBold
reviveButton.Parent = promptFrame

local reviveCorner = Instance.new("UICorner")
reviveCorner.CornerRadius = UDim.new(0, 10)
reviveCorner.Parent = reviveButton

-- Decline button
local declineButton = Instance.new("TextButton")
declineButton.Name = "DeclineButton"
declineButton.Size = UDim2.new(0, 160, 0, 50)
declineButton.Position = UDim2.new(0.5, 10, 1, -70)
declineButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
declineButton.BorderSizePixel = 0
declineButton.Text = "DECLINE"
declineButton.TextColor3 = Color3.fromRGB(255, 255, 255)
declineButton.TextSize = 18
declineButton.Font = Enum.Font.GothamBold
declineButton.Parent = promptFrame

local declineCorner = Instance.new("UICorner")
declineCorner.CornerRadius = UDim.new(0, 10)
declineCorner.Parent = declineButton

-- Countdown timer
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "Timer"
timerLabel.Size = UDim2.new(1, 0, 0, 30)
timerLabel.Position = UDim2.new(0, 0, 0, 155)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Time remaining: 10s"
timerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
timerLabel.TextSize = 14
timerLabel.Font = Enum.Font.Gotham
timerLabel.Parent = promptFrame

-- State
local promptEndTime = 0
local countdownActive = false

-- Shows revival prompt
local function showPrompt(donutCount)
	if donutCount <= 0 then
		messageLabel.Text = "You don't have any donuts!\nRespawning in 3 seconds..."
		reviveButton.Visible = false
		declineButton.Visible = false
		timerLabel.Visible = false

		promptFrame.Visible = true

		task.wait(3)
		promptFrame.Visible = false
		return
	end

	messageLabel.Text = string.format("Would you like to revive using a donut?\nYou have %d donuts remaining.", donutCount)
	reviveButton.Visible = true
	declineButton.Visible = true
	timerLabel.Visible = true
	promptFrame.Visible = true

	promptEndTime = os.clock() + 10
	countdownActive = true

	-- Countdown
	task.spawn(function()
		while countdownActive and os.clock() < promptEndTime do
			local remaining = math.ceil(promptEndTime - os.clock())
			timerLabel.Text = string.format("Time remaining: %ds", remaining)
			task.wait(0.1)
		end

		if countdownActive then
			-- Auto-decline
			remoteEvent:FireServer("DeclineRevival")
			promptFrame.Visible = false
			countdownActive = false
		end
	end)
end

-- Hides prompt
local function hidePrompt()
	promptFrame.Visible = false
	countdownActive = false
end

-- Button handlers
reviveButton.MouseButton1Click:Connect(function()
	remoteEvent:FireServer("AcceptRevival")
	hidePrompt()
end)

declineButton.MouseButton1Click:Connect(function()
	remoteEvent:FireServer("DeclineRevival")
	hidePrompt()
end)

-- Listen for server events
remoteEvent.OnClientEvent:Connect(function(eventType, data)
	if eventType == "ShowRevivePrompt" then
		showPrompt(data)
	elseif eventType == "HideRevivePrompt" then
		hidePrompt()
	end
end)

print("[RevivePrompt] Initialized")
