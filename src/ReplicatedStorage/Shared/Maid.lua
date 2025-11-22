-- Maid.lua
-- Memory leak prevention via cleanup pattern
-- Based on Nevermore Engine Maid pattern

local Maid = {}
Maid.__index = Maid

-- Creates a new Maid instance
function Maid.new()
	local self = setmetatable({}, Maid)
	self._tasks = {}
	return self
end

-- Adds a task to be cleaned up
-- Task can be: Instance, RBXScriptConnection, function, or another Maid
function Maid:GiveTask(task)
	if not task then
		error("[Maid] Cannot GiveTask a nil value", 2)
	end

	local taskId = #self._tasks + 1
	self._tasks[taskId] = task

	return taskId
end

-- Removes and cleans up a specific task
function Maid:RemoveTask(taskId)
	local task = self._tasks[taskId]
	if task then
		self._tasks[taskId] = nil
		self:_cleanupTask(task)
	end
end

-- Internal cleanup logic for different task types
function Maid:_cleanupTask(task)
	local taskType = typeof(task)

	if taskType == "Instance" then
		task:Destroy()
	elseif taskType == "RBXScriptConnection" then
		task:Disconnect()
	elseif taskType == "function" then
		task()
	elseif taskType == "table" and task.Destroy then
		task:Destroy()
	elseif taskType == "table" and task.DoCleaning then
		task:DoCleaning()
	end
end

-- Cleans up all tasks
function Maid:DoCleaning()
	for _, task in pairs(self._tasks) do
		self:_cleanupTask(task)
	end
	self._tasks = {}
end

-- Alias for DoCleaning
function Maid:Destroy()
	self:DoCleaning()
end

return Maid
