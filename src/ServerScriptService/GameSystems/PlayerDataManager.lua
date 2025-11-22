-- PlayerDataManager.lua
-- DataStore persistence for rank, gold, donuts, customization, stats

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local PlayerDataStore
local success, err = pcall(function()
	PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
end)

if not success then
	warn("[PlayerDataManager] DataStore not available (Studio mode or API disabled):", err)
end

local PlayerDataManager = {}
PlayerDataManager._cache = {} -- In-memory cache [userId] = data

-- Default player data
local DEFAULT_DATA = {
	version = 1,
	data = {
		rank = 1,
		gold = 0,
		reviveDonuts = 3, -- Free starter donuts
		customization = {
			color = Color3.fromRGB(255, 100, 100), -- Default red
			mouth = "Default",
			eyes = "Default",
			effects = {},
		},
		stats = {
			totalKills = 0,
			longestLength = 0,
			totalFood = 0,
			gamesPlayed = 0,
		},
	}
}

-- Deep copy table
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Retry logic with exponential backoff
local function retryOperation(operation, maxRetries)
	maxRetries = maxRetries or 3
	local attempts = 0
	local success, result

	while attempts < maxRetries do
		attempts = attempts + 1
		success, result = pcall(operation)

		if success then
			return true, result
		else
			if attempts < maxRetries then
				local waitTime = 2 ^ attempts -- Exponential backoff
				warn(string.format("[PlayerDataManager] Retry %d/%d after %.1fs: %s", attempts, maxRetries, waitTime, tostring(result)))
				task.wait(waitTime)
			end
		end
	end

	return false, result
end

-- Loads player data from DataStore
function PlayerDataManager:LoadData(player)
	local userId = player.UserId
	local key = "Player_" .. userId

	-- Check if Studio (mock data)
	if RunService:IsStudio() then
		print("[PlayerDataManager] Studio mode: Using default data for", player.Name)
		self._cache[userId] = deepCopy(DEFAULT_DATA.data)
		return self._cache[userId]
	end

	-- Try to load from DataStore
	local success, data = retryOperation(function()
		return PlayerDataStore:GetAsync(key)
	end)

	if success and data then
		-- Validate version and migrate if needed
		if data.version == 1 then
			self._cache[userId] = data.data
			print("[PlayerDataManager] Loaded data for", player.Name)
		else
			warn("[PlayerDataManager] Unknown data version for", player.Name, "- using defaults")
			self._cache[userId] = deepCopy(DEFAULT_DATA.data)
		end
	else
		-- First time player or load failed
		warn("[PlayerDataManager] Load failed for", player.Name, "- using defaults")
		self._cache[userId] = deepCopy(DEFAULT_DATA.data)
	end

	return self._cache[userId]
end

-- Saves player data to DataStore
function PlayerDataManager:SaveData(player)
	local userId = player.UserId
	local key = "Player_" .. userId

	local data = self._cache[userId]
	if not data then
		warn("[PlayerDataManager] No cached data to save for", player.Name)
		return false
	end

	-- Skip save in Studio
	if RunService:IsStudio() then
		print("[PlayerDataManager] Studio mode: Skipping save for", player.Name)
		return true
	end

	-- Save with retry logic
	local success, err = retryOperation(function()
		PlayerDataStore:UpdateAsync(key, function(oldData)
			-- Return new data wrapped in version
			return {
				version = 1,
				data = data,
			}
		end)
	end)

	if success then
		print("[PlayerDataManager] Saved data for", player.Name)
		return true
	else
		warn("[PlayerDataManager] Save failed for", player.Name, ":", err)
		return false
	end
end

-- Gets player data (from cache)
function PlayerDataManager:GetData(player)
	return self._cache[player.UserId]
end

-- Gold operations
function PlayerDataManager:AddGold(player, amount)
	local data = self:GetData(player)
	if data then
		data.gold = data.gold + amount
		return data.gold
	end
end

function PlayerDataManager:DeductGold(player, amount)
	local data = self:GetData(player)
	if data and data.gold >= amount then
		data.gold = data.gold - amount
		return true
	end
	return false
end

function PlayerDataManager:GetGold(player)
	local data = self:GetData(player)
	return data and data.gold or 0
end

-- Donut operations
function PlayerDataManager:AddDonuts(player, amount)
	local data = self:GetData(player)
	if data then
		data.reviveDonuts = data.reviveDonuts + amount
		return data.reviveDonuts
	end
end

function PlayerDataManager:UseDonuts(player, amount)
	local data = self:GetData(player)
	if data and data.reviveDonuts >= amount then
		data.reviveDonuts = data.reviveDonuts - amount
		return true
	end
	return false
end

function PlayerDataManager:GetDonuts(player)
	local data = self:GetData(player)
	return data and data.reviveDonuts or 0
end

-- Rank operations
function PlayerDataManager:GetRank(player)
	local data = self:GetData(player)
	return data and data.rank or 1
end

function PlayerDataManager:SetRank(player, rank)
	local data = self:GetData(player)
	if data then
		data.rank = rank
	end
end

-- Customization operations
function PlayerDataManager:GetCustomization(player)
	local data = self:GetData(player)
	return data and data.customization or DEFAULT_DATA.data.customization
end

function PlayerDataManager:SetCustomization(player, customization)
	local data = self:GetData(player)
	if data then
		data.customization = customization
	end
end

-- Stats operations
function PlayerDataManager:IncrementStat(player, statName, amount)
	local data = self:GetData(player)
	if data and data.stats[statName] then
		data.stats[statName] = data.stats[statName] + (amount or 1)
	end
end

function PlayerDataManager:SetStat(player, statName, value)
	local data = self:GetData(player)
	if data and data.stats[statName] ~= nil then
		data.stats[statName] = value
	end
end

function PlayerDataManager:GetStats(player)
	local data = self:GetData(player)
	return data and data.stats or DEFAULT_DATA.data.stats
end

-- Initialize for all players
function PlayerDataManager:Initialize()
	-- Load data for existing players
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			self:LoadData(player)
		end)
	end

	-- Handle new players
	Players.PlayerAdded:Connect(function(player)
		self:LoadData(player)
	end)

	-- Save on player leave
	Players.PlayerRemoving:Connect(function(player)
		self:SaveData(player)
		self._cache[player.UserId] = nil
	end)

	-- Periodic auto-save every 5 minutes
	task.spawn(function()
		while true do
			task.wait(300) -- 5 minutes
			for _, player in ipairs(Players:GetPlayers()) do
				task.spawn(function()
					self:SaveData(player)
				end)
			end
		end
	end)

	print("[PlayerDataManager] Initialized")
end

return PlayerDataManager
