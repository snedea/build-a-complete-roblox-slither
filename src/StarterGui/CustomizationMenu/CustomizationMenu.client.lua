-- CustomizationMenu.client.lua
-- Color picker, mouth/eye selection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameEvent")
local CustomizationData = require(ReplicatedStorage.Modules.CustomizationData)

-- Create customization menu (hidden by default)
local screenGui = script.Parent.Parent
local menuFrame = Instance.new("Frame")
menuFrame.Name = "CustomizationMenu"
menuFrame.Size = UDim2.new(0, 400, 0, 500)
menuFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.BackgroundTransparency = 0.2
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = menuFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "CUSTOMIZATION"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = menuFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = menuFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

-- Color grid
local colorLabel = Instance.new("TextLabel")
colorLabel.Name = "ColorLabel"
colorLabel.Size = UDim2.new(1, -40, 0, 30)
colorLabel.Position = UDim2.new(0, 20, 0, 60)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "Snake Color:"
colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
colorLabel.TextSize = 18
colorLabel.Font = Enum.Font.GothamBold
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.Parent = menuFrame

local colorGrid = Instance.new("Frame")
colorGrid.Name = "ColorGrid"
colorGrid.Size = UDim2.new(1, -40, 0, 200)
colorGrid.Position = UDim2.new(0, 20, 0, 95)
colorGrid.BackgroundTransparency = 1
colorGrid.Parent = menuFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 50, 0, 50)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = colorGrid

-- Apply button
local applyButton = Instance.new("TextButton")
applyButton.Name = "ApplyButton"
applyButton.Size = UDim2.new(0, 200, 0, 50)
applyButton.Position = UDim2.new(0.5, -100, 1, -70)
applyButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
applyButton.BorderSizePixel = 0
applyButton.Text = "APPLY"
applyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
applyButton.TextSize = 20
applyButton.Font = Enum.Font.GothamBold
applyButton.Parent = menuFrame

local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 10)
applyCorner.Parent = applyButton

-- State
local selectedColor = Color3.fromRGB(255, 100, 100)
local playerRank = 1

-- Creates color button
local function createColorButton(colorData)
	local button = Instance.new("TextButton")
	button.Name = "Color_" .. colorData.name
	button.BackgroundColor3 = colorData.color
	button.BorderSizePixel = 2
	button.BorderColor3 = Color3.fromRGB(255, 255, 255)
	button.Text = ""
	button.AutoButtonColor = false

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0.3, 0)
	buttonCorner.Parent = button

	-- Lock if not unlocked
	if playerRank < colorData.unlockRank then
		button.BackgroundTransparency = 0.7

		local lockLabel = Instance.new("TextLabel")
		lockLabel.Size = UDim2.new(1, 0, 1, 0)
		lockLabel.BackgroundTransparency = 1
		lockLabel.Text = "🔒"
		lockLabel.TextSize = 24
		lockLabel.Parent = button
	else
		button.MouseButton1Click:Connect(function()
			selectedColor = colorData.color

			-- Update all button borders
			for _, child in ipairs(colorGrid:GetChildren()) do
				if child:IsA("TextButton") then
					child.BorderSizePixel = 2
					child.BorderColor3 = Color3.fromRGB(255, 255, 255)
				end
			end

			-- Highlight selected
			button.BorderSizePixel = 4
			button.BorderColor3 = Color3.fromRGB(255, 255, 0)
		end)
	end

	return button
end

-- Populates color grid
local function populateColors(rank)
	-- Clear existing
	for _, child in ipairs(colorGrid:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- Add color buttons
	for _, colorData in ipairs(CustomizationData.COLORS) do
		local button = createColorButton(colorData)
		button.Parent = colorGrid
	end
end

-- Toggle menu visibility
local function toggleMenu()
	menuFrame.Visible = not menuFrame.Visible
end

-- Close button
closeButton.MouseButton1Click:Connect(function()
	menuFrame.Visible = false
end)

-- Apply button
applyButton.MouseButton1Click:Connect(function()
	-- Send customization to server
	local customization = {
		color = selectedColor,
		mouth = "Default",
		eyes = "Default",
		effects = {},
	}

	remoteEvent:FireServer("SetCustomization", customization)
	menuFrame.Visible = false
end)

-- Keyboard shortcut (C key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.C then
		toggleMenu()
	end
end)

-- Listen for initial data
remoteEvent.OnClientEvent:Connect(function(eventType, data)
	if eventType == "InitialData" then
		playerRank = data.rank or 1
		selectedColor = data.customization and data.customization.color or Color3.fromRGB(255, 100, 100)
		populateColors(playerRank)
	elseif eventType == "RankUp" then
		playerRank = data
		populateColors(playerRank)
	end
end)

print("[CustomizationMenu] Initialized (Press C to open)")
