-- ActivateBoost.lua
-- RemoteEvent for boost ability activation

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "ActivateBoost"
remoteEvent.Parent = ReplicatedStorage:WaitForChild("RemoteEvents")

return remoteEvent
