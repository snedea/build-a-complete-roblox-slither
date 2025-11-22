-- RevivePrompt.lua
-- Death UI with donut revival option

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RequestReviveEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestRevive")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create prompt (initially hidden)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RevivePrompt"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local promptFrame = Instance.new("Frame")
promptFrame.Name = "PromptFrame"
promptFrame.Size = UDim2.new(0, 400, 0, 250)
promptFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
promptFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
promptFrame.BorderSizePixel = 0
promptFrame.Visible = false
promptFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = promptFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "YOU DIED!"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.TextSize = 36
title.Font = Enum.Font.GothamBold
title.Parent = promptFrame

-- Donut count label
local donutLabel = Instance.new("TextLabel")
donutLabel.Size = UDim2.new(1, 0, 0, 40)
donutLabel.Position = UDim2.new(0, 0, 0, 70)
donutLabel.BackgroundTransparency = 1
donutLabel.Text = "Revive Donuts: 3"
donutLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
donutLabel.TextSize = 20
donutLabel.Font = Enum.Font.GothamBold
donutLabel.Parent = promptFrame

-- Revive button
local reviveButton = Instance.new("TextButton")
reviveButton.Size = UDim2.new(0, 180, 0, 50)
reviveButton.Position = UDim2.new(0.5, -90, 0, 120)
reviveButton.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
reviveButton.Text = "REVIVE (1 DONUT)"
reviveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
reviveButton.TextSize = 18
reviveButton.Font = Enum.Font.GothamBold
reviveButton.TextWrapped = true
reviveButton.Parent = promptFrame

local reviveCorner = Instance.new("UICorner")
reviveCorner.CornerRadius = UDim.new(0, 10)
reviveCorner.Parent = reviveButton

-- Timeout label
local timeoutLabel = Instance.new("TextLabel")
timeoutLabel.Size = UDim2.new(1, 0, 0, 30)
timeoutLabel.Position = UDim2.new(0, 0, 0, 180)
timeoutLabel.BackgroundTransparency = 1
timeoutLabel.Text = "Auto-respawn in 10s..."
timeoutLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
timeoutLabel.TextSize = 16
timeoutLabel.Font = Enum.Font.Gotham
timeoutLabel.Parent = promptFrame

-- Show prompt function
local offerTimeout
local function showRevivePrompt(donutCount)
	if donutCount <= 0 then
		return  -- No donuts, don't show
	end
	
	donutLabel.Text = "Revive Donuts: " .. donutCount
	promptFrame.Visible = true
	
	-- Countdown timer
	local timeLeft = 10
	offerTimeout = task.spawn(function()
		while timeLeft > 0 do
			timeoutLabel.Text = "Auto-respawn in " .. timeLeft .. "s..."
			task.wait(1)
			timeLeft -= 1
		end
		
		-- Timeout expired, hide prompt
		promptFrame.Visible = false
	end)
end

-- Revive button handler
reviveButton.Activated:Connect(function()
	RequestReviveEvent:FireServer()
	promptFrame.Visible = false
	
	if offerTimeout then
		task.cancel(offerTimeout)
	end
end)

-- Listen for offer revive event from server
local OfferReviveEvent = ReplicatedStorage:FindFirstChild("OfferReviveEvent")
if OfferReviveEvent then
	OfferReviveEvent.OnClientEvent:Connect(function(donutCount)
		showRevivePrompt(donutCount)
	end)
end

return {}
