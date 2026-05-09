--//Services
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local rs = game:GetService("ReplicatedStorage")
local ls = game:GetService("LocalizationService") -- appologize for the naming convention

--//ModuleScripts
local QuestFunctions = ServerStorage.ModuleScripts.QuestModules.QuestFunctions
local QuestRewardFunctions = require(QuestFunctions.Rewards)
local QuestOnStartFunctions = require(QuestFunctions.OnStart)
local QuestTrackingFunctions = require(QuestFunctions.Tracking)

local EndlessQuestsFunctions = ServerStorage.ModuleScripts.QuestModules.EndlessQuestsFunctions
local EndlessQuestsTrackingFunctions = require(EndlessQuestsFunctions.Tracking)
local EndlessQuestsOnStartFunctions = require(EndlessQuestsFunctions.OnStart)

local NotificationHandler = require(ServerScriptService.Libraries.NotificationHandler)
local QuestsDataTemplate = require(ServerStorage.ModuleScripts.QuestModules.QuestsDataTemplate)
local DataManager = require(ServerScriptService.Data.DataManager)
local QuestsInfo = require(ServerStorage.ModuleScripts.QuestModules.QuestsInfo)
local EndlessQuestsInfo = require(ServerStorage.ModuleScripts.QuestModules.EndlessQuestsInfo)
local GridSystemModule = require(ServerScriptService.Libraries.GridSystemModule)
local DialogueHandler = require(ServerScriptService.Libraries.DialogueHandler)
local LevelingService = require(rs.Services.LevelingService)
local UnlockExternalZoneChunk = require(ServerScriptService.Libraries.UnlockExternalZoneChunk)

--//Objects
local DogFolder = workspace.DogFolder
local DogPart = DogFolder.DogPart

local DogSystemModule = {}

DogSystemModule.debounce = false

local function DogDialogue(QuestDialogues)
	if DogSystemModule.debounce then return end
	DogSystemModule.debounce = true

	DialogueHandler.StartDialogue(DogFolder, QuestDialogues)

	DogSystemModule.debounce = false
end

--[[local function HandleQuest(plr: Player, toolName: string, Quest_num)
	local char = plr.Character
	if not char then return end -- In case character hasn't loaded yet
	local check = false
	local currentQuest = DataManagerModule.GetCurrentQuest(plr)
	-- Check character
	local tool = char:FindFirstChild(toolName)
	if tool and tool:IsA("Tool") then
		tool:Destroy()
		check = true
	end
	local shownEndDialogue = false
	if check then
		DogDialogueShower(DogSystemModule.QuestList[currentQuest].EndDialogues)
		DataManagerModule.SetCurrentQuest(plr, DataManagerModule.GetCurrentQuest(plr) + 1)
		NotificationHandler:SendNotification(plr, "Area Unlocked!" ,false, 5)
		shownEndDialogue = true
		
		DogPart:SetAttribute("CurrentQuest", Quest_num + 1)
	else
		DogDialogueShower(DogSystemModule.QuestList[currentQuest].Dialogues)
		spawnTools(toolName)
		return false
	end
	if not shownEndDialogue then
		DogDialogueShower(DogSystemModule.QuestList[currentQuest].Dialogues)
	end
	
	
end]]

function DogSystemModule.StartTracking(player)
	local currentQuestData = DataManager.GetCurrentQuestData(player)
	
	if next(currentQuestData) == nil then return end
	
	DogPart:SetAttribute("IsDoingQuest", true)
	
	local currentQuestNum = DataManager.GetCurrentQuest(player)
	local maxQuests = #QuestsInfo
	
	local trackingFunction
	
	if currentQuestNum > maxQuests then
		local endlessQuestIndex = DataManager.GetEndlessQuestIndex(player)
		
		trackingFunction = EndlessQuestsTrackingFunctions.StartTrack[endlessQuestIndex]
	else
		trackingFunction = QuestTrackingFunctions.StartTrack[currentQuestNum]
	end
	
	if trackingFunction then
		task.spawn(trackingFunction, player, currentQuestData)
	end
