-- RankConfig.lua
-- 20 rank progression system with thresholds and benefits

local RankConfig = {
	RANKS = {
		-- Rank 1: Starter
		{goldRequired = 0, magnet = 10, boostCD = 10.0, brakeCD = 8.0, shieldDuration = 10, name = "Worm"},
		-- Rank 2-5: Early progression
		{goldRequired = 100, magnet = 12, boostCD = 9.8, brakeCD = 7.85, shieldDuration = 9.5, name = "Serpent"},
		{goldRequired = 300, magnet = 14, boostCD = 9.6, brakeCD = 7.7, shieldDuration = 9, name = "Viper"},
		{goldRequired = 600, magnet = 16, boostCD = 9.4, brakeCD = 7.55, shieldDuration = 8.5, name = "Cobra"},
		{goldRequired = 1000, magnet = 18, boostCD = 9.2, brakeCD = 7.4, shieldDuration = 8, name = "Python"},
		-- Rank 6-10: Mid progression
		{goldRequired = 1500, magnet = 20, boostCD = 9.0, brakeCD = 7.25, shieldDuration = 7.5, name = "Boa"},
		{goldRequired = 2200, magnet = 23, boostCD = 8.8, brakeCD = 7.1, shieldDuration = 7, name = "Anaconda"},
		{goldRequired = 3000, magnet = 26, boostCD = 8.6, brakeCD = 6.95, shieldDuration = 6.8, name = "Mamba"},
		{goldRequired = 4000, magnet = 29, boostCD = 8.4, brakeCD = 6.8, shieldDuration = 6.6, name = "Rattler"},
		{goldRequired = 5500, magnet = 32, boostCD = 8.2, brakeCD = 6.65, shieldDuration = 6.4, name = "Adder"},
		-- Rank 11-15: Late progression
		{goldRequired = 7500, magnet = 35, boostCD = 8.0, brakeCD = 6.5, shieldDuration = 6.2, name = "Basilisk"},
		{goldRequired = 10000, magnet = 38, boostCD = 7.8, brakeCD = 6.35, shieldDuration = 6, name = "Hydra"},
		{goldRequired = 13500, magnet = 41, boostCD = 7.6, brakeCD = 6.2, shieldDuration = 5.8, name = "Wyrm"},
		{goldRequired = 18000, magnet = 44, boostCD = 7.4, brakeCD = 6.05, shieldDuration = 5.6, name = "Drake"},
		{goldRequired = 24000, magnet = 47, boostCD = 7.2, brakeCD = 5.9, shieldDuration = 5.4, name = "Wyvern"},
		-- Rank 16-20: End game
		{goldRequired = 31000, magnet = 50, boostCD = 7.0, brakeCD = 5.75, shieldDuration = 5.2, name = "Dragon"},
		{goldRequired = 40000, magnet = 54, boostCD = 6.8, brakeCD = 5.6, shieldDuration = 5.1, name = "Leviathan"},
		{goldRequired = 52000, magnet = 58, boostCD = 6.6, brakeCD = 5.45, shieldDuration = 5.05, name = "Jormungandr"},
		{goldRequired = 67000, magnet = 62, boostCD = 6.4, brakeCD = 5.3, shieldDuration = 5.02, name = "Quetzalcoatl"},
		{goldRequired = 86000, magnet = 66, boostCD = 6.2, brakeCD = 5.15, shieldDuration = 5, name = "Ouroboros"},
	},
}

-- Gets rank from gold amount
function RankConfig.GetRank(gold)
	local rank = 1
	for i = #RankConfig.RANKS, 1, -1 do
		if gold >= RankConfig.RANKS[i].goldRequired then
			rank = i
			break
		end
	end
	return rank
end

-- Gets rank data
function RankConfig.GetRankData(rank)
	return RankConfig.RANKS[rank] or RankConfig.RANKS[1]
end

-- Gets next rank threshold
function RankConfig.GetNextRankThreshold(currentRank)
	if currentRank >= #RankConfig.RANKS then
		return nil -- Max rank
	end
	return RankConfig.RANKS[currentRank + 1].goldRequired
end

return RankConfig
