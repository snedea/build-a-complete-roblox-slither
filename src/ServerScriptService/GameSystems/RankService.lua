-- RankService.lua
-- Rank progression calculations, magnet range/boost/brake stat calculations

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RankConfig = require(ReplicatedStorage.Modules.RankConfig)

local RankService = {}

-- Gets rank from gold amount
function RankService:GetRank(gold)
	return RankConfig.GetRank(gold)
end

-- Gets rank data (magnet, cooldowns, shield duration)
function RankService:GetRankData(rank)
	return RankConfig.GetRankData(rank)
end

-- Gets magnet range in studs for given rank
function RankService:GetMagnetRange(rank)
	local rankData = self:GetRankData(rank)
	return rankData.magnet
end

-- Gets boost cooldown in seconds for given rank
function RankService:GetBoostCooldown(rank)
	local rankData = self:GetRankData(rank)
	return rankData.boostCD
end

-- Gets brake cooldown in seconds for given rank
function RankService:GetBrakeCooldown(rank)
	local rankData = self:GetRankData(rank)
	return rankData.brakeCD
end

-- Gets shield duration in seconds for given rank
function RankService:GetShieldDuration(rank)
	local rankData = self:GetRankData(rank)
	return rankData.shieldDuration
end

-- Gets gold required for specific rank
function RankService:GetRankThreshold(rank)
	local rankData = self:GetRankData(rank)
	return rankData.goldRequired
end

-- Gets next rank threshold (for progress bar)
function RankService:GetNextRankThreshold(currentRank)
	return RankConfig.GetNextRankThreshold(currentRank)
end

-- Gets rank name
function RankService:GetRankName(rank)
	local rankData = self:GetRankData(rank)
	return rankData.name or "Unknown"
end

-- Checks if player should rank up
function RankService:CheckRankUp(currentRank, gold)
	local nextThreshold = self:GetNextRankThreshold(currentRank)
	if nextThreshold and gold >= nextThreshold then
		return currentRank + 1
	end
	return currentRank
end

return RankService
