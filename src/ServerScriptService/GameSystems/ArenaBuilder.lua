-- ArenaBuilder.lua
-- Procedurally generates the arena floor and boundaries

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SnakeConfig = require(ReplicatedStorage.Modules.SnakeConfig)

local ArenaBuilder = {}

function ArenaBuilder:Initialize()
	local arenaFolder = workspace:FindFirstChild("Arena")
	if not arenaFolder then
		arenaFolder = Instance.new("Folder")
		arenaFolder.Name = "Arena"
		arenaFolder.Parent = workspace
	end

	-- Create floor
	self:CreateFloor(arenaFolder)

	-- Create boundary walls
	self:CreateBoundaries(arenaFolder)

	-- Add lighting
	self:SetupLighting()

	print("[ArenaBuilder] Arena created successfully")
end

function ArenaBuilder:CreateFloor(parent)
	local arenaMin = SnakeConfig.ARENA_MIN
	local arenaMax = SnakeConfig.ARENA_MAX

	local sizeX = arenaMax.X - arenaMin.X
	local sizeZ = arenaMax.Z - arenaMin.Z
	local centerX = (arenaMax.X + arenaMin.X) / 2
	local centerZ = (arenaMax.Z + arenaMin.Z) / 2

	-- Main floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(sizeX, 1, sizeZ)
	floor.Position = Vector3.new(centerX, -0.5, centerZ)
	floor.Anchored = true
	floor.Material = Enum.Material.Slate
	floor.Color = Color3.fromRGB(30, 30, 40)
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.Parent = parent

	-- Grid lines for visual reference
	local gridSpacing = 100
	for x = arenaMin.X, arenaMax.X, gridSpacing do
		local line = Instance.new("Part")
		line.Name = "GridLine"
		line.Size = Vector3.new(2, 0.1, sizeZ)
		line.Position = Vector3.new(x, 0.1, centerZ)
		line.Anchored = true
		line.Material = Enum.Material.Neon
		line.Color = Color3.fromRGB(50, 50, 70)
		line.CanCollide = false
		line.Transparency = 0.7
		line.Parent = parent
	end

	for z = arenaMin.Z, arenaMax.Z, gridSpacing do
		local line = Instance.new("Part")
		line.Name = "GridLine"
		line.Size = Vector3.new(sizeX, 0.1, 2)
		line.Position = Vector3.new(centerX, 0.1, z)
		line.Anchored = true
		line.Material = Enum.Material.Neon
		line.Color = Color3.fromRGB(50, 50, 70)
		line.CanCollide = false
		line.Transparency = 0.7
		line.Parent = parent
	end

	print("[ArenaBuilder] Floor created")
end

function ArenaBuilder:CreateBoundaries(parent)
	local arenaMin = SnakeConfig.ARENA_MIN
	local arenaMax = SnakeConfig.ARENA_MAX

	local wallHeight = 20
	local wallThickness = 2

	local sizeX = arenaMax.X - arenaMin.X
	local sizeZ = arenaMax.Z - arenaMin.Z
	local centerX = (arenaMax.X + arenaMin.X) / 2
	local centerZ = (arenaMax.Z + arenaMin.Z) / 2

	-- North wall
	local northWall = Instance.new("Part")
	northWall.Name = "NorthWall"
	northWall.Size = Vector3.new(sizeX + wallThickness * 2, wallHeight, wallThickness)
	northWall.Position = Vector3.new(centerX, wallHeight / 2, arenaMax.Z + wallThickness / 2)
	northWall.Anchored = true
	northWall.Material = Enum.Material.ForceField
	northWall.Color = Color3.fromRGB(100, 100, 255)
	northWall.Transparency = 0.3
	northWall.CanCollide = true
	northWall.Parent = parent

	-- South wall
	local southWall = Instance.new("Part")
	southWall.Name = "SouthWall"
	southWall.Size = Vector3.new(sizeX + wallThickness * 2, wallHeight, wallThickness)
	southWall.Position = Vector3.new(centerX, wallHeight / 2, arenaMin.Z - wallThickness / 2)
	southWall.Anchored = true
	southWall.Material = Enum.Material.ForceField
	southWall.Color = Color3.fromRGB(100, 100, 255)
	southWall.Transparency = 0.3
	southWall.CanCollide = true
	southWall.Parent = parent

	-- East wall
	local eastWall = Instance.new("Part")
	eastWall.Name = "EastWall"
	eastWall.Size = Vector3.new(wallThickness, wallHeight, sizeZ)
	eastWall.Position = Vector3.new(arenaMax.X + wallThickness / 2, wallHeight / 2, centerZ)
	eastWall.Anchored = true
	eastWall.Material = Enum.Material.ForceField
	eastWall.Color = Color3.fromRGB(100, 100, 255)
	eastWall.Transparency = 0.3
	eastWall.CanCollide = true
	eastWall.Parent = parent

	-- West wall
	local westWall = Instance.new("Part")
	westWall.Name = "WestWall"
	westWall.Size = Vector3.new(wallThickness, wallHeight, sizeZ)
	westWall.Position = Vector3.new(arenaMin.X - wallThickness / 2, wallHeight / 2, centerZ)
	westWall.Anchored = true
	westWall.Material = Enum.Material.ForceField
	westWall.Color = Color3.fromRGB(100, 100, 255)
	westWall.Transparency = 0.3
	westWall.CanCollide = true
	westWall.Parent = parent

	print("[ArenaBuilder] Boundary walls created")
end

function ArenaBuilder:SetupLighting()
	-- Set ambient lighting for better visibility
	local lighting = game:GetService("Lighting")

	local ok, err = pcall(function()
		lighting.Ambient = Color3.fromRGB(100, 100, 120)
		lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 120)
		lighting.Brightness = 2
		lighting.GlobalShadows = false

		-- Add a skybox for depth
		local sky = Instance.new("Sky")
		sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.jpg"
		sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.jpg"
		sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.jpg"
		sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.jpg"
		sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.jpg"
		sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.jpg"
		sky.Parent = lighting
	end)

	if not ok then
		warn("[ArenaBuilder] Lighting configuration skipped:", err)
	end

	print("[ArenaBuilder] Lighting configured")
end

return ArenaBuilder