end

local function processNormalQuests(player: Player, questLookup, currentQuestData, currentQuestNum)
	-- check if a quest is currently in progress
	if next(currentQuestData) == nil then
		local isQuestAvailable = DogPart:GetAttribute("IsQuestAvailable")
		if not isQuestAvailable then return end
		
		local dialogueLines = {}
		
		-- order dialogue lines
		for lineIndex, lineData in questLookup.DialogueLines.Start do
			dialogueLines[lineIndex] = lineData.Line
		end
		
		local success, translator: Translator = pcall(function()
			return ls:GetTranslatorForPlayerAsync(player)
		end)
		
		if success and translator ~= nil then
			pcall(function()
				for lineIndex = 1, #dialogueLines do
					local translation = translator:FormatByKey(questLookup.DialogueLines.Start[lineIndex].TranslationKey, {})
					
					if translation then
						dialogueLines[lineIndex] = translation
					end
				end
			end)
		end
		
		DogDialogue(dialogueLines)
		
		local dataTemplate = table.clone(QuestsDataTemplate[currentQuestNum])
		
		local questData = {
			Name = QuestsInfo[currentQuestNum].Name,
			Data = dataTemplate
		}

		DataManager.SetCurrentQuestData(player, questData)
		
		DogPart:SetAttribute("IsQuestAvailable", false)
		DogPart:SetAttribute("IsDoingQuest", true)
		
		local tasks = {}
		
		for taskIndex, taskData in QuestsInfo[currentQuestNum].QuestSteps do
			local success, translation = pcall(function()
				return translator:FormatByKey(taskData.TranslationKey, {})
			end)
			
			local finalString
			
			if success and translation ~= nil then
				finalString = translation
			else
				finalString = taskData.Step
			end
			
			tasks[taskIndex] = {String = finalString, Progress = dataTemplate.Progress[taskIndex], Required = dataTemplate.Required[taskIndex]}
		end
		
		rs.RemoteEvents.TodoList.ShowTodoList:FireClient(player, tasks)

		local onStartFunction = QuestOnStartFunctions[currentQuestNum]

		if onStartFunction then
			task.spawn(onStartFunction, player)
		end

		local trackingFunction = QuestTrackingFunctions.StartTrack[currentQuestNum]

		if trackingFunction then
			task.spawn(trackingFunction, player, questData)
		end
		
		rs.RemoteEvents.SendNotification:FireClient(player, "New tasks available, check your to do list!", false, 5)
	else
		local isCompleted = true
		
		for i, v in ipairs(currentQuestData.Data.Progress) do
			if v ~= currentQuestData.Data.Required[i] then
				isCompleted = false
			end
		end
		
		local success, translator: Translator = pcall(function()
			return ls:GetTranslatorForPlayerAsync(player)
		end)
		
		if not isCompleted then
			local dialogueLines = {}

			-- order dialogue lines
			for lineIndex, lineData in questLookup.DialogueLines.Start do
				dialogueLines[lineIndex] = lineData.Line
			end
			
			if success and translator ~= nil then
				pcall(function()
					for lineIndex = 1, #dialogueLines do
						local translation = translator:FormatByKey(questLookup.DialogueLines.Start[lineIndex].TranslationKey, {})
						
						if translation then
							dialogueLines[lineIndex] = translation
						end
					end
				end)
			end
			
			DogDialogue(dialogueLines)
		else
			QuestTrackingFunctions.StopTrack(player)

			local dialogueLines = {}

			-- order dialogue lines
			for lineIndex, lineData in questLookup.DialogueLines.Completion do
				dialogueLines[lineIndex] = lineData.Line
			end
			
			if success and translator ~= nil then
				pcall(function()
					for lineIndex = 1, #dialogueLines do
						local translation = translator:FormatByKey(questLookup.DialogueLines.Completion[lineIndex].TranslationKey, {})

						if translation then
							dialogueLines[lineIndex] = translation
						end
					end
				end)
			end
			
			DogDialogue(dialogueLines)
			
			local rewardFunction = QuestRewardFunctions[currentQuestNum]
			
			if rewardFunction then
				task.spawn(rewardFunction, player)
			end

			DataManager.SetCurrentQuest(player, currentQuestNum + 1)
			DataManager.SetCompletedQuestsNumber(player, currentQuestNum)
			
			DogPart:SetAttribute("CurrentQuest", currentQuestNum + 1)
			DogPart:SetAttribute("IsDoingQuest", false)
			DogPart:SetAttribute("IsQuestAvailable", true)

			DataManager.SetCurrentQuestData(player, {})
		end
	end
