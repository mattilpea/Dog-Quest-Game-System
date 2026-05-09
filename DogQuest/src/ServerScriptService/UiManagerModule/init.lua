local player = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainMenuModule = require(script.MainMenuModule)
local SettingsModule = require(script.SettingsModule)
local ShopModule = require(script.ShopModule)
local HUDModule = require(script.HUDModule)
local CodesModule = require(script.CodesModule)
local DailyRewardsModule = require(script.DailyRewardsModule)
local NotificationModule = require(script.HUDModule.NotificationModule)
local InventoryModule = require(script.InventoryModule)
local TodoModule = require(script.TodoModule)

local UiManagerModule = {}
UiManagerModule.Screens = require(script.UiManagerScreens)

-- Example accompanying functions for each screen
local ScreenFunctions = {
	MainMenu = function(isOpen)
		MainMenuModule.AnimateMenu(isOpen)
	end,
	Settings = function(isOpen)
		SettingsModule.AnimateMenu(isOpen)
	end,
	Shop = function(isOpen)
		ShopModule.AnimateMenu(isOpen)
	end,
	HUD = function(isOpen)
		HUDModule.AnimateMenu(isOpen)
	end,
	Codes = function(isOpen)
		CodesModule.AnimateMenu(isOpen)
	end,
	DailyRewards = function(isOpen)
		DailyRewardsModule.AnimateMenu(isOpen)
	end,
	Inventory = function(isOpen)
		InventoryModule.AnimateMenu(isOpen)
	end,
	Todo = function(isOpen)
		TodoModule.AnimateMenu(isOpen)
	end,
}

ReplicatedStorage.RemoteEvents.DailyRewardsEvents.UpdateDailyRewardsData.OnClientEvent:Connect(function(data, showGui)
	if player:GetAttribute("IsInMenu") then
		repeat task.wait() until not player:GetAttribute("IsInMenu")
	end
	
	if showGui then
		if UiManagerModule.Screens.DailyRewards ~= true then
			UiManagerModule.Screens:SetAllScreensFalse()
			
			UiManagerModule.Screens.DailyRewards = true
			UiManagerModule:RunActiveScreens()
		end
	end
	
	DailyRewardsModule.UpdateData(data)
end)

function UiManagerModule:RunActiveScreens()
	for screenName, isOpen in pairs(self.Screens) do
		if ScreenFunctions[screenName] then
			task.spawn(ScreenFunctions[screenName], isOpen)  -- pass the isOpen state
		end
	end
end

UiManagerModule.NotificationModule = NotificationModule
UiManagerModule.InventoryModule = InventoryModule

for _, otherModule in script.Other:GetChildren() do
	task.spawn(function()
		require(otherModule)
	end)
end

return UiManagerModule