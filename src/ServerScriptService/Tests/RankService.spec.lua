-- RankService.spec.lua
-- Unit tests for RankService

return function()
	local ServerScriptService = game:GetService("ServerScriptService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local RankService = require(ServerScriptService.GameSystems.RankService)
	local RankConfig = require(ReplicatedStorage.Modules.RankConfig)

	describe("RankService", function()
		describe("GetRank", function()
			it("should return rank 1 for 0 gold", function()
				local rank = RankService:GetRank(0)
				expect(rank).to.equal(1)
			end)

			it("should return rank 2 for 100+ gold", function()
				local rank = RankService:GetRank(100)
				expect(rank).to.equal(2)
			end)

			it("should return rank 5 for 1000+ gold", function()
				local rank = RankService:GetRank(1000)
				expect(rank).to.equal(5)
			end)

			it("should return rank 20 for max gold", function()
				local rank = RankService:GetRank(100000)
				expect(rank).to.equal(20)
			end)
		end)

		describe("GetMagnetRange", function()
			it("should return correct magnet range for rank 1", function()
				local magnet = RankService:GetMagnetRange(1)
				expect(magnet).to.equal(10)
			end)

			it("should increase magnet range with rank", function()
				local magnet1 = RankService:GetMagnetRange(1)
				local magnet10 = RankService:GetMagnetRange(10)
				expect(magnet10).to.be.greaterThan(magnet1)
			end)

			it("should return max magnet range for rank 20", function()
				local magnet = RankService:GetMagnetRange(20)
				expect(magnet).to.equal(66)
			end)
		end)

		describe("GetBoostCooldown", function()
			it("should return correct cooldown for rank 1", function()
				local cooldown = RankService:GetBoostCooldown(1)
				expect(cooldown).to.equal(10.0)
			end)

			it("should decrease cooldown with rank", function()
				local cd1 = RankService:GetBoostCooldown(1)
				local cd20 = RankService:GetBoostCooldown(20)
				expect(cd20).to.be.lessThan(cd1)
			end)
		end)

		describe("CheckRankUp", function()
			it("should not rank up if below threshold", function()
				local newRank = RankService:CheckRankUp(1, 50)
				expect(newRank).to.equal(1)
			end)

			it("should rank up if at threshold", function()
				local newRank = RankService:CheckRankUp(1, 100)
				expect(newRank).to.equal(2)
			end)

			it("should not rank up at max rank", function()
				local newRank = RankService:CheckRankUp(20, 1000000)
				expect(newRank).to.equal(20)
			end)
		end)

		describe("Rank Configuration", function()
			it("should have 20 ranks", function()
				expect(#RankConfig.RANKS).to.equal(20)
			end)

			it("should have increasing gold requirements", function()
				for i = 1, #RankConfig.RANKS - 1 do
					local current = RankConfig.RANKS[i].goldRequired
					local next = RankConfig.RANKS[i + 1].goldRequired
					expect(next).to.be.greaterThan(current)
				end
			end)

			it("should have all required fields", function()
				for i, rank in ipairs(RankConfig.RANKS) do
					expect(rank.goldRequired).to.be.ok()
					expect(rank.magnet).to.be.ok()
					expect(rank.boostCD).to.be.ok()
					expect(rank.brakeCD).to.be.ok()
					expect(rank.shieldDuration).to.be.ok()
					expect(rank.name).to.be.ok()
				end
			end)
		end)
	end)
end
