-- ObjectPool.lua
-- Body segment pooling to prevent GC spikes from 1000+ dynamic parts
-- Preallocates objects and reuses them instead of creating/destroying

local ObjectPool = {}
ObjectPool.__index = ObjectPool

function ObjectPool.new(template: Instance, initialSize: number)
	local self = setmetatable({}, ObjectPool)
	self.template = template
	self.available = {}
	self.inUse = {}
	
	-- Prewarm the pool
	if initialSize then
		self:Prewarm(initialSize)
	end
	
	return self
end

-- Preallocate objects
function ObjectPool:Prewarm(count: number)
	for i = 1, count do
		local object = self.template:Clone()
		object.Parent = nil
		table.insert(self.available, object)
	end
end

-- Get an object from the pool
function ObjectPool:Get(): Instance
	local object = table.remove(self.available)
	
	if not object then
		-- Pool exhausted, create new object
		object = self.template:Clone()
	end
	
	self.inUse[object] = true
	return object
end

-- Return an object to the pool
function ObjectPool:Return(object: Instance)
	if self.inUse[object] then
		object.Parent = nil
		self.inUse[object] = nil
		table.insert(self.available, object)
	end
end

-- Return multiple objects at once
function ObjectPool:ReturnAll(objects: {Instance})
	for _, object in ipairs(objects) do
		self:Return(object)
	end
end

-- Get pool statistics
function ObjectPool:GetStats(): {available: number, inUse: number}
	local inUseCount = 0
	for _ in pairs(self.inUse) do
		inUseCount += 1
	end
	
	return {
		available = #self.available,
		inUse = inUseCount
	}
end

return ObjectPool
