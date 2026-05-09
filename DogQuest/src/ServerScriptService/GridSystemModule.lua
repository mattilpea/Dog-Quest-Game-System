--// GridSystemModule.lua
local GridSystemModule = {}

-- Services (kept inside module in case standalone use is needed)
local ServerStorage = game:GetService("ServerStorage")
local sss = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")

local DataManager = require(sss.Data.DataManager)
local BlinkBillboardGui = require(rs.Services.BlinkBillboardGui)

-- Default settings
GridSystemModule.Settings = {
	ChunkArea = 50,
	Up = 8,      -- +X
	Down = 5,    -- -X
	Right = 6,   -- +Z
	Left = 7,    -- -Z
	OriginPosition = Vector3.new(27.027, 62.597, -89.693),
	ChunkTemplate = ServerStorage:WaitForChild("Objects"):WaitForChild("Chunk"),
	ChunkParent = workspace:WaitForChild("Chunks"),
	MaxChunks = 195
}

-- Internal state
local grid = {}
local spiralPoints = {}
local visited = {}
local width, height, xOffset, zOffset

-- Utility
local function isValid(x, z)
	return x >= 1 and x <= width and z >= 1 and z <= height
end

local function firstMissingNumber(tbl)
	local set = {}
	local max = 0

	-- Put all numbers into a set for O(1) lookup and find max
	for _, num in ipairs(tbl) do
		set[num] = true
		if num > max then
			max = num
		end
	end

	-- Check from 1 to max for the first missing number
	for i = 1, max do
		if not set[i] then
			return i
		end
	end

	-- If nothing is missing, return the next number
	return max + 1
end

local directions = {
	{1, 0},   -- Right (+X)
	{0, 1},   -- Down (+Z)
	{-1, 0},  -- Left (-X)
	{0, -1},  -- Up (-Z)
}

-- Build grid and generate spiral indexing
function GridSystemModule:GenerateGrid()
	local settings = self.Settings

	-- Calculate grid dimensions
	width = settings.Down + settings.Up + 1
	height = settings.Left + settings.Right + 1

	xOffset = settings.Down + 1
	zOffset = settings.Left + 1

	-- Initialize tables
	grid = {}
	spiralPoints = {}
	visited = {}

	for x = 1, width do
		grid[x] = {}
		visited[x] = {}
	end

	-- Fill grid with parts
	for dx = -settings.Down, settings.Up do
		for dz = -settings.Left, settings.Right do
			local newPart = settings.ChunkTemplate:Clone()
			newPart.Anchored = true
			newPart.Position = settings.OriginPosition + Vector3.new(dx * settings.ChunkArea, 0, dz * settings.ChunkArea)
			newPart.Parent = settings.ChunkParent
			grid[dx + xOffset][dz + zOffset] = newPart
		end
	end

	-- Generate spiral order
	local function spiralFromCenter(cx, cz)
		local x, z = cx, cz
		local step = 1
		local dir = 1

		visited[x][z] = true

		while #spiralPoints < width * height - 1 do
			for _ = 1, 2 do
				local dx, dz = directions[dir][1], directions[dir][2]
				for _ = 1, step do
					x += dx
					z += dz
					if isValid(x, z) and not visited[x][z] and grid[x][z] then
						table.insert(spiralPoints, grid[x][z])
						visited[x][z] = true
					end
				end
				dir = dir % 4 + 1
			end
			step += 1
		end
	end

	spiralFromCenter(xOffset, zOffset)

	-- Rename chunks based on spiral index
	grid[xOffset][zOffset].Name = "0" -- center
	grid[xOffset][zOffset].CanCollide = false
	
	for i, part in ipairs(spiralPoints) do
		part.Name = tostring(i)
	end
end

-- Get chunk part by spiral index
function GridSystemModule:ReferenceToPoint(n)
	if n == 0 then
		return grid[xOffset][zOffset]
	end
	return spiralPoints[n]
end

-- Destroy chunks in a given list of spiral indexes
function GridSystemModule:ClearChunks(unlocked_chunks)
	for _, pointIndex in ipairs(unlocked_chunks) do
		local chunkBlock = self:ReferenceToPoint(pointIndex)
		if chunkBlock then
			chunkBlock:Destroy()
		end
		
		if pointIndex == 34 then
			workspace.Zones.TownZone.Blacksmith.BillboardGui.Enabled = true
		end
	end
	
	workspace.Chunks:SetAttribute("ChunksLoaded", true)
end

function GridSystemModule:UnlockNextChunk(player: Player)
	local unlocked_table = DataManager.GetUnlockedTable(player)
	
	for chunkNumber = 1, GridSystemModule.Settings.MaxChunks do
		if not table.find(unlocked_table, chunkNumber) then
			GridSystemModule:UnlockChunk(player, chunkNumber)
			
			break
		end
	end
end

function GridSystemModule:UnlockChunk(player: Player, chunkNumber: number)
	local unlocked_table = DataManager.GetUnlockedTable(player)
	
	local chunkPosition: Vector3 = DataManager.AppendToUnlockedTable(player, chunkNumber)
	
	if type(chunkPosition) == "vector" then
		local character = player.Character or player.CharacterAdded:Wait()
		
		chunkPosition = Vector3.new(chunkPosition.X, character.HumanoidRootPart.Position.Y, chunkPosition.Z)
		BlinkBillboardGui.RemoveBillboard("CHUNK_UNLOCK")
		BlinkBillboardGui.AddBillboard("CHUNK_UNLOCK", 6, rs.Models.ChunkUnlockBillboard, chunkPosition)
	end
	
	if chunkNumber == 34 then
		workspace.Zones.TownZone.Blacksmith.BillboardGui.Enabled = true
	end
end

return GridSystemModule
