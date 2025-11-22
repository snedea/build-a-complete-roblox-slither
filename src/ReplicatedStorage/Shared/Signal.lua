-- Signal.lua
-- Event-driven architecture for decoupling systems
-- Lightweight signal implementation for event handling

local Signal = {}
Signal.__index = Signal

-- Creates a new Signal instance
function Signal.new()
	local self = setmetatable({}, Signal)
	self._connections = {}
	return self
end

-- Connects a callback to the signal
-- Returns a connection object with Disconnect method
function Signal:Connect(callback)
	if not callback or type(callback) ~= "function" then
		error("[Signal] Connect requires a function callback", 2)
	end

	local connection = {
		Connected = true,
		_callback = callback,
		_signal = self,
	}

	function connection:Disconnect()
		if not self.Connected then
			return
		end

		self.Connected = false

		for i, conn in ipairs(self._signal._connections) do
			if conn == self then
				table.remove(self._signal._connections, i)
				break
			end
		end
	end

	table.insert(self._connections, connection)

	return connection
end

-- Fires the signal with the given arguments
function Signal:Fire(...)
	for _, connection in ipairs(self._connections) do
		if connection.Connected then
			task.spawn(connection._callback, ...)
		end
	end
end

-- Waits for the signal to fire and returns the arguments
function Signal:Wait()
	local thread = coroutine.running()
	local connection

	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

-- Disconnects all connections and cleans up
function Signal:Destroy()
	for _, connection in ipairs(self._connections) do
		connection.Connected = false
	end
	self._connections = {}
end

return Signal
