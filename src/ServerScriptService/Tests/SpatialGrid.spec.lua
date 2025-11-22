-- SpatialGrid.spec.lua
-- Unit tests for SpatialGrid spatial partitioning

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpatialGrid = require(ReplicatedStorage.Shared.SpatialGrid)

return function()
	describe("SpatialGrid", function()
		it("should create a new grid with default cell size", function()
			local grid = SpatialGrid.new()
			expect(grid).to.be.ok()
			expect(grid.cellSize).to.equal(64)
		end)
		
		it("should create a grid with custom cell size", function()
			local grid = SpatialGrid.new(32)
			expect(grid.cellSize).to.equal(32)
		end)
		
		it("should insert and query objects", function()
			local grid = SpatialGrid.new(64)
			local object = {name = "test"}
			local position = Vector3.new(0, 0, 0)
			
			grid:Insert(position, object)
			local results = grid:Query(position, 10)
			
			expect(#results).to.equal(1)
			expect(results[1]).to.equal(object)
		end)
		
		it("should remove objects", function()
			local grid = SpatialGrid.new(64)
			local object = {name = "test"}
			local position = Vector3.new(0, 0, 0)
			
			grid:Insert(position, object)
			grid:Remove(position, object)
			local results = grid:Query(position, 10)
			
			expect(#results).to.equal(0)
		end)
		
		it("should handle multiple objects in same cell", function()
			local grid = SpatialGrid.new(64)
			local obj1 = {name = "obj1"}
			local obj2 = {name = "obj2"}
			local position = Vector3.new(0, 0, 0)
			
			grid:Insert(position, obj1)
			grid:Insert(position, obj2)
			local results = grid:Query(position, 10)
			
			expect(#results).to.equal(2)
		end)
		
		it("should query across multiple cells", function()
			local grid = SpatialGrid.new(64)
			local obj1 = {name = "obj1"}
			local obj2 = {name = "obj2"}
			
			grid:Insert(Vector3.new(0, 0, 0), obj1)
			grid:Insert(Vector3.new(100, 0, 0), obj2)
			
			local results = grid:Query(Vector3.new(50, 0, 0), 100)
			expect(#results).to.equal(2)
		end)
		
		it("should handle negative positions", function()
			local grid = SpatialGrid.new(64)
			local object = {name = "test"}
			local position = Vector3.new(-100, 0, -100)
			
			grid:Insert(position, object)
			local results = grid:Query(position, 10)
			
			expect(#results).to.equal(1)
		end)
		
		it("should clear all objects", function()
			local grid = SpatialGrid.new(64)
			grid:Insert(Vector3.new(0, 0, 0), {})
			grid:Insert(Vector3.new(100, 0, 0), {})
			
			grid:Clear()
			expect(grid:GetObjectCount()).to.equal(0)
		end)
	end)
end
