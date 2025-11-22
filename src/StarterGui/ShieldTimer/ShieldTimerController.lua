--[[
	ShieldTimerController.lua
	Shield countdown overlay

	Display shield timer during spawn protection
	Author: Context Foundry Builder
]]

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ShieldTimerController = {}

local timerGui = nil
local timerLabel = nil
local shieldActive = false
local shieldExpiry = 0

-- Initialize shield timer
function ShieldTimerController:Initialize()
	self:CreateTimer()
	self:StartUpdateLoop()
end

-- Create shield timer GUI
function ShieldTimerController:CreateTimer()
	timerGui = Instance.new("ScreenGui")
	timerGui.Name = "ShieldTimer"
	timerGui.ResetOnSpawn = false
	timerGui.Parent = PlayerGui

	-- Timer label
	timerLabel = Instance.new("TextLabel")
	timerLabel.Size = UDim2.new(0, 150, 0, 50)
	timerLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
	timerLabel.AnchorPoint = Vector2.new(0.5, 0)
	timerLabel.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	timerLabel.BackgroundTransparency = 0.3
	timerLabel.Text = "SHIELD: 5s"
	timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerLabel.TextScaled = true
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.Visible = false
	timerLabel.Parent = timerGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = timerLabel
end

-- Activate shield timer
function ShieldTimerController:ActivateShield(duration)
	shieldActive = true
	shieldExpiry = tick() + duration
	timerLabel.Visible = true
end

-- Update shield timer
function ShieldTimerController:StartUpdateLoop()
	task.spawn(function()
		while true do
			task.wait(0.1)

			if shieldActive then
				local remaining = math.max(0, shieldExpiry - tick())

				if remaining > 0 then
					timerLabel.Text = string.format("SHIELD: %.1fs", remaining)
				else
					shieldActive = false
					timerLabel.Visible = false
				end
			end
		end
	end)
end

-- Start controller
ShieldTimerController:Initialize()

return ShieldTimerController
