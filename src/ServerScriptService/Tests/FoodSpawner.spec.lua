-- FoodSpawner.spec.lua
-- Unit tests for FoodSpawner

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local FoodConfig = require(ReplicatedStorage.Modules.FoodConfig)
	local SpatialGrid = require(ReplicatedStorage.Shared.SpatialGrid)

	describe("FoodSpawner", function()
		describe("Food Configuration", function()
			it("should have defined food types", function()
				expect(FoodConfig.TYPES.SMALL).to.be.ok()
				expect(FoodConfig.TYPES.MEDIUM).to.be.ok()
				expect(FoodConfig.TYPES.LARGE).to.be.ok()
			end)

			it("should have weighted spawn probabilities", function()
				expect(FoodConfig.TYPES.SMALL.weight).to.equal(70)
				expect(FoodConfig.TYPES.MEDIUM.weight).to.equal(25)
				expect(FoodConfig.TYPES.LARGE.weight).to.equal(5)
			end)

			it("should have different gold values", function()
				expect(FoodConfig.TYPES.SMALL.gold).to.equal(1)
				expect(FoodConfig.TYPES.MEDIUM.gold).to.equal(3)
				expect(FoodConfig.TYPES.LARGE.gold).to.equal(5)
			end)
		end)

		describe("GetRandomFoodType", function()
			it("should return valid food type", function()
				local typeName, foodType = FoodConfig.GetRandomFoodType()
				expect(typeName).to.be.ok()
				expect(foodType).to.be.ok()
				expect(foodType.size).to.be.ok()
				expect(foodType.gold).to.be.ok()
			end)
		end)

		describe("CalculateReward", function()
			it("should calculate base reward for rank 1", function()
				local reward = FoodConfig.CalculateReward(FoodConfig.TYPES.SMALL, 1)
				expect(reward).to.equal(1)
			end)

			it("should increase reward with rank", function()
				local reward1 = FoodConfig.CalculateReward(FoodConfig.TYPES.SMALL, 1)
				local reward10 = FoodConfig.CalculateReward(FoodConfig.TYPES.SMALL, 10)
				expect(reward10).to.be.greaterThan(reward1)
			end)

			it("should scale with food type", function()
				local smallReward = FoodConfig.CalculateReward(FoodConfig.TYPES.SMALL, 5)
				local largeReward = FoodConfig.CalculateReward(FoodConfig.TYPES.LARGE, 5)
				expect(largeReward).to.be.greaterThan(smallReward)
			end)
		end)

		describe("Poisson Disk Distribution", function()
			it("should enforce minimum distance", function()
				local minDist = FoodConfig.MIN_DISTANCE
				expect(minDist).to.equal(15)
			end)

			it("should have max food limit", function()
				expect(FoodConfig.MAX_FOOD).to.equal(500)
			end)
		end)

		describe("SpatialGrid", function()
			it("should insert and retrieve parts", function()
				local grid = SpatialGrid.new()
				local part = Instance.new("Part")
				part.Position = Vector3.new(0, 0, 0)

				grid:Insert(part, part.Position)
				local nearby = grid:GetNearby(Vector3.new(5, 0, 5), 20)

				expect(#nearby).to.be.greaterThan(0)

				part:Destroy()
			end)

			it("should not find distant parts", function()
				local grid = SpatialGrid.new()
				local part = Instance.new("Part")
				part.Position = Vector3.new(0, 0, 0)

				grid:Insert(part, part.Position)
				local nearby = grid:GetNearby(Vector3.new(1000, 0, 1000), 20)

				expect(#nearby).to.equal(0)

				part:Destroy()
			end)
		end)
	end)
end
