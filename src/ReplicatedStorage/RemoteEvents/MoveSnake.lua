-- MoveSnake.lua
-- RemoteEvent for client -> server movement requests

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "MoveSnake"
remoteEvent.Parent = ReplicatedStorage:WaitForChild("RemoteEvents")

return remoteEvent
