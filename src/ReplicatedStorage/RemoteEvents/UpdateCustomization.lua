-- UpdateCustomization.lua
-- RemoteEvent for changing snake appearance

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "UpdateCustomization"
remoteEvent.Parent = ReplicatedStorage:WaitForChild("RemoteEvents")

return remoteEvent
