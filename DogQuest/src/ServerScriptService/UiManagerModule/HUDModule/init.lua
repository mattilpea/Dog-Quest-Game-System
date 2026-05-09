local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TweenService = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")

local UiManagerScreens = require(script.Parent.UiManagerScreens)
local UiAnimationsModule = UiManagerScreens.UiAnimationsModule

--local ToolbarModule = require(script.ToolbarModule)
--ToolbarModule.Init()

local HUDModule = {}

local OpenLeftPos = UDim2.new(0.069,0,0.5,0)
local OpenToolbarPos = UDim2.new(0.5,0,0.944,0)

local CloseStartLeftPos = UDim2.new(0.075,0,0.5,0)
local CloseStartToolbarPos = UDim2.new(0.5,0,0.9,0)

local CloseLeftPos = UDim2.new(-0.3, 0, 0.5,0)
local CloseToolbarPos = UDim2.new(0.5,0,1.2,0)

local screenFadeTime = 0.2

local FrameHUD = UiManagerScreens.FrameHUD
local MainMenu = playerGui:WaitForChild("MainMenu")
local screenFadeFrame: Frame = MainMenu:WaitForChild("ScreenFadeFrame")

function HUDModule.AnimateMenu(state : boolean)
	if state then
		FrameHUD.Visible = true

		task.spawn(function()
			-- Tween HUD elements from close start to open positions
			UiAnimationsModule.TweenPosition(FrameHUD.Left, CloseStartLeftPos, OpenLeftPos, 0.3, 0.2)
			UiAnimationsModule.TweenPosition(FrameHUD.Toolbar, CloseStartToolbarPos, OpenToolbarPos, 0.3, 0.2)
		end)
		UiManagerScreens.HUD = nil
	elseif state == false then
		task.spawn(function()
			-- Tween HUD elements from open to close positions
			UiAnimationsModule.TweenPosition(FrameHUD.Left, OpenLeftPos, CloseLeftPos, 0.1, 0.15)
			UiAnimationsModule.TweenPosition(FrameHUD.Toolbar, OpenToolbarPos, CloseToolbarPos, 0.1, 0.15)
			UiManagerScreens.HUD = nil
		end)
		UiManagerScreens.HUD = nil
	else
		FrameHUD.Visible = false
	end
end

local function fadeScreen(duration: number)
	duration = duration or 1

	local tween = TweenService:Create(screenFadeFrame, TweenInfo.new(screenFadeTime, Enum.EasingStyle.Linear), {BackgroundTransparency = 0})

	tween:Play()
	tween.Completed:Wait()

	task.wait(duration)

	tween = TweenService:Create(screenFadeFrame, TweenInfo.new(screenFadeTime, Enum.EasingStyle.Linear), {BackgroundTransparency = 1})

	tween:Play()
	tween.Completed:Wait()
end

local IconFrame = FrameHUD.Left.IconFrame.Buttons

IconFrame.Shop.Activated:Connect(function()
	if player:GetAttribute("HUD_Blocked") == true then return end
	
	if UiManagerScreens.Shop then
		UiManagerScreens.Shop = false
		UiManagerScreens:RunActiveScreens()
	else
		UiManagerScreens:SetAllScreensFalse()
		
		UiManagerScreens.Shop = true
		UiManagerScreens:RunActiveScreens()
	end
end)

IconFrame.Settings.Activated:Connect(function()
	if player:GetAttribute("HUD_Blocked") == true then return end
	
	if UiManagerScreens.Settings then
		UiManagerScreens.Settings = false
		UiManagerScreens:RunActiveScreens()
	else
		UiManagerScreens:SetAllScreensFalse()

		UiManagerScreens.Settings = true
		UiManagerScreens:RunActiveScreens()
	end
end)

IconFrame.Code.Activated:Connect(function()
	if player:GetAttribute("HUD_Blocked") == true then return end

	if UiManagerScreens.Codes then
		UiManagerScreens.Codes = false
		UiManagerScreens:RunActiveScreens()
	else
		UiManagerScreens:SetAllScreensFalse()

		UiManagerScreens.Codes = true
		UiManagerScreens:RunActiveScreens()
	end
end)

IconFrame.Daily.Activated:Connect(function()
	if player:GetAttribute("HUD_Blocked") == true then return end

	if UiManagerScreens.DailyRewards then
		UiManagerScreens.DailyRewards = false
		UiManagerScreens:RunActiveScreens()
	else
		UiManagerScreens:SetAllScreensFalse()

		UiManagerScreens.DailyRewards = true
		UiManagerScreens:RunActiveScreens()
	end
end)

IconFrame.Inventory.Activated:Connect(function()
	if player:GetAttribute("HUD_Blocked") == true then return end

	if UiManagerScreens.Inventory then
		UiManagerScreens.Inventory = false
		UiManagerScreens:RunActiveScreens()
	else
		UiManagerScreens:SetAllScreensFalse()

		UiManagerScreens.Inventory = true
		UiManagerScreens:RunActiveScreens()
	end
end)

IconFrame.Todo.Activated:Connect(function()
	if player:GetAttribute("HUD_Blocked") == true then return end

	if UiManagerScreens.Todo then
		UiManagerScreens.Todo = false
		UiManagerScreens:RunActiveScreens()
	else
		UiManagerScreens:SetAllScreensFalse()

		UiManagerScreens.Todo = true
		UiManagerScreens:RunActiveScreens()
	end
end)

local tp_debounce = false

IconFrame.GoToDog.Activated:Connect(function()
	if tp_debounce then return end
	tp_debounce = true
	task.delay(0.5, function()
		tp_debounce = false
	end)
	
	local character = player.Character
	local humanoid = character.Humanoid
	
	if humanoid.Health <= 0 then return end
	
	task.spawn(fadeScreen, 0.4)
	task.wait(screenFadeTime)
	
	character:PivotTo(workspace.SpawnLocation.CFrame * CFrame.new(0, 3, 0) * CFrame.Angles(0, math.rad(-90), 0))
end)

local arrowOpen = true

IconFrame.Arrow.Activated:Connect(function()
	if arrowOpen then
		local arrowTween = TweenService:Create(IconFrame.Arrow, TweenInfo.new(0.2), {Rotation = 90})
		local iconsTween = TweenService:Create(IconFrame, TweenInfo.new(0.2), {Position = UDim2.new(-0.5,0,0.5,0)} )
		arrowTween:Play()
		iconsTween:Play()
		arrowOpen = false
	else
		local arrowTween = TweenService:Create(IconFrame.Arrow, TweenInfo.new(0.2), {Rotation = -90})
		local iconsTween = TweenService:Create(IconFrame, TweenInfo.new(0.2), {Position = UDim2.new(0.5,0,0.5,0)} )
		arrowTween:Play()
		iconsTween:Play()
		arrowOpen = true
	end
end)

rs.Bindables.ScreenFade.Event:Connect(fadeScreen)

HUDModule.UiAnimationsModule = UiAnimationsModule
HUDModule.UiManagerScreens = UiManagerScreens

return HUDModule
