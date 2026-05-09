local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer

plr:SetAttribute("IsInMenu", true)

local UiManagerScreens = require(script.Parent.UiManagerScreens)
local UiAnimationsModule = UiManagerScreens.UiAnimationsModule

local MainMenuFrame = UiManagerScreens.FrameMainMenu

local MainMenuModule = {}

-- Positions
local OpenLogoPos = UDim2.new(0.5, 0, 0.401, 0)
local CloseStartLogoPos = UDim2.new(0.5, 0, 0.5, 0)
local CloseLogoPos = UDim2.new(0.5, 0, -0.5, 0)

local OpenSettingsPos = UDim2.new(0.418, 0, 0.945, 0)
local CloseStartSettingsPos = UDim2.new(0.418, 0, 0.93, 0)
local CloseSettingsPos = UDim2.new(0.418, 0, 1.245, 0) -- 0.945 + 0.3

local OpenShopPos = UDim2.new(0.581, 0, 0.945, 0)
local CloseStartShopPos = UDim2.new(0.581, 0, 0.93, 0)
local CloseShopPos = UDim2.new(0.581, 0, 1.245, 0) -- 0.945 + 0.3

local OpenPlayPos = UDim2.new(0.5, 0, 0.834, 0)
local CloseStartPlayPos = UDim2.new(0.5, 0, 0.819, 0)
local ClosePlayPos = UDim2.new(0.5, 0, 1.134, 0) -- 0.834 + 0.3

local BtnPlay = MainMenuFrame.Play
local BtnSettings = MainMenuFrame.Settings
local BtnShop = MainMenuFrame.Shop

-- Main animation function with PlayButton delay
function MainMenuModule.AnimateMenu(state : boolean)
	if state then
		workspace:WaitForChild("SpawnLocation")
		
		MainMenuFrame.Visible = true
		-- Open animation: Logo, Settings, Shop first
		task.spawn(function()
			UiAnimationsModule.TweenPosition(MainMenuFrame.Logo, CloseStartLogoPos, OpenLogoPos, 0.1, 0.15)
		end)
		task.spawn(function()
			UiAnimationsModule.TweenPosition(BtnSettings, CloseStartSettingsPos, OpenSettingsPos, 0.1, 0.15)
		end)
		task.spawn(function()
			UiAnimationsModule.TweenPosition(BtnShop, CloseStartShopPos, OpenShopPos, 0.1, 0.15)
		end)

		-- Delay then Play button animation
		task.delay(0.1, function()
			UiAnimationsModule.TweenPosition(BtnPlay, CloseStartPlayPos, OpenPlayPos, 0.1, 0.15)
		end)
	elseif state == false then
		-- Close animation: Logo, Settings, Shop first
		task.spawn(function()
			UiAnimationsModule.TweenPosition(MainMenuFrame.Logo, CloseStartLogoPos, CloseLogoPos, 0.1, 0.15)
		end)
		task.spawn(function()
			UiAnimationsModule.TweenPosition(BtnSettings, CloseStartSettingsPos, CloseSettingsPos, 0.1, 0.15)
		end)
		task.spawn(function()
			UiAnimationsModule.TweenPosition(BtnShop, CloseStartShopPos, CloseShopPos, 0.1, 0.15)
		end)

		-- Delay then Play button animation
		task.delay(0.1, function()
			UiAnimationsModule.TweenPosition(BtnPlay, CloseStartPlayPos, ClosePlayPos, 0.1, 0.15)
		end)
		UiManagerScreens.MainMenu = nil
	else
		MainMenuFrame.Visible = false
	end
end

BtnPlay.Activated:Connect(function()
	workspace:WaitForChild("SpawnLocation")
	
	ReplicatedStorage.Bindables.ScreenFade:Fire()
	task.wait(0.2)
	
	UiManagerScreens:SetAllScreensFalse()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	UiManagerScreens.HUD = true
	UiManagerScreens:RunActiveScreens()
	
	plr:SetAttribute("IsInMenu", false)
end)

BtnSettings.Activated:Connect(function()
	UiManagerScreens:SetAllScreensFalse()
	UiManagerScreens.Settings = true
	UiManagerScreens.FrameSettingsShowMenu.Value = true
	UiManagerScreens:RunActiveScreens()
end)

BtnShop.Activated:Connect(function()
	UiManagerScreens:SetAllScreensFalse()
	UiManagerScreens.Shop = true
	UiManagerScreens.FrameShopShowMenu.Value = true
	UiManagerScreens:RunActiveScreens()
end)

local previousWalkSpeed = 0
local previousJumpHeight = 0

local function handleMenu(isInMenu: boolean)
	local character = plr.Character or plr.CharacterAdded:Wait()
	
	if isInMenu then
		character:PivotTo(CFrame.new(144.75, -319.396667, -288.75, 1, 0, 0, 0, 1, 0, 0, 0, 1))
		
		previousWalkSpeed = character.Humanoid.WalkSpeed > 0 and character.Humanoid.WalkSpeed
		previousJumpHeight = character.Humanoid.JumpHeight > 0 and character.Humanoid.JumpHeight
		
		character.Humanoid.WalkSpeed = 0
		character.Humanoid.JumpHeight = 0
	else
		character.Humanoid.WalkSpeed = previousWalkSpeed
		character.Humanoid.JumpHeight = previousJumpHeight
		
		character:PivotTo(workspace:WaitForChild("SpawnLocation").CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(0, math.rad(-90), 0))
	end
	
	for _, chunk in workspace.Chunks:GetChildren() do
		if chunk:IsA("BasePart") then
			chunk.Transparency = isInMenu and 1 or 0.55
		end
	end
	
	for _, zoneFolder in workspace.Zones.ExternalZones:GetChildren() do
		for _, chunk in zoneFolder.Chunks:GetChildren() do
			if chunk:IsA("BasePart") then
				chunk.Transparency = isInMenu and 1 or 0.55
			end
		end
	end
end

plr:GetAttributeChangedSignal("IsInMenu"):Connect(function()
	local isInMenu = plr:GetAttribute("IsInMenu")
	
	handleMenu(isInMenu)
end)

task.spawn(handleMenu, plr:GetAttribute("IsInMenu"))

return MainMenuModule
