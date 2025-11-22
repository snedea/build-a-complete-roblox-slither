-- SnakeRenderer.lua
-- Body segment interpolation for other players' snakes (smooth 60 FPS rendering)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SnakeConfig = require(ReplicatedStorage.Modules.SnakeConfig)
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GameEvent")

local SnakeRenderer = {}
SnakeRenderer.OtherSnakes = {} -- [userId] = {headPart, bodyParts, targetData}
SnakeRenderer._initialized = false
SnakeRenderer._connections = {}

-- Updates snake data from server
function SnakeRenderer:UpdateSnakes(snakeData)
	for userId, data in pairs(snakeData) do
		-- Skip local player (rendered separately)
		if userId ~= player.UserId then
			if not self.OtherSnakes[userId] then
				self:_createSnakeVisuals(userId, data)
			end

			-- Update target data for interpolation
			local snake = self.OtherSnakes[userId]
			if snake then
				snake.targetHeadPos = data.headPos
				snake.targetDirection = data.direction
				snake.targetLength = data.length
				snake.targetColor = data.color
			end
		end
	end

	-- Remove snakes that no longer exist
	for userId, snake in pairs(self.OtherSnakes) do
		if not snakeData[userId] then
			self:_removeSnakeVisuals(userId)
		end
	end
end

-- Creates visual representation for other snake
function SnakeRenderer:_createSnakeVisuals(userId, data)
	local snakesFolder = workspace:FindFirstChild("Snakes")
	if not snakesFolder then
		return
	end

	-- Create head
	local head = Instance.new("Part")
	head.Name = "OtherSnake_" .. userId .. "_Head"
	head.Size = Vector3.new(SnakeConfig.HEAD_SIZE, SnakeConfig.HEAD_SIZE, SnakeConfig.HEAD_SIZE)
	head.Shape = Enum.PartType.Ball
	head.Material = Enum.Material.Neon
	head.Color = data.color
	head.CanCollide = false
	head.Anchored = true
	head.Position = data.headPos
	head.Parent = snakesFolder

	-- Create body segments (client-side only, for smooth rendering)
	local bodyParts = {}
	for i = 1, data.length do
		local segment = Instance.new("Part")
		segment.Name = "OtherSnake_" .. userId .. "_Body_" .. i
		segment.Size = Vector3.new(SnakeConfig.SEGMENT_SIZE, SnakeConfig.SEGMENT_SIZE, SnakeConfig.SEGMENT_SIZE)
		segment.Shape = Enum.PartType.Ball
		segment.Material = Enum.Material.Neon
		segment.Color = data.color
		segment.CanCollide = false
		segment.Anchored = true
		segment.Position = data.headPos - Vector3.new(i * SnakeConfig.SEGMENT_SPACING, 0, 0)
		segment.Parent = snakesFolder

		table.insert(bodyParts, segment)
	end

	self.OtherSnakes[userId] = {
		headPart = head,
		bodyParts = bodyParts,
		targetHeadPos = data.headPos,
		currentHeadPos = data.headPos,
		targetDirection = data.direction,
		targetLength = data.length,
		targetColor = data.color,
	}
end

-- Removes visual representation
function SnakeRenderer:_removeSnakeVisuals(userId)
	local snake = self.OtherSnakes[userId]
	if snake then
		snake.headPart:Destroy()
		for _, part in ipairs(snake.bodyParts) do
			part:Destroy()
		end
		self.OtherSnakes[userId] = nil
	end
end

-- Interpolates snake positions (60 FPS smooth)
function SnakeRenderer:_interpolateSnakes(dt)
	for userId, snake in pairs(self.OtherSnakes) do
		-- Interpolate head position
		local alpha = SnakeConfig.CLIENT_INTERPOLATION_ALPHA
		snake.currentHeadPos = snake.currentHeadPos:Lerp(snake.targetHeadPos, alpha)
		snake.headPart.Position = snake.currentHeadPos

		-- Update color if changed
		if snake.headPart.Color ~= snake.targetColor then
			snake.headPart.Color = snake.targetColor
			for _, part in ipairs(snake.bodyParts) do
				part.Color = snake.targetColor
			end
		end

		-- Adjust body segment count if length changed
		while #snake.bodyParts < snake.targetLength do
			local segment = Instance.new("Part")
			segment.Name = "OtherSnake_" .. userId .. "_Body_" .. #snake.bodyParts + 1
			segment.Size = Vector3.new(SnakeConfig.SEGMENT_SIZE, SnakeConfig.SEGMENT_SIZE, SnakeConfig.SEGMENT_SIZE)
			segment.Shape = Enum.PartType.Ball
			segment.Material = Enum.Material.Neon
			segment.Color = snake.targetColor
			segment.CanCollide = false
			segment.Anchored = true
			segment.Position = snake.currentHeadPos
			segment.Parent = workspace:FindFirstChild("Snakes")
			table.insert(snake.bodyParts, segment)
		end

		while #snake.bodyParts > snake.targetLength do
			local segment = table.remove(snake.bodyParts)
			segment:Destroy()
		end

		-- Interpolate body segments (follow head)
		local positions = {snake.currentHeadPos}
		for i, segment in ipairs(snake.bodyParts) do
			local targetPos = positions[i]
			local currentPos = segment.Position

			-- Smooth follow
			local newPos = currentPos:Lerp(targetPos - snake.targetDirection * i * SnakeConfig.SEGMENT_SPACING, alpha)
			segment.Position = newPos

			table.insert(positions, newPos)
		end
	end
end

-- Initialize
function SnakeRenderer:Initialize()
	if self._initialized then
		return
	end
	self._initialized = true

	table.insert(self._connections, remoteEvent.OnClientEvent:Connect(function(eventType, data)
		if eventType == "UpdateSnakes" then
			self:UpdateSnakes(data)
		end
	end))

	table.insert(self._connections, RunService.RenderStepped:Connect(function(dt)
		self:_interpolateSnakes(dt)
	end))

	print("[SnakeRenderer] Initialized")
end

return SnakeRenderer
