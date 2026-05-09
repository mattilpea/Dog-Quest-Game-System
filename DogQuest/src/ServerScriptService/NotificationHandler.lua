local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotificationHandler = {}



function NotificationHandler:SendNotification(plr : Player, msg : string, infinite : boolean, timeOut : number, iconImageId, translationKey: string, translationArgs: {})
	ReplicatedStorage.RemoteEvents.SendNotification:FireClient(plr, msg, infinite, timeOut, iconImageId, translationKey, translationArgs)
end


return NotificationHandler