-- SpatialGrid.lua
-- O(n) collision detection via spatial partitioning
-- Divides arena into 64x64 stud cells for efficient proximity queries

local SpatialGrid = {}
SpatialGrid.__index = SpatialGrid

local CELL_SIZE = 64 -- Studs per cell

-- Creates a new SpatialGrid instance
function SpatialGrid.new()
	local self = setmetatable({}, SpatialGrid)
	self._cells = {} -- [cellKey] = {part1, part2, ...}
	self._partToCell = {} -- [part] = cellKey (for fast removal)
	return self
end

-- Converts world position to cell key
function SpatialGrid:_positionToCellKey(position)
	local cellX = math.floor(position.X / CELL_SIZE)
	local cellZ = math.floor(position.Z / CELL_SIZE)
	return string.format("%d,%d", cellX, cellZ)
end

-- Parses cell key back to cell coordinates
function SpatialGrid:_cellKeyToCoords(cellKey)
	local x, z = cellKey:match("(-?%d+),(-?%d+)")
	return tonumber(x), tonumber(z)
end

-- Inserts a part into the grid at the given position
function SpatialGrid:Insert(part, position)
	-- Remove from old cell if exists
	self:Remove(part)

	local cellKey = self:_positionToCellKey(position)

	-- Initialize cell if doesn't exist
	if not self._cells[cellKey] then
		self._cells[cellKey] = {}
	end

	-- Add part to cell
	table.insert(self._cells[cellKey], part)
	self._partToCell[part] = cellKey

	return cellKey
end

-- Removes a part from the grid
function SpatialGrid:Remove(part)
	local cellKey = self._partToCell[part]
	if not cellKey then
		return
	end

	local cell = self._cells[cellKey]
	if cell then
		for i, p in ipairs(cell) do
			if p == part then
				table.remove(cell, i)
				break
			end
		end

		-- Clean up empty cells
		if #cell == 0 then
			self._cells[cellKey] = nil
		end
	end

	self._partToCell[part] = nil
end

-- Gets all parts within radius of position (checks same + 8 adjacent cells)
function SpatialGrid:GetNearby(position, radius)
	local centerCellKey = self:_positionToCellKey(position)
	local centerX, centerZ = self:_cellKeyToCoords(centerCellKey)

	local nearbyParts = {}
	local radiusSquared = radius * radius

	-- Check 3x3 grid of cells (same + 8 adjacent)
	for dx = -1, 1 do
		for dz = -1, 1 do
			local cellKey = string.format("%d,%d", centerX + dx, centerZ + dz)
			local cell = self._cells[cellKey]

			if cell then
				for _, part in ipairs(cell) do
					-- Distance check for accuracy
					if part:IsA("BasePart") then
						local distance = (part.Position - position).Magnitude
						if distance <= radius then
							table.insert(nearbyParts, part)
						end
					end
				end
			end
		end
	end

	return nearbyParts
end

-- Gets all parts in a specific cell
function SpatialGrid:GetCell(position)
	local cellKey = self:_positionToCellKey(position)
	return self._cells[cellKey] or {}
end

-- Clears all parts from the grid
function SpatialGrid:Clear()
	self._cells = {}
	self._partToCell = {}
end

-- Gets total number of parts in grid
function SpatialGrid:GetCount()
	local count = 0
	for _, cell in pairs(self._cells) do
		count = count + #cell
	end
	return count
end

return SpatialGrid
