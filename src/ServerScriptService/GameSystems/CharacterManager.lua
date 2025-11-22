-- CharacterManager.lua
-- Disables default Roblox character spawning since we use custom snakes

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local CharacterManager = {}

function CharacterManager:Initialize()
	-- Disable character auto-spawn
	Players.CharacterAutoLoads = false

	-- Remove any existing characters
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			player.Character:Destroy()
		end
	end

	-- Prevent character spawning for new players
	Players.PlayerAdded:Connect(function(player)
		-- Clear any character that gets spawned
		if player.Character then
			player.Character:Destroy()
		end

		player.CharacterAdded:Connect(function(character)
			-- Destroy any auto-spawned character
			character:Destroy()
		end)
	end)

	print("[CharacterManager] Default character spawning disabled")
end

return CharacterManager
