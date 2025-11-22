-- ActivateBrake.lua
-- RemoteEvent for brake ability activation

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "ActivateBrake"
remoteEvent.Parent = ReplicatedStorage:WaitForChild("RemoteEvents")

return remoteEvent
