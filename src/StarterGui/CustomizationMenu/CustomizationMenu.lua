-- CustomizationMenu.lua
-- Color picker, mouth/eye styles

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomizationData = require(ReplicatedStorage.Modules.CustomizationData)
local UpdateCustomizationEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UpdateCustomization")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create menu (initially hidden)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomizationMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 500, 0, 600)
menuFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = menuFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "CUSTOMIZE SNAKE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 26
title.Font = Enum.Font.GothamBold
title.Parent = menuFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 24
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = menuFrame

closeButton.Activated:Connect(function()
	menuFrame.Visible = false
end)

-- Color presets section
local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(1, -20, 0, 30)
colorLabel.Position = UDim2.new(0, 10, 0, 60)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Select Color:"
colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
colorLabel.TextSize = 20
colorLabel.Font = Enum.Font.GothamBold
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.Parent = menuFrame

local colorGrid = Instance.new("Frame")
colorGrid.Size = UDim2.new(1, -20, 0, 200)
colorGrid.Position = UDim2.new(0, 10, 0, 95)
colorGrid.BackgroundTransparency = 1
colorGrid.Parent = menuFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 80, 0, 80)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = colorGrid

-- Create color buttons
local selectedColor = CustomizationData.DefaultColor

for i, color in ipairs(CustomizationData.ColorPresets) do
	local colorButton = Instance.new("TextButton")
	colorButton.Size = UDim2.new(1, 0, 1, 0)
	colorButton.BackgroundColor3 = color
	colorButton.BorderSizePixel = 2
	colorButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
	colorButton.Text = ""
	colorButton.LayoutOrder = i
	colorButton.Parent = colorGrid
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0.3, 0)
	buttonCorner.Parent = colorButton
	
	colorButton.Activated:Connect(function()
		selectedColor = color
		-- Visual feedback could be added here
	end)
end

-- Apply button
local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(0, 200, 0, 50)
applyButton.Position = UDim2.new(0.5, -100, 1, -70)
applyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
applyButton.Text = "APPLY"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.TextSize = 22
applyButton.Font = Enum.Font.GothamBold
applyButton.Parent = menuFrame

local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 10)
applyCorner.Parent = applyButton

applyButton.Activated:Connect(function()
	-- Send customization to server
	local customizationData = {
		color = selectedColor,
		mouthStyle = "default",
		eyeStyle = "default",
		effect = "none"
	}
	
	UpdateCustomizationEvent:FireServer(customizationData)
	menuFrame.Visible = false
end)

-- Toggle button (top-right of screen)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(1, -80, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.Text = "CUSTOMIZE"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 12
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextWrapped = true
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.5, 0)
toggleCorner.Parent = toggleButton

toggleButton.Activated:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end)

return {}
