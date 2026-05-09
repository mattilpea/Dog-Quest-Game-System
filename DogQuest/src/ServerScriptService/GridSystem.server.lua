local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// ModuleScripts
local GridSystemModule = require(ServerScriptService.Libraries.GridSystemModule)
local DataManagerModule = require(ServerScriptService.Data.DataManager)

-- Initialize grid
GridSystemModule:GenerateGrid()

-- When player joins
Players.PlayerAdded:Connect(function(plr)
	repeat task.wait() until plr:GetAttribute('DataLoaded') == true
	
	local unlocked_table = DataManagerModule.GetUnlockedTable(plr)
	if unlocked_table then
		GridSystemModule:ClearChunks(unlocked_table)
	else
		warn("unlocked table not found")
	end
	
	local unlockedExternalZoneChunks = DataManagerModule.GetUnlockedExternalZoneChunks(plr)
	
	-- delete all unlocked chunks from all zones
	for zoneName, unlockedChunksTable in unlockedExternalZoneChunks do
		local zoneFolder = workspace.Zones.ExternalZones[zoneName]
		
		for _, chunkData in unlockedChunksTable do
			local chunkNumber = chunkData.ChunkNumber
			local chunkOrder = chunkData.ChunkOrder
			
			for _, chunkPart in zoneFolder.Chunks:GetChildren() do
				local chunkPartNumber = tonumber(chunkPart.Name)
				local chunkPartOrder = chunkPart:GetAttribute("Order")
				
				if chunkPartNumber == chunkNumber and chunkPartOrder == chunkOrder then
					chunkPart:Destroy()
					
					break
				end
			end
		end
	end
end)