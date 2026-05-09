local TweenService = game:GetService("TweenService")
local soundService = game:GetService("SoundService")
local ls = game:GetService("LocalizationService")

local player = game.Players.LocalPlayer

local success, translator: Translator = pcall(function()
	return ls:GetTranslatorForPlayer(player)
end)

local NotificationModule = {}

local OpenNotificationPos = UDim2.new(0.5,0,0.5,0)
local CloseNotificationPos = UDim2.new(2,0,0.5,0)
local CloseStartNotificationPos = UDim2.new(0.45,0,0.5,0)

--//ModuleScripts
local HUDModule = require(script.Parent)
local UiManagerScreens = HUDModule.UiManagerScreens 
local UiAnimationsModule = HUDModule.UiAnimationsModule --its just redirected, dw, its just animations/ client

NotificationModule.NotificationList= {}
local NotificationList = NotificationModule.NotificationList

--//Objects
local NotificationTemplate = script.NotificationTemplate
local NotificationContainer = UiManagerScreens.FrameNotification

function NotificationModule:SendNotification(msg : string, infinite : boolean , timeout : number,  iconImageID : number, translationKey: string, translationArgs: {})
	iconImageID = iconImageID or "rbxassetid://99207187195937" -- should be fine instead of string or rbxassetid://
	translationArgs = translationArgs or {}
	
	local newNotification = NotificationTemplate:Clone()
	
	local tbl = {newNotificationFrame = newNotification}
	
	table.insert(NotificationList, tbl)
	newNotification.BGNotification.Position = CloseNotificationPos
	for index, notif in ipairs(NotificationList) do
		notif.newNotificationFrame.LayoutOrder = -index --instinctively inversing this is the one of the smartest things ive done in my scripting career, cuz this saved me around 30-50 lines of code easily
	end

	if success == true and translationKey ~= nil then
		local success, translation = pcall(function()
			if translationKey then
				return translator:FormatByKey(translationKey, translationArgs)
			else
				return translator:Translate(game, msg)
			end
		end)
		
		if success and translation ~= nil then
			msg = translation
		end
	end
	
	newNotification.BGNotification.Message.Text = msg
	newNotification.BGNotification.Icon.Image = iconImageID
	newNotification.Parent = NotificationContainer
	
	local soundClone = soundService.Notification:Clone()
	soundClone.Parent = newNotification
	soundClone:Play()
	
	UiAnimationsModule.TweenPosition(newNotification.BGNotification, CloseNotificationPos, CloseStartNotificationPos, 0.3, 0.2 )
	UiAnimationsModule.TweenPosition(newNotification.BGNotification, CloseStartNotificationPos, OpenNotificationPos, 0.3, 0.2 )
	
	local loadingBar = newNotification:WaitForChild('BGNotification'):WaitForChild('LoadingBar')
	local ToScale = loadingBar.ToScale
	
	local connection1
	local connection2
	
	local function closeNotification()
		if newNotification then
			-- Tween out the notification visually
			UiAnimationsModule.TweenPosition(newNotification.BGNotification, OpenNotificationPos, CloseStartNotificationPos, 0.3, 0.2)
			UiAnimationsModule.TweenPosition(newNotification.BGNotification, CloseStartNotificationPos, CloseNotificationPos, 0.3, 0.2)
			
			for i, v in ipairs(NotificationList) do
				if v.newNotificationFrame == newNotification then
					table.remove(NotificationList, i)
					break
				end
			end

			
			-- Destroy the UI object
			if newNotification then
				newNotification:Destroy()
				newNotification = nil
			end
			
			if connection1 then
				connection1:Disconnect()
				connection1 = nil
			end
			if connection2 then
				connection2:Disconnect()
				connection2 = nil
			end

			
		end
	end
	if not infinite and timeout then
		local tween = TweenService:Create(ToScale, TweenInfo.new(timeout), {Size = UDim2.new(0,0,1,0) } )
		tween:Play()
		
		connection1 = tween.Completed:Connect(function()
			closeNotification()
		end)
		
	end
	
	UiAnimationsModule.HoverAndClick(newNotification.BGNotification.Close)
	connection2 = newNotification.BGNotification.Close.Activated:Connect(function()
		closeNotification()
	end)
	
end



return NotificationModule
