-- init.lua
-- Test runner for all specs
-- Run this script in Roblox Studio to execute all tests

local TestEZ = require(game:GetService("ReplicatedStorage"):WaitForChild("TestEZ"))

-- Run all tests
local results = TestEZ.TestBootstrap:run({
	script.Parent.SnakeManager,
	script.Parent.RankService,
	script.Parent.FoodSpawner,
	script.Parent.PlayerDataManager,
})

-- Print results
if results.failureCount == 0 then
	print(string.format("[Tests] ✅ All %d tests passed!", results.successCount))
else
	warn(string.format("[Tests] ❌ %d tests failed out of %d", results.failureCount, results.successCount + results.failureCount))
end

return results
