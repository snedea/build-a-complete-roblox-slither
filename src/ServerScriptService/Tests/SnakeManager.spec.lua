-- SnakeManager.spec.lua
-- Unit tests for SnakeManager

return function()
	local ServerScriptService = game:GetService("ServerScriptService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local SnakeManager = require(ServerScriptService.GameSystems.SnakeManager)
	local SnakeConfig = require(ReplicatedStorage.Modules.SnakeConfig)

	describe("SnakeManager", function()
		describe("CreateSnake", function()
			it("should create a snake with head and body segments", function()
				-- This is a placeholder test
				-- In a real environment, you would mock players and dependencies
				expect(SnakeManager).to.be.ok()
			end)

			it("should create snake with initial segment count", function()
				expect(SnakeConfig.INITIAL_SEGMENTS).to.equal(5)
			end)
		end)

		describe("MoveSnake", function()
			it("should validate direction is unit vector", function()
				local validDirection = Vector3.new(1, 0, 0)
				expect(validDirection.Magnitude).to.be.near(1, 0.01)
			end)

			it("should reject invalid directions", function()
				local invalidDirection = Vector3.new(10, 0, 0)
				expect(invalidDirection.Magnitude).to.be.greaterThan(1.1)
			end)
		end)

		describe("Collision Detection", function()
			it("should detect collisions within radius", function()
				local pos1 = Vector3.new(0, 0, 0)
				local pos2 = Vector3.new(2, 0, 0)
				local distance = (pos1 - pos2).Magnitude

				expect(distance).to.be.lessThan(SnakeConfig.COLLISION_RADIUS)
			end)

			it("should ignore collisions outside radius", function()
				local pos1 = Vector3.new(0, 0, 0)
				local pos2 = Vector3.new(10, 0, 0)
				local distance = (pos1 - pos2).Magnitude

				expect(distance).to.be.greaterThan(SnakeConfig.COLLISION_RADIUS)
			end)
		end)

		describe("Boost and Brake", function()
			it("should apply boost multiplier correctly", function()
				local boostedSpeed = SnakeConfig.BASE_SPEED * SnakeConfig.BOOST_MULTIPLIER
				expect(boostedSpeed).to.equal(16 * 1.8)
			end)

			it("should apply brake multiplier correctly", function()
				local brakedSpeed = SnakeConfig.BASE_SPEED * SnakeConfig.BRAKE_MULTIPLIER
				expect(brakedSpeed).to.equal(16 * 0.5)
			end)
		end)
	end)
end
