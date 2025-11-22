-- RequestRevive.lua
-- RemoteEvent for revive with donut consumption

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "RequestRevive"
remoteEvent.Parent = ReplicatedStorage:WaitForChild("RemoteEvents")

return remoteEvent
