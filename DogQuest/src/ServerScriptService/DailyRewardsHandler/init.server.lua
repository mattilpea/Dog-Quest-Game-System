local rs = game:GetService("ReplicatedStorage")
local sss = game:GetService("ServerScriptService")

local DataManager = require(sss.Data.DataManager)
local RewardFunctions = require(script.RewardFunctions)

local hours_24 = 60 * 60 * 24
local hours_48 = hours_24 * 2
local lastDay = 6

local function checkDailyRewards(player: Player)
	local playerData = DataManager.GetPlayerData(player)
	local dailyRewardsData = playerData.DailyReward
	
	local now = workspace:GetServerTimeNow()
	local lastClaim = dailyRewardsData.LastClaimTime
	
	if now - lastClaim > hours_48 then
		dailyRewardsData.CurrentDay = 1
		
		if not player:GetAttribute("DailyRewardRemoteDebounce") then
			player:SetAttribute("DailyRewardRemoteDebounce", true)
			rs.RemoteEvents.DailyRewardsEvents.UpdateDailyRewardsData:FireClient(player, dailyRewardsData, true)
			
			task.delay(10, function()
				player:SetAttribute("DailyRewardRemoteDebounce", nil)
			end)
		end
		
		return
	end
	
	if now - lastClaim >= hours_24 then
		if dailyRewardsData.CurrentDay > lastDay then
			dailyRewardsData.CurrentDay = 1
		end
		
		if not player:GetAttribute("DailyRewardRemoteDebounce") then
			player:SetAttribute("DailyRewardRemoteDebounce", true)
			rs.RemoteEvents.DailyRewardsEvents.UpdateDailyRewardsData:FireClient(player, dailyRewardsData, true)

			task.delay(10, function()
				player:SetAttribute("DailyRewardRemoteDebounce", nil)
			end)
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	repeat task.wait() until player:GetAttribute("DataLoaded") == true
	
	checkDailyRewards(player)
end)

-- periodic check for daily rewards
task.spawn(function()
	local checkEvery = 1
	
	while task.wait(checkEvery) do
		for _, player in game.Players:GetPlayers() do
			if not player:GetAttribute("DataLoaded") then continue end
			
			task.spawn(checkDailyRewards, player)
		end
	end
end)

local db1 = {}

rs.RemoteEvents.DailyRewardsEvents.ClaimReward.OnServerEvent:Connect(function(player: Player)
	if db1[player] then return end
	db1[player] = true
	task.delay(0.1, function()
		db1[player] = nil
	end)
	
	local playerData = DataManager.GetPlayerData(player)
	local dailyRewardsData = playerData.DailyReward
	
	local now = workspace:GetServerTimeNow()
	local lastClaim = dailyRewardsData.LastClaimTime
	
	if now - lastClaim >= hours_24 then
		if dailyRewardsData.CurrentDay > lastDay then
			dailyRewardsData.CurrentDay = 1
		end
		
		local rewardFunction = RewardFunctions[dailyRewardsData.CurrentDay]
		
		task.spawn(rewardFunction, player)
		
		dailyRewardsData.CurrentDay = dailyRewardsData.CurrentDay + 1
		dailyRewardsData.LastClaimTime = now
		
		rs.RemoteEvents.DailyRewardsEvents.UpdateDailyRewardsData:FireClient(player, dailyRewardsData)
	end
end)

local db2 = {}

rs.RemoteFunctions.GetDailyRewardsData.OnServerInvoke = function(player: Player)
	if db2[player] then return end
	db2[player] = true
	task.delay(0.1, function()
		db2[player] = nil
	end)
	
	local playerData = DataManager.GetPlayerData(player)
	
	return playerData.DailyReward
end