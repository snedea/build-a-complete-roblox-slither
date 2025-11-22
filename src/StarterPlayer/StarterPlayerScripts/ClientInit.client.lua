-- init.client.lua
-- Client initialization script for Slither Simulator

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- Disable default Roblox UI elements
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

-- Wait for scripts to load
local playerScripts = player:WaitForChild("PlayerScripts")

-- Load controllers
local CameraController = require(playerScripts:WaitForChild("CameraController"))
local SnakeController = require(playerScripts:WaitForChild("SnakeController"))
local SnakeRenderer = require(playerScripts:WaitForChild("SnakeRenderer"))
local MobileControls = require(playerScripts:WaitForChild("MobileControls"))

-- Initialize in order
print("[Client] Initializing Slither Simulator client...")

CameraController:Initialize()
SnakeController:Initialize()
SnakeRenderer:Initialize()
MobileControls:Initialize(SnakeController)

-- Set camera to arena center initially
CameraController:SetTargetPosition(Vector3.new(0, 0, 0))

print("[Client] Client initialized successfully!")
