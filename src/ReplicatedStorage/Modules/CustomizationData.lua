-- CustomizationData.lua
-- Available colors, mouth/eye styles, and effects

local CustomizationData = {
	-- Snake Colors (Body + Head)
	COLORS = {
		{name = "Ruby Red", color = Color3.fromRGB(255, 100, 100), unlockRank = 1},
		{name = "Emerald Green", color = Color3.fromRGB(100, 255, 100), unlockRank = 1},
		{name = "Sapphire Blue", color = Color3.fromRGB(100, 100, 255), unlockRank = 1},
		{name = "Golden Yellow", color = Color3.fromRGB(255, 255, 100), unlockRank = 1},
		{name = "Amethyst Purple", color = Color3.fromRGB(200, 100, 255), unlockRank = 2},
		{name = "Tangerine Orange", color = Color3.fromRGB(255, 150, 50), unlockRank = 2},
		{name = "Hot Pink", color = Color3.fromRGB(255, 100, 200), unlockRank = 3},
		{name = "Cyan", color = Color3.fromRGB(100, 255, 255), unlockRank = 3},
		{name = "Lime", color = Color3.fromRGB(200, 255, 100), unlockRank = 4},
		{name = "Magenta", color = Color3.fromRGB(255, 100, 255), unlockRank = 5},
		{name = "Midnight Black", color = Color3.fromRGB(50, 50, 50), unlockRank = 6},
		{name = "Pearl White", color = Color3.fromRGB(255, 255, 255), unlockRank = 7},
		{name = "Toxic Green", color = Color3.fromRGB(150, 255, 50), unlockRank = 8},
		{name = "Electric Blue", color = Color3.fromRGB(50, 200, 255), unlockRank = 9},
		{name = "Fire Red", color = Color3.fromRGB(255, 50, 50), unlockRank = 10},
		{name = "Rainbow", color = Color3.fromRGB(255, 200, 150), unlockRank = 15, special = true},
		{name = "Galaxy", color = Color3.fromRGB(100, 50, 150), unlockRank = 20, special = true},
	},

	-- Mouth Styles (cosmetic only)
	MOUTHS = {
		{name = "Default", unlockRank = 1},
		{name = "Smile", unlockRank = 3},
		{name = "Fangs", unlockRank = 5},
		{name = "Grin", unlockRank = 8},
		{name = "Fierce", unlockRank = 12},
	},

	-- Eye Styles (cosmetic only)
	EYES = {
		{name = "Default", unlockRank = 1},
		{name = "Cute", unlockRank = 2},
		{name = "Angry", unlockRank = 4},
		{name = "Sleepy", unlockRank = 6},
		{name = "Glowing", unlockRank = 10},
		{name = "Dragon", unlockRank = 15},
	},

	-- Particle Effects (trail behind snake)
	EFFECTS = {
		{name = "None", unlockRank = 1},
		{name = "Sparkles", unlockRank = 7, particleType = "Sparkles"},
		{name = "Fire", unlockRank = 11, particleType = "Fire"},
		{name = "Smoke", unlockRank = 14, particleType = "Smoke"},
		{name = "Stars", unlockRank = 18, particleType = "Sparkles"},
	},
}

-- Gets unlocked items for player rank
function CustomizationData.GetUnlockedColors(rank)
	local unlocked = {}
	for _, colorData in ipairs(CustomizationData.COLORS) do
		if rank >= colorData.unlockRank then
			table.insert(unlocked, colorData)
		end
	end
	return unlocked
end

function CustomizationData.GetUnlockedMouths(rank)
	local unlocked = {}
	for _, mouth in ipairs(CustomizationData.MOUTHS) do
		if rank >= mouth.unlockRank then
			table.insert(unlocked, mouth)
		end
	end
	return unlocked
end

function CustomizationData.GetUnlockedEyes(rank)
	local unlocked = {}
	for _, eyes in ipairs(CustomizationData.EYES) do
		if rank >= eyes.unlockRank then
			table.insert(unlocked, eyes)
		end
	end
	return unlocked
end

function CustomizationData.GetUnlockedEffects(rank)
	local unlocked = {}
	for _, effect in ipairs(CustomizationData.EFFECTS) do
		if rank >= effect.unlockRank then
			table.insert(unlocked, effect)
		end
	end
	return unlocked
end

-- Validates customization choices
function CustomizationData.ValidateCustomization(customization, rank)
	local valid = {
		color = Color3.fromRGB(255, 100, 100), -- Default red
		mouth = "Default",
		eyes = "Default",
		effects = {},
	}

	-- Validate color
	if customization.color then
		for _, colorData in ipairs(CustomizationData.COLORS) do
			if colorData.color == customization.color and rank >= colorData.unlockRank then
				valid.color = customization.color
				break
			end
		end
	end

	-- Validate mouth
	if customization.mouth then
		for _, mouth in ipairs(CustomizationData.MOUTHS) do
			if mouth.name == customization.mouth and rank >= mouth.unlockRank then
				valid.mouth = customization.mouth
				break
			end
		end
	end

	-- Validate eyes
	if customization.eyes then
		for _, eyes in ipairs(CustomizationData.EYES) do
			if eyes.name == customization.eyes and rank >= eyes.unlockRank then
				valid.eyes = customization.eyes
				break
			end
		end
	end

	return valid
end

return CustomizationData