end

local function processEndlessQuests(player, currentQuestData)
	-- check if a quest is currently in progress
	local QuestsCompleted = DataManager.GetCompletedQuestsNumber(player)
	
	local success, translator: Translator = pcall(function()
		return ls:GetTranslatorForPlayerAsync(player)
	end)
	
	if next(currentQuestData) == nil then
		local playerData = DataManager.GetPlayerData(player)
		
		local finalIndex
		
		if playerData.NextEndlessQuestIndex ~= 0 and (EndlessQuestsInfo[playerData.NextEndlessQuestIndex] ~= nil and EndlessQuestsInfo[playerData.NextEndlessQuestIndex].SpecialCondition(player) == true) then
			finalIndex = playerData.NextEndlessQuestIndex
			
			playerData.NextEndlessQuestIndex = 0
		else
			local EndlessQuestIndex = DataManager.GetEndlessQuestIndex(player)
			local stopLoop = false

			repeat
				local rng = math.random(1, #EndlessQuestsInfo)

				if EndlessQuestsInfo[rng].SpecialCondition ~= nil then
					local meetsCondition = EndlessQuestsInfo[rng].SpecialCondition(player)

					if meetsCondition == false then
						continue
					end
				end
				
				if EndlessQuestsInfo[EndlessQuestIndex] and EndlessQuestsInfo[EndlessQuestIndex].QuestType ~= nil and EndlessQuestsInfo[rng].QuestType ~= nil then
					if EndlessQuestsInfo[EndlessQuestIndex].QuestType ~= EndlessQuestsInfo[rng].QuestType then
						finalIndex = rng
						
						stopLoop = true
					end
				elseif finalIndex ~= EndlessQuestIndex then
					finalIndex = rng
					
					stopLoop = true
				end
			until stopLoop == true
		end
		
		DataManager.SetEndlessQuestIndex(player, finalIndex)
		
		local questLookup = EndlessQuestsInfo[finalIndex]
		
		local DialogueLines = table.clone(questLookup.DialogueLines.Start)
		local QuestSteps = table.clone(questLookup.QuestSteps)
		local ProgressTable = {}
		local RequiredTable = {}
		
		for stepIndex, questStep in questLookup.QuestSteps do
			ProgressTable[stepIndex] = 0
			
			-- generate random requirement
			if questLookup.GenerateRequirements ~= nil then
				local amount = questLookup.GenerateRequirements(player)
				RequiredTable[stepIndex] = amount
			else
				local keys = {}

				for key, value in pairs(questLookup.RandomNumbers[stepIndex]) do
					table.insert(keys, key)
				end

				table.sort(keys)

				for i, key in ipairs(keys) do
					if QuestsCompleted < key then
						local min, max = questLookup.RandomNumbers[stepIndex][key].Min, questLookup.RandomNumbers[stepIndex][key].Max
						RequiredTable[stepIndex] = math.random(min, max)

						break
					elseif i == #keys and QuestsCompleted >= key then
						local min, max = questLookup.RandomNumbers[stepIndex][key].Min, questLookup.RandomNumbers[stepIndex][key].Max
						RequiredTable[stepIndex] = math.random(min, max)

						break
					end
				end
			end
		end
		
		local newDialogueLines = {}
		
		for i = 1, #DialogueLines do
			local success, translation = pcall(function()
				return translator:FormatByKey(DialogueLines[i].TranslationKey, {["number1"] = tostring(RequiredTable[1])})
			end)
			
			if success and translation ~= nil then
				DialogueLines[i].Line = translation
			else
				DialogueLines[i].Line = DialogueLines[i].Line:format(table.unpack(RequiredTable))
			end
			
			newDialogueLines[i] = DialogueLines[i].Line
		end
		
		DogDialogue(newDialogueLines)
		
		local questData = {
			Data = {
				Progress = ProgressTable,
				Required = RequiredTable
			}
		}

		DataManager.SetCurrentQuestData(player, questData)
		
		DogPart:SetAttribute("IsQuestAvailable", false)
		DogPart:SetAttribute("IsDoingQuest", true)
		
		local tasks = {}
		
		for taskIndex, taskData in QuestSteps do
			local success, translation = pcall(function()
				return translator:FormatByKey(taskData.TranslationKey, {["number1"] = tostring(questData.Data.Required[taskIndex])})
			end)

			local finalString

			if success and translation ~= nil then
				finalString = translation
			else
				finalString = taskData.Step:format(tostring(questData.Data.Required[taskIndex]))
			end
			
			tasks[taskIndex] = {String = finalString, Progress = ProgressTable[taskIndex], Required = RequiredTable[taskIndex]}
		end
		
		rs.RemoteEvents.TodoList.ShowTodoList:FireClient(player, tasks)
		
		local trackingFunction = EndlessQuestsTrackingFunctions.StartTrack[finalIndex]
		-- check when the number of CurrentQuest is changed here
		if trackingFunction then
			task.spawn(trackingFunction, player, questData)
		end
		
		local onStartFunction = EndlessQuestsOnStartFunctions[finalIndex]
		
		if onStartFunction then
			task.spawn(onStartFunction, player)
		end
		
		rs.RemoteEvents.SendNotification:FireClient(player, "New tasks available, check your to do list!", false, 5)
	else
		local isCompleted = true

		for i, v in pairs(currentQuestData.Data.Progress) do
			if not (v >= currentQuestData.Data.Required[i]) then
				isCompleted = false
				
				break
			end
		end
		
		local endlessQuestIndex = DataManager.GetEndlessQuestIndex(player)
		local questLookup = EndlessQuestsInfo[endlessQuestIndex]
		
		if not isCompleted then
			local DialogueLines = table.clone(questLookup.DialogueLines.Start)
			local RequiredTable = currentQuestData.Data.Required
			
			for i = 1, #DialogueLines do
				DialogueLines[i].Line = DialogueLines[i].Line:format(table.unpack(RequiredTable))
			end
			
			local dialogueLinesTable = {}
			
			for index, dialogueLineData in ipairs(DialogueLines) do
				dialogueLinesTable[index] = dialogueLineData.Line
			end
			
			local newDialogueLines = {}

			for i = 1, #DialogueLines do
				local success, translation = pcall(function()
					return translator:FormatByKey(DialogueLines[i].TranslationKey, {["number1"] = tostring(RequiredTable[1])})
				end)
				
				if success and translation ~= nil then
					DialogueLines[i].Line = translation
				else
					DialogueLines[i].Line = DialogueLines[i].Line:format(table.unpack(RequiredTable))
				end

				newDialogueLines[i] = DialogueLines[i].Line
			end
			
			DogDialogue(newDialogueLines)
		else
			EndlessQuestsTrackingFunctions.StopTrack(player)
			
			-- give reward
			do
				local coinsReward = 0
				local expReward = 0
				
				if QuestsCompleted < 50 then
					coinsReward = 20
					expReward = 40
				elseif QuestsCompleted < 100 then
					coinsReward = 40
					expReward = 80
				elseif QuestsCompleted < 150 then
					coinsReward = 60
					expReward = 120
				elseif QuestsCompleted < 200 then
					coinsReward = 80
					expReward = 160
				elseif QuestsCompleted < 250 then
					coinsReward = 100
					expReward = 200
				elseif QuestsCompleted < 300 then
					coinsReward = 120
					expReward = 240
				elseif QuestsCompleted < 350 then
					coinsReward = 150
					expReward = 300
				elseif QuestsCompleted < 400 then
					coinsReward = 150
					expReward = 300
				elseif QuestsCompleted < 450 then
					coinsReward = 180
					expReward = 360
				elseif QuestsCompleted < 500 then
					coinsReward = 220
					expReward = 440
				elseif QuestsCompleted >= 500 then
					coinsReward = 250
					expReward = 500
				end
				
				DataManager.AddCoins(player, coinsReward)
				LevelingService:GiveXP(player, expReward)
				
				if #workspace.Chunks:GetChildren() > 0 then
					GridSystemModule:UnlockNextChunk(player)
					NotificationHandler:SendNotification(player, "Area unlocked!", false, 5)
				else
					local aretherestillchunkstounlock = false
					
					for _, zoneFolder in workspace.Zones.ExternalZones:GetChildren() do
						if #zoneFolder.Chunks:GetChildren() > 0 then
							aretherestillchunkstounlock = true
							
							break
						end
					end
					
					if aretherestillchunkstounlock then
						local zoneChosen: string = nil
						
						repeat
							local randomZone = workspace.Zones.ExternalZones:GetChildren()[math.random(1, #workspace.Zones.ExternalZones:GetChildren())]
							
							if #randomZone.Chunks:GetChildren() > 0 then
								zoneChosen = randomZone.Name
								
								break
							end
						until zoneChosen ~= nil
						
						local zoneChunks = workspace.Zones.ExternalZones[zoneChosen].Chunks
						local chunkUnlockedData = UnlockExternalZoneChunk.UnlockChunk(player, zoneChosen)
						
						if chunkUnlockedData ~= nil then
							NotificationHandler:SendNotification(player, "Area unlocked ("..zoneChosen..")", false, 5, nil, "NOTIFICATION_AREAUNLOCKED2", {zoneChosen})
							
							if chunkUnlockedData.WasBossTerritory then
								local playerData = DataManager.GetPlayerData(player)

								playerData.NextEndlessQuestIndex = workspace.Zones.ExternalZones:FindFirstChild(zoneChosen):GetAttribute("BossFightQuestIndex")
							end
						end
					end
				end
			end

			DataManager.SetCompletedQuestsNumber(player, QuestsCompleted + 1)
			
			DogPart:SetAttribute("IsDoingQuest", false)
			DogPart:SetAttribute("IsQuestAvailable", true)

			DataManager.SetCurrentQuestData(player, {})
			
			local dialogueLines = {}

			-- order dialogue lines
			for lineIndex, lineData in questLookup.DialogueLines.Completion do
				dialogueLines[lineIndex] = lineData.Line
			end

			if success and translator ~= nil then
				pcall(function()
					for lineIndex = 1, #dialogueLines do
						local translation = translator:FormatByKey(questLookup.DialogueLines.Completion[lineIndex].TranslationKey, {})

						if translation then
							dialogueLines[lineIndex] = translation
						end
					end
				end)
			end
			
			DogDialogue(dialogueLines)
		end
	end
end

function DogSystemModule.onProxTriggered(player)
	if player:GetAttribute("DataLoaded") ~= true then return end
	if DogSystemModule.debounce then return end
	
	local currentQuestNum = DataManager.GetCurrentQuest(player) 
	local currentQuestData = DataManager.GetCurrentQuestData(player)
	
	local questNumber = DogPart:GetAttribute("CurrentQuest")
	local maxQuests = #QuestsInfo

	if questNumber > maxQuests then
		processEndlessQuests(player, currentQuestData)
	else
		local questLookup = QuestsInfo[currentQuestNum]

		if not questLookup then return end
		
		processNormalQuests(player, questLookup, currentQuestData, currentQuestNum)
	end
end

return DogSystemModule