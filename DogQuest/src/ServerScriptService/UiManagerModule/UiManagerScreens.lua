local player = game.Players.LocalPlayer
local playerGui: PlayerGui = player:WaitForChild("PlayerGui")
local MainMenu = playerGui:WaitForChild("MainMenu")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
--true means its being shown, false means it will play the closing animation and dissapear, nil means its completely hidden

local UiManagerScreens = {
	MainMenu = true, 
	Settings = nil,
	Shop = nil,
	HUD = nil,
	Codes = nil,
	DailyRewards = nil,
	Inventory = nil,
	Todo = nil
	
	-- add more screens here
}

local RunActiveScreensEvent = script.Parent.Parent.RunActiveScreens
local UiAnimationsModule = require(ReplicatedStorage.ModuleScripts.UiAnimations)
local Debugger = require(ReplicatedStorage.ModuleScripts.Debugger)

function UiManagerScreens:SetAllScreensFalse()
	MainMenu.BuildingsUI.Visible = false
	MainMenu.CraftingUI.Visible = false
	
	for screenName, value in pairs(self) do
		if type(value) == "boolean" then
			self[screenName] = false
		end
	end
end

function UiManagerScreens:RunActiveScreens()
	RunActiveScreensEvent:Fire()
end
UiManagerScreens.UiAnimationsModule = UiAnimationsModule
UiManagerScreens.Debugger = Debugger

local MainGUI = script.Parent.Parent.Parent.Parent:WaitForChild('MainMenu')
UiManagerScreens.FrameMainMenu = MainGUI.MainMenuFrame
UiManagerScreens.FrameSettings = MainGUI.SettingsFrame
UiManagerScreens.FrameSettingsShowMenu = MainGUI.SettingsFrame.ShowMenu
UiManagerScreens.FrameShop = MainGUI.ShopFrame
UiManagerScreens.FrameShopShowMenu = MainGUI.ShopFrame.ShowMenu
UiManagerScreens.FrameHUD = MainGUI.HUD
UiManagerScreens.FrameToolbar = MainGUI.HUD.Toolbar
UiManagerScreens.FrameCodes = MainGUI.CodesFrame
UiManagerScreens.FrameDailyRewards = MainGUI.DailyRewardsFrame
UiManagerScreens.FrameInventory = MainGUI.InventoryFrame
UiManagerScreens.FrameTodo = MainGUI.TodoUI
UiManagerScreens.FrameNotification = MainGUI.Notification
UiManagerScreens.OrganizedList = {}

return UiManagerScreens
