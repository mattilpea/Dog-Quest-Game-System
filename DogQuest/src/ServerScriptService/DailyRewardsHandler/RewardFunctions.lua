local ss = game:GetService("ServerStorage")
local sss = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")

local LevelingService = require(rs.Services.LevelingService)
local NotificationHandler = require(sss.Libraries.NotificationHandler)

local RewardFunctions = {}

RewardFunctions[1] = function(plr: Player)
	local leaderstats = plr:WaitForChild("leaderstats")
	local Coins: IntValue = leaderstats:WaitForChild("Coins")
	
	local coinsReward = 30
	
	Coins.Value = Coins.Value + coinsReward
	
	NotificationHandler:SendNotification(plr, "Daily Reward: Received "..tostring(coinsReward).." Coins", false, 5, "rbxassetid://98641615872629", "NOTIFICATION_DAILYREWARDSCOINS", {coinsReward})
end

RewardFunctions[2] = function(plr: Player)
	local leaderstats = plr:WaitForChild("leaderstats")
	local Coins: IntValue = leaderstats:WaitForChild("Coins")

	local coinsReward = 60
	local expReward = 150

	Coins.Value = Coins.Value + coinsReward
	
	NotificationHandler:SendNotification(plr, "Daily Reward: Received "..tostring(coinsReward).." Coins", false, 5, "rbxassetid://98641615872629", "NOTIFICATION_DAILYREWARDSCOINS", {coinsReward})

	LevelingService:GiveXP(plr, expReward, true)
end

RewardFunctions[3] = function(plr: Player)
	local leaderstats = plr:WaitForChild("leaderstats")
	local Coins: IntValue = leaderstats:WaitForChild("Coins")

	local coinsReward = 120

	Coins.Value = Coins.Value + coinsReward

	NotificationHandler:SendNotification(plr, "Daily Reward: Received "..tostring(coinsReward).." Coins", false, 5, "rbxassetid://98641615872629", "NOTIFICATION_DAILYREWARDSCOINS", {coinsReward})
end

RewardFunctions[4] = function(plr: Player)
	local leaderstats = plr:WaitForChild("leaderstats")
	local Coins: IntValue = leaderstats:WaitForChild("Coins")

	local coinsReward = 240

	Coins.Value = Coins.Value + coinsReward

	NotificationHandler:SendNotification(plr, "Daily Reward: Received "..tostring(coinsReward).." Coins", false, 5, "rbxassetid://98641615872629", "NOTIFICATION_DAILYREWARDSCOINS", {coinsReward})
end

RewardFunctions[5] = function(plr: Player)
	local leaderstats = plr:WaitForChild("leaderstats")
	local Coins: IntValue = leaderstats:WaitForChild("Coins")

	local coinsReward = 300
	local expReward = 400

	Coins.Value = Coins.Value + coinsReward

	NotificationHandler:SendNotification(plr, "Daily Reward: Received "..tostring(coinsReward).." Coins", false, 5, "rbxassetid://98641615872629", "NOTIFICATION_DAILYREWARDSCOINS", {coinsReward})

	LevelingService:GiveXP(plr, expReward, true)
end

RewardFunctions[6] = function(plr: Player)
	local leaderstats = plr:WaitForChild("leaderstats")
	local Coins: IntValue = leaderstats:WaitForChild("Coins")

	local coinsReward = 400

	Coins.Value = Coins.Value + coinsReward

	NotificationHandler:SendNotification(plr, "Daily Reward: Received "..tostring(coinsReward).." Coins", false, 5, "rbxassetid://98641615872629", "NOTIFICATION_DAILYREWARDSCOINS", {coinsReward})
end

return RewardFunctions