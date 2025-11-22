-- BodySegmentPool.lua
-- Object pooling to prevent GC spikes from dynamic segments
-- Preallocates segments, reuses instead of create/destroy

local BodySegmentPool = {}
BodySegmentPool.__index = BodySegmentPool

local POOL_SIZE = 1000 -- Preallocate for ~20 snakes with 50 segments each
local SEGMENT_SIZE = 4 -- Studs diameter

-- Creates a new BodySegmentPool instance
function BodySegmentPool.new(parent)
	local self = setmetatable({}, BodySegmentPool)
	self._pool = {}
	self._active = {}
	self._parent = parent or workspace:FindFirstChild("Snakes")

	self:_preallocate()

	return self
end

-- Preallocates segments
function BodySegmentPool:_preallocate()
	for i = 1, POOL_SIZE do
		local segment = self:_createSegment()
		segment.Parent = nil -- Store in nil until needed
		table.insert(self._pool, segment)
	end

	print(string.format("[BodySegmentPool] Preallocated %d segments", POOL_SIZE))
end

-- Creates a new segment part
function BodySegmentPool:_createSegment()
	local segment = Instance.new("Part")
	segment.Name = "BodySegment"
	segment.Size = Vector3.new(SEGMENT_SIZE, SEGMENT_SIZE, SEGMENT_SIZE)
	segment.Shape = Enum.PartType.Ball
	segment.Material = Enum.Material.Neon
	segment.CanCollide = false
	segment.Anchored = true
	segment.TopSurface = Enum.SurfaceType.Smooth
	segment.BottomSurface = Enum.SurfaceType.Smooth

	return segment
end

-- Acquires a segment from the pool
function BodySegmentPool:Acquire()
	local segment

	if #self._pool > 0 then
		-- Reuse from pool
		segment = table.remove(self._pool)
	else
		-- Pool exhausted, create new segment
		segment = self:_createSegment()
		warn("[BodySegmentPool] Pool exhausted, creating new segment. Consider increasing POOL_SIZE.")
	end

	segment.Parent = self._parent
	self._active[segment] = true

	return segment
end

-- Releases a segment back to the pool
function BodySegmentPool:Release(segment)
	if not segment or not segment:IsA("BasePart") then
		return
	end

	-- Deactivate
	segment.Parent = nil
	self._active[segment] = nil

	-- Reset properties
	segment.CFrame = CFrame.new(0, -1000, 0) -- Move far away
	segment.BrickColor = BrickColor.new("White")
	segment.Transparency = 0

	-- Return to pool
	table.insert(self._pool, segment)
end

-- Releases multiple segments
function BodySegmentPool:ReleaseMany(segments)
	for _, segment in ipairs(segments) do
		self:Release(segment)
	end
end

-- Gets pool statistics
function BodySegmentPool:GetStats()
	local activeCount = 0
	for _ in pairs(self._active) do
		activeCount = activeCount + 1
	end

	return {
		pooled = #self._pool,
		active = activeCount,
		total = #self._pool + activeCount,
	}
end

-- Cleans up the pool
function BodySegmentPool:Destroy()
	-- Destroy all pooled segments
	for _, segment in ipairs(self._pool) do
		segment:Destroy()
	end

	-- Destroy all active segments
	for segment in pairs(self._active) do
		segment:Destroy()
	end

	self._pool = {}
	self._active = {}
end

return BodySegmentPool
