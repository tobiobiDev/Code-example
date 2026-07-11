--!strict
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local BaseConfigs = require(ReplicatedStorage.Source.Configs.BaseConfigs)
local BaseInterfaceService = require(script.Parent.BaseInterfaceService)
local BaseSkinService = require(script.Parent.BaseSkinService)
local CharacterEarningService = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterEarningService)
local CharacterInfoService = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterInfoService)
local CharacterMutationService = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterMutationService)
local CharacterNameEnum = require(ReplicatedStorage.Source.Enums.CharacterNameEnum)
local CharacterSpawnService = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterSpawnService)
local CharacterSystem = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterSystem)
local CharacterToolService = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterToolService)
local CharacterUpgradeService = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterUpgradeService)
local CurrencyEnum = require(ReplicatedStorage.Source.Enums.CurrencyEnum)
local FloorService = require(script.Parent.FloorService)
local FriendBoostService = require(script.Parent.FriendBoostService)
local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local MovementValidationSystem = require(ServerScriptService.Source.Systems.MovementValidationSystem)
local MutationEnum = require(ReplicatedStorage.Source.Enums.MutationEnum)
local Network = require(ReplicatedStorage.Source.Libs.Network)
local PlayerCharacterService = require(ServerScriptService.Source.Systems.PlayerCharacterSystem.PlayerCharacterService)
local PlayerDataService = require(ServerScriptService.Source.PlayerData.PlayerDataService)
local RebirthSystem = require(ServerScriptService.Source.Systems.RebirthSystem)
local Signal = require(ReplicatedStorage.Source.Libs.Signal)
local TraitsConfig = require(ReplicatedStorage.Source.Configs.TraitsConfig)
local TraitsEnum = require(ReplicatedStorage.Source.Enums.TraitsEnum)
local TutorialConfig = require(ReplicatedStorage.Source.Configs.TutorialConfig)
local formatNumber = require(ReplicatedStorage.Source.Utility.formatNumber)
local tryGetPlayerProfile = require(ServerScriptService.Source.PlayerData.tryGetPlayerProfile)

local basesFolder = assert(workspace:FindFirstChild("Bases"), "Workspace is missing 'Bases' folder")
local tutorialBasesFolder =
	assert(workspace:FindFirstChild("TutorialBases"), "Workspace is missing 'TutorialBases' folder")
local tutorialBase = assert(ServerStorage:FindFirstChild("TutorialBase"), "ServerStorage is missing tutorial base")

local MAX_BASES = #basesFolder:GetChildren()

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

local ADJACENT_DISPLAYS: { [number]: { number } } = {
	[1] = { 2 },
	[2] = { 1, 3 },
	[3] = { 2, 4 },
	[4] = { 3 },

	[5] = { 6 },
	[6] = { 5, 7 },
	[7] = { 6, 8 },
	[8] = { 7 },
}

type PlayerData = tryGetPlayerProfile.PlayerData

type FloorName = "Floor1" | "Floor2" | "Floor3"
type CharacterName = CharacterNameEnum.EnumType
type CharacterId = string

type PlacedCharacterInfo = {
	Name: CharacterName,
	Level: number,
	Mutation: MutationEnum.EnumType,
	Trait: TraitsEnum.EnumType,
}

-- Per-placed-character runtime state. Created on placement, removed on pickup/sell.
type DisplayRecord = {
	CharacterId: string,
	CharacterInfo: PlacedCharacterInfo,
	LastTime: number,
	CashAmount: number,
	CashPerSecond: number,
}

type FloorRecord = { [number]: DisplayRecord }
type FloorDisplay = { [number]: FloorRecord }

type CharacterLocationRecord = {
	Player: Player,
	FloorId: number,
	DisplayId: number,
}

type BaseMetadata = {
	Skin: string?,
	TotalEarning: number?,
}

local tutorialBaseLocations: { CFrame } = {
	CFrame.new(30, 0.661, 900),
	CFrame.new(-64, 0.661, 900),
	CFrame.new(-158, 0.661, 900),
	CFrame.new(-252, 0.661, 900),
	CFrame.new(-346, 0.661, 900),
	CFrame.new(-440, 0.661, 900),
}

-- Table that holds a record for all unoccupied bases.
local freeBases: { number } = {}

-- Table for direct base number lookup by player.
local playerBaseNumbers: { [Player]: number } = {}

-- Skin / TotalEarning metadata, separated from the per-display records.
local baseMetadata: { [Player]: BaseMetadata } = {}

-- One FloorDisplay per player, keyed by Player.
local baseDisplays: { [Player]: FloorDisplay } = {}

-- Used for reverse lookup of display by character Id.
local characterLocations: { [CharacterId]: CharacterLocationRecord } = {}

local playerSignals: { [Player]: Signal.Signal<number> } = {}

local BaseSystem = {}

local function getSignal(player)
	if not playerSignals[player] then
		playerSignals[player] = Signal.new()
	end
	return playerSignals[player]
end

--[[
    Returns the model for the base a player owns, or nil.
]]
function BaseSystem.GetPlayerBaseModel(player: Player): Model?
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return nil
	end

	local baseNumber = playerBaseNumbers[player]
	if not baseNumber then
		return nil
	end

	local currentTutorialStage = profile.TutorialStage
	local tutorialAreaCompletionStage = TutorialConfig.TutorialAreaCompletionStage
	local inTutorialArea = not profile.CompletedTutorial and currentTutorialStage < tutorialAreaCompletionStage

	if inTutorialArea then
		return tutorialBasesFolder:FindFirstChild(`Base{baseNumber}`) :: Model?
	end

	return basesFolder:FindFirstChild(`Base{baseNumber}`) :: Model?
end

local function reconstructDisplayModelForServer(player: Player, floorNumber: number, displayModelNumber: number): Model?
	local playerBase = BaseSystem.GetPlayerBaseModel(player)
	if not playerBase then
		return nil
	end
	local floorModel = playerBase:FindFirstChild(`Floor{floorNumber}`)
	if not (floorModel and floorModel:IsA("Model")) then
		return nil
	end
	local displayModel = floorModel:FindFirstChild(`Display{displayModelNumber}`)
	if displayModel and displayModel:IsA("Model") then
		return displayModel
	end
	return nil
end

--[[
	Looks up a placed character's record for a specific player.
]]
local function findPlacedCharacterRecord(player: Player, characterId: string): DisplayRecord?
	local location = characterLocations[characterId]
	if location and location.Player == player then
		return if baseDisplays[player] and baseDisplays[player][location.FloorId]
			then baseDisplays[player][location.FloorId][location.DisplayId]
			else nil
	end

	return nil
end

local function isCharacterPlaced(player: Player, characterId: string): boolean
	return findPlacedCharacterRecord(player, characterId) ~= nil
end

--[[
	Retrieves the character model with the matching ID under the given display model.
]]
local function findPlacedCharacterModel(displayModel: Model, characterId: string): Model?
	for _, child in displayModel:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("CharacterId") == characterId then
			return child
		end
	end
	return nil
end

--[[
	Fetches the upgrade price for the given character, formats it, and pushes
	it to BaseInterfaceService for visual updates.
]]
local function updateDisplayUpgradeUi(player: Player, characterId: string, displayModel: Model, characterLevel: number)
	local nextUpgradePrice = CharacterUpgradeService.GetUpgradePrice(player, characterId)
	if not nextUpgradePrice then
		logger.log(`Failed to get next upgrade price for character '{characterId}' for player ID: {player.UserId}`, true)
		return
	end

	if nextUpgradePrice < 0  then
		BaseInterfaceService.UpdateUpgradeUI(displayModel, "MAXED", "MAXED")
	else
		local formatedPrice = formatNumber(nextUpgradePrice)
		local levelText = `Level {characterLevel} > Level {characterLevel + 1}`
		local priceText = `${formatedPrice}`

		BaseInterfaceService.UpdateUpgradeUI(displayModel, levelText, priceText)
	end
end

local function getCharacterModelFromDisplay(
	floorModel: Model,
	displayId: number,
	characterName: CharacterNameEnum.EnumType
): Model?
	local formatedCharacterName = string.gsub(characterName, " ", "")
	local displayModel = floorModel:FindFirstChild(`Display{displayId}`)
	local characterModel = if displayModel then displayModel:FindFirstChild(formatedCharacterName) else nil
	if not (characterModel and characterModel:IsA("Model")) then
		return nil
	end
	return characterModel
end

--[[
	Gets proximity multiplier for the given display.

	@param ignoreDisplayId An optional display number to be ignored in calculation.
]]
local function getProximityMultiplier(
	player: Player,
	floorId: number,
	displayId: number,
	ignoreDisplayId: number?
): number
	local floorRecord = if baseDisplays[player] then baseDisplays[player][floorId] else nil
	if not (floorRecord and floorRecord[displayId]) then
		return 1
	end

	local adjacentIds = ADJACENT_DISPLAYS[displayId]
	if not adjacentIds then
		return 1
	end

	local proximityMultiplier = 1

	for _, adjacentId in adjacentIds do
		if adjacentId == ignoreDisplayId then
			continue
		end

		local boosterRecord = floorRecord[adjacentId]
		if not boosterRecord then
			continue
		end

		local characterInfo = boosterRecord.CharacterInfo
		local trait = if characterInfo and characterInfo.Trait then TraitsConfig[characterInfo.Trait] else nil
		if not trait then
			continue
		end

		local boostNearby = if trait.Boost and trait.Boost.BoostNearby then trait.Boost.BoostNearby else nil

		proximityMultiplier *= boostNearby or 1
	end

	return proximityMultiplier
end

--[[
	Computes cash accumulated since the record's LastTime using the character's
	current earnings rate, adds it to CashAmount, and resets LastTime to now.
]]
local function settleDisplayRecord(
	player: Player,
	floorId: number,
	displayId: number,
	customMultiplier: number?
): DisplayRecord?
	local record = if baseDisplays[player] and baseDisplays[player][floorId]
		then baseDisplays[player][floorId][displayId]
		else nil
	if not record then
		return nil
	end

	local now = os.time()
	local proximityMultiplier = customMultiplier or getProximityMultiplier(player, floorId, displayId)
	local earned = CharacterEarningService.GetEarningPerSecond(player, record.CharacterId, proximityMultiplier)
	local elapsedTime = now - record.LastTime

	record.CashAmount += earned * elapsedTime
	record.LastTime = now

	return record
end

--[[
	Called when character with trait that boosts other characters is picked up or placed.
	If character is picked up, removes multiplier from all nearby displays.
	If it is placed, adds multiplier to all nearby displays.
 ]]
local function onBoosterStateChanged(player: Player, floorId: number, displayId: number, pickedUp: boolean)
	local floorRecord = if baseDisplays[player] then baseDisplays[player][floorId] else nil
	if not floorRecord then
		return
	end

	local boosterRecord = floorRecord[displayId]
	if not boosterRecord then
		return
	end

	local characterInfo = boosterRecord.CharacterInfo
	local trait = if characterInfo and characterInfo.Trait then TraitsConfig[characterInfo.Trait] else nil
	local boostNearby = if trait and trait.Boost then trait.Boost.BoostNearby else nil
	if not boostNearby then
		return
	end

	local adjacentIds = ADJACENT_DISPLAYS[displayId]
	if not adjacentIds then
		return
	end

	local playerBaseIndex = playerBaseNumbers[player]
	local baseModel = if playerBaseIndex then basesFolder:FindFirstChild(`Base{playerBaseIndex}`) else nil
	if not (baseModel and baseModel:IsA("Model")) then
		return
	end

	local floorModel = baseModel:FindFirstChild(`Floor{floorId}`)
	if not (floorModel and floorModel:IsA("Model")) then
		return
	end

	for _, adjacentId in adjacentIds do
		local targetRecord = floorRecord[adjacentId]
		if not targetRecord then
			continue
		end

		local targetInfo = targetRecord.CharacterInfo
		if not targetInfo then
			continue
		end

		local characterModel = getCharacterModelFromDisplay(floorModel, adjacentId, targetInfo.Name)
		if not characterModel then
			continue
		end

		local multiplierWithoutBooster = getProximityMultiplier(player, floorId, adjacentId, displayId)
		local multiplierWithBooster = multiplierWithoutBooster * boostNearby

		local oldMultiplier = if pickedUp then multiplierWithBooster else multiplierWithoutBooster
		local newMultiplier = if pickedUp then multiplierWithoutBooster else multiplierWithBooster

		settleDisplayRecord(player, floorId, adjacentId, oldMultiplier)

		local newEarning = CharacterEarningService.GetEarningPerSecond(player, targetRecord.CharacterId, newMultiplier)
		targetRecord.CashPerSecond = newEarning
		local baseId = `Base{playerBaseIndex}`

		CharacterInfoService.UpdateUiInfo(
			characterModel,
			targetInfo.Name,
			targetInfo.Level,
			newEarning,
			targetInfo.Mutation,
			targetInfo.Trait
		)
		Network.fireAllClients(
			Network.RemoteEvents.PlaceCharacter,
			baseId,
			floorId,
			adjacentId,
			newEarning,
			targetRecord.CashAmount
		)
	end
end

--[[
	Recomputes the player's total cash-per-second across all placed characters
	using pre-cached display values and updates the base UI.
]]
local function recomputeTotalEarning(player: Player)
	local baseModel = BaseSystem.GetPlayerBaseModel(player)
	if not (baseModel and baseModel:IsA("Model")) then
		return
	end

	local metadata = baseMetadata[player]
	if not metadata then
		return
	end

	local total = 0

	local playerBase = baseDisplays[player]
	if not playerBase then
		return
	end

	for _, floorRecord in playerBase do
		for _, record in floorRecord do
			total += record.CashPerSecond
		end
	end

	if metadata.TotalEarning ~= total then
		metadata.TotalEarning = total
		BaseInterfaceService.UpdateTotalEarning(total, baseModel)
		PlayerDataService.AdjustCashPerSecond(player, total)
	end
end

--[[
	Recalculates the CashPerSecond for all display records of the player,
	updates the UI on their character models, notifies clients of the new rates,
	and recomputes the total earnings.
]]
local function updateAllDisplayEarnings(player: Player)
	local playerBase = baseDisplays[player]
	if not playerBase then
		return
	end

	local playerBaseIndex = playerBaseNumbers[player]
	if not playerBaseIndex then
		return
	end

	local baseId = `Base{playerBaseIndex}`
	local baseModel = basesFolder:FindFirstChild(`Base{playerBaseIndex}`)
	if not (baseModel and baseModel:IsA("Model")) then
		return
	end

	for floorId, floorRecord in playerBase do
		local floorModel = baseModel:FindFirstChild(`Floor{floorId}`)
		if not (floorModel and floorModel:IsA("Model")) then
			continue
		end

		for displayId, record in floorRecord do
			local targetInfo = record.CharacterInfo
			if not targetInfo then
				continue
			end

			local characterModel = getCharacterModelFromDisplay(floorModel, displayId, targetInfo.Name)
			if not characterModel then
				continue
			end

			local proximityMultiplier = getProximityMultiplier(player, floorId, displayId)
			local newEarning =
				CharacterEarningService.GetEarningPerSecond(player, record.CharacterId, proximityMultiplier)

			record.CashPerSecond = newEarning

			CharacterInfoService.UpdateUiInfo(
				characterModel,
				targetInfo.Name,
				targetInfo.Level,
				newEarning,
				targetInfo.Mutation,
				targetInfo.Trait
			)

			Network.fireAllClients(
				Network.RemoteEvents.PlaceCharacter,
				baseId,
				floorId,
				displayId,
				newEarning,
				record.CashAmount
			)
		end
	end

	recomputeTotalEarning(player)
end

--[[
	Spawns the given character's model onto a display, setting position and look vector.
	
	@return The character's model is successfully spawned and positioned, else nil.
]]
local function placeAndUpdateModel(
	player: Player,
	characterInfo: PlacedCharacterInfo,
	displayModel: Model,
	characterId: string
): Model?
	local characterName = characterInfo.Name

	local displayPrimaryPart = displayModel.PrimaryPart or displayModel:FindFirstChildOfClass("BasePart")
	if not displayPrimaryPart then
		logger.log(`Failed to place {characterName}: {displayModel.Name} is missing primary part`, true)
		return nil
	end

	local characterModel = CharacterSpawnService.SpawnCharacter(characterName, Vector3.zero)
	if not characterModel then
		logger.log(`Failed to place {characterName}: Missing character model`, true)
		return nil
	end

	local upgradePart = displayModel:FindFirstChild("Upgrade")
	if not (upgradePart and upgradePart:IsA("BasePart")) then
		logger.log(`Failed to place {characterName}: Missing 'Upgrade' BasePart`, true)
		return nil
	end

	local floorTopYPos = displayPrimaryPart.Position.Y + (displayPrimaryPart.Size.Y / 2)
	local newPosition = Vector3.new(displayPrimaryPart.Position.X, floorTopYPos, displayPrimaryPart.Position.Z)
	local lookVector = upgradePart.Position

	characterModel:PivotTo(CFrame.lookAt(newPosition, Vector3.new(lookVector.X, newPosition.Y, lookVector.Z)))

	CharacterMutationService.ApplyMutation(characterModel, characterInfo.Mutation)

	characterModel.Parent = displayModel
	characterModel:SetAttribute("CharacterId", characterId)
	characterModel:AddTag(`PlacedCharacter_{player.UserId}`)

	return characterModel
end

local function placeCharacter(
	player: Player,
	characterId: string,
	floorId: number,
	displayId: number,
	displayModel: Model,
	ranOnStart: boolean?
)
	-- Guard: don't allow placing a character that's already on a display.
	if not ranOnStart and isCharacterPlaced(player, characterId) then
		logger.log(`{player.Name} tried to place a character that is already placed`, true)
		return
	end

	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	local characterInfo = profile.CollectedCharacters[characterId]
	if not characterInfo then
		logger.log(`{player.Name} tried to place character they don't own`, true)
		return
	end

	logger.log(`{player.Name} is trying to place {characterInfo.Name} on Floor {floorId} into Display {displayId}...`)

	local unlockedFloors = profile.BaseInfo.UnlockedFloors
	if floorId > unlockedFloors then
		logger.log(
			`Failed to place {characterInfo.Name} for {player.Name}: Floor '{floorId}' exceeds unlocked floors ({unlockedFloors})`,
			true
		)
		return
	end

	local baseRecord = baseDisplays[player]

	local count = 0
	for _, displayRecord in baseRecord[floorId] do
		if displayRecord.CharacterId then
			count += 1
		end
	end
	local currentlyPlaced = count
	local maxPlaced = BaseConfigs.MaxCharactersPerFloor
	local atMaxFloorCapacity = currentlyPlaced >= maxPlaced

	if atMaxFloorCapacity and not ranOnStart then
		logger.log(`{player.Name} failed to place character on Floor {floorId}: At max floor capacity`, true)
		return
	end

	local characterModel = placeAndUpdateModel(player, characterInfo, displayModel, characterId)
	if not characterModel then
		logger.log(`Failed to place {characterInfo.Name} for {player.Name}: Missing character model`, true)
		return
	end

	CharacterToolService.RemoveTool(player, characterId)

	local floorName = `Floor{floorId}` :: FloorName

	if not ranOnStart then
		PlayerDataService.SavePlacedCharacter(player, floorName, characterId, displayModel.Name)
	end

	displayModel:SetAttribute("Occupied", true)

	if displayModel:GetAttribute("IsTutorialDisplay") then
		Network.fireClient(Network.RemoteEvents.TutorialCharacterPlaced, player)
	end

	-- Read any uncollected cash sitting on this display from the profile.
	-- This allows cash to persist on a display even if characters are swapped.
	local savedDisplay = if profile.BaseInfo[floorName] and profile.BaseInfo[floorName][displayModel.Name]
		then profile.BaseInfo[floorName][displayModel.Name]
		else nil
	local savedDisplayCash = 0
	if savedDisplay and savedDisplay.CollectedCash then
		savedDisplayCash = savedDisplay.CollectedCash
		-- Clear it from the profile since we are absorbing it into the runtime record
		savedDisplay.CollectedCash = 0
	end

	-- Create the display record. If one already existed (e.g. re-joining with saved data),
	-- preserve its CashAmount so previously accumulated offline cash isn't lost.
	local existingRecord = findPlacedCharacterRecord(player, characterId)

	-- Send to client so it can start its local ticker at the correct values.
	local initialCash = (if existingRecord then existingRecord.CashAmount else 0) + savedDisplayCash
	local baseId = `Base{playerBaseNumbers[player]}`

	local characterLevel = characterInfo.Level
	updateDisplayUpgradeUi(player, characterId, displayModel, characterLevel)

	local proximityMultiplier = getProximityMultiplier(player, floorId, displayId)
	local cashPerSecond = CharacterEarningService.GetEarningPerSecond(player, characterId, proximityMultiplier)
	local characterMutation = characterInfo.Mutation
	local characterTrait = characterInfo.Trait

	local placedCharacterInfo: PlacedCharacterInfo = {
		Name = characterInfo.Name,
		Level = characterInfo.Level,
		Mutation = characterMutation,
		Trait = characterTrait,
	}

	baseDisplays[player][floorId][displayId] = {
		CharacterId = characterId,
		CharacterInfo = placedCharacterInfo,
		LastTime = os.time(),
		CashAmount = initialCash,
		CashPerSecond = cashPerSecond,
	}

	characterLocations[characterId] = {
		Player = player,
		FloorId = floorId,
		DisplayId = displayId,
	}

	CharacterInfoService.UpdateUiInfo(
		characterModel,
		characterInfo.Name,
		characterInfo.Level,
		cashPerSecond,
		characterMutation,
		characterTrait
	)

	local traitData = TraitsConfig[characterTrait]
	local boostData = if traitData then traitData.Boost else nil
	if boostData and boostData.BoostNearby then
		onBoosterStateChanged(player, floorId, displayId, false)
	end

	Network.fireAllClients(Network.RemoteEvents.PlaceCharacter, baseId, floorId, displayId, cashPerSecond, initialCash)

	recomputeTotalEarning(player)

	logger.log(`{player.Name} successfuly placed down {characterInfo.Name} on {displayModel.Name}`)
	logger.log(
		`{if ranOnStart then currentlyPlaced else currentlyPlaced + 1}/{maxPlaced} placed characters on this floor.`
	)
end

--[[
	Loops throug the player's profile to place each character found into the correct display.
	Called when initially joining the game and when the tutorial is finished.
]]
local function placeAllCharacters(player: Player, profile: PlayerData, assignedBase: Model)
	logger.log(`Checking if player has any placed characters saved to their profile...`)
	for floorName, floorData in profile.BaseInfo do
		if type(floorData) ~= "table" then
			continue
		end

		for displayName, displayInfo in floorData do
			local floorId = tonumber(string.match(floorName, "%d+"))
			if not (floorId and typeof(floorId) == "number") then
				logger.log(`Failed to convert floor model name '{floorName}' into id.`, true)
				return
			end
			local displayId = tonumber(string.match(displayName, "%d+"))
			if not (displayId and typeof(displayId) == "number") then
				logger.log(`Failed to convert display model name '{displayName}' into id.`, true)
				return
			end

			local floorModel = assignedBase:FindFirstChild(floorName)
			local displayModel = if (floorModel and floorModel:IsA("Model"))
				then floorModel:FindFirstChild(displayName)
				else nil
			if not (displayModel and displayModel:IsA("Model")) then
				logger.log(
					`Failed to place characters for {player.Name}: Display model '{displayName}' missing on {floorName}`,
					true
				)
				continue
			end

			local characterId = displayInfo.CharacterId
			if not characterId then
				if displayInfo.CollectedCash and displayInfo.CollectedCash <= 0 then
					continue
				end

				task.spawn(function()
					local playerCharacter = player.Character
					if
						not (playerCharacter and playerCharacter.Parent == workspace:FindFirstChild("PlayerCharacters"))
					then
						PlayerCharacterService.Signals.CharacterLoaded:Wait()
					end
					Network.fireClient(
						Network.RemoteEvents.UpdateDisplayCash,
						player,
						floorId,
						displayId,
						displayInfo.CollectedCash
					)
				end)

				continue
			end

			logger.log(
				`{player.Name} has a character placed at floor {floorId} - display {displayId}. Attempting to spawn it.`
			)
			placeCharacter(player, characterId, floorId, displayId, displayModel, true)
		end
	end

	-- Ensure the base billboard UI is updated to $0/s if no characters were placed.
	recomputeTotalEarning(player)
end

local function pickupCharacter(
	player: Player,
	profile: PlayerData,
	floorId: number,
	displayId: number,
	displayModel: Model
)
	local floorName = `Floor{floorId}` :: FloorName

	local placedCharacters = profile.BaseInfo[floorName]
	if not placedCharacters then
		return
	end

	local displayEntry = placedCharacters[displayModel.Name]
	local characterId = if displayEntry then displayEntry.CharacterId else nil
	if not (displayEntry and characterId) then
		logger.log(`Failed to pickup character: {displayModel.Name} not found in placed characters.`, true)
		return
	end

	local characterRecord = findPlacedCharacterRecord(player, characterId)
	if not characterRecord then
		logger.log(`Failed to pickup character: Missing character record in baseDisplays table.`, true)
		return
	end

	local characterInfo = characterRecord.CharacterInfo

	local characterModel = findPlacedCharacterModel(displayModel, characterId)
	if not characterModel then
		logger.log(`Failed to pickup character: Character model '{characterId}' not found in {displayModel.Name}`, true)
		return
	end

	-- Settle accumulated cash into the profile before removing the record.
	local record = settleDisplayRecord(player, floorId, displayId)
	if record then
		displayEntry.CollectedCash = record.CashAmount
	end

	local characterTrait = characterInfo.Trait
	local traitData = TraitsConfig[characterTrait]
	local boostData = if traitData then traitData.Boost else nil
	if boostData and boostData.BoostNearby then
		onBoosterStateChanged(player, floorId, displayId, true)
	end

	baseDisplays[player][floorId][displayId] = nil
	characterLocations[characterId] = nil

	characterModel:RemoveTag(`PlacedCharacter_{player.UserId}`)
	displayModel:SetAttribute("Occupied", false)
	BaseInterfaceService.UpdateOfflineEarning(displayModel, "")
	BaseInterfaceService.UpdateUpgradeUI(displayModel, "", "")

	CharacterSpawnService.DespawnCharacter(characterModel)
	PlayerDataService.RemovePlacedCharacter(player, floorName, displayModel.Name)
	CharacterToolService.GiveCharactersTools(player, characterInfo.Name, characterId)

	local baseId = `Base{playerBaseNumbers[player]}`
	Network.fireAllClients(Network.RemoteEvents.PickupCharacter, baseId, floorId, displayId, false)

	recomputeTotalEarning(player)

	logger.log(`{player.Name} succesfully picked up {characterInfo.Name} from {characterModel.Name}`)
end

local function sellCharacter(player: Player, floorId: number, displayId: number)
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	local baseModel = BaseSystem.GetPlayerBaseModel(player)
	if not (baseModel and baseModel:IsA("Model")) then
		logger.log(`Failed to sell character: {player.Name} is missing an assigned base`)
		return
	end

	local floorName = `Floor{floorId}` :: FloorName
	local floorModel =
		assert(baseModel:FindFirstChild(`Floor{floorId}`), `Missing Floor{floorId} model for 'Display{displayId}'`)
	local displayModel = floorModel:FindFirstChild(`Display{displayId}`)
	if not (displayModel and displayModel:IsA("Model")) then
		logger.log(
			`Failed to sell character: {player.Name}'s base is missing 'Display{displayId}' in {floorName} model`
		)
		return
	end

	local baseRecord = baseDisplays[player]
	local floorRecord = if baseRecord then baseRecord[floorId] else nil
	local displayRecord = if floorRecord then floorRecord[displayId] else nil

	if not displayRecord then
		logger.log(`Filaed to sell character: Missing display record for floor {floorId}, display {displayId}`, true)
		return
	end

	local characterId = displayRecord.CharacterId
	if not characterId then
		logger.log(`Failed to sell character: Missing character at floor {floorId}, display {displayId}`, true)
		return
	end

	local characterModel = findPlacedCharacterModel(displayModel, characterId)
	if not characterModel then
		logger.log(`Failed to sell character: Character model '{characterId}' not found in {displayModel.Name}`, true)
		return
	end

	local sellAmount = CharacterEarningService.GetSellPrice(player, characterId)
	if not sellAmount then
		logger.log(`Failed to sell character: Unable to et sell price`, true)
		return
	end

	baseDisplays[player][floorId][displayId] = nil
	characterLocations[characterId] = nil

	-- Discard accumulated cash on sell. The sell price is the payout. (is this how we really want this?)
	if profile.BaseInfo[floorName][displayModel.Name] then
		profile.BaseInfo[floorName][displayModel.Name].CollectedCash = 0
	end

	displayModel:SetAttribute("Occupied", false)

	local baseId = `Base{playerBaseNumbers[player]}`
	Network.fireAllClients(Network.RemoteEvents.PickupCharacter, baseId, floorId, displayId, true)

	BaseInterfaceService.UpdateOfflineEarning(displayModel, "")
	BaseInterfaceService.UpdateUpgradeUI(displayModel, "", "")

	CharacterSpawnService.DespawnCharacter(characterModel)
	PlayerDataService.RemovePlacedCharacter(player, floorName, displayModel.Name)
	PlayerDataService.RemoveCollectedCharacter(player, characterId)
	PlayerDataService.AdjustCurrency(player, CurrencyEnum.Cash, sellAmount)

	recomputeTotalEarning(player)

	logger.log(`{player.Name} succesfully sold {characterId} for {sellAmount}`)
end

local function updateOfflineEarning(player: Player)
	local baseNumber = playerBaseNumbers[player] or nil
	if not baseNumber then
		return
	end

	local baseModel = BaseSystem.GetPlayerBaseModel(player)

	local newBaseInfo = CharacterEarningService.GetOfflineEarningTable(player)
	if not newBaseInfo then
		return
	end

	for floorName, floorInfo in newBaseInfo do
		for displayName, amountGained in floorInfo do
			local floorModel = if baseModel then baseModel:FindFirstChild(floorName) else nil
			if not (floorModel and floorModel:IsA("Model")) then
				logger.log(`Failed to find floor model '{floorName}'.`, true)
				continue
			end

			local displayModel = floorModel:FindFirstChild(displayName)
			if not (displayModel and displayModel:IsA("Model")) then
				logger.log(`Failed to find display model '{displayName}'.`, true)
				continue
			end

			local floorId = tonumber(string.match(floorName, "%d+"))
			if not (floorId and typeof(floorId) == "number") then
				logger.log(`Failed to convert floor model name '{floorName}' into id.`, true)
				continue
			end

			local displayId = tonumber(string.match(displayName, "%d+"))
			if not (displayId and typeof(displayId) == "number") then
				logger.log(`Failed to convert display model name '{displayName}' into id.`, true)
				continue
			end

			local record = if baseDisplays[player] and baseDisplays[player][floorId]
				then baseDisplays[player][floorId][displayId]
				else nil
			if record then
				-- Add offline earnings
				record.CashAmount += amountGained
			end

			local precision = if amountGained < 1000 then 0 else 2
			local formatedText = `(${formatNumber(amountGained, precision)} Earned offline)`
			BaseInterfaceService.UpdateOfflineEarning(displayModel, formatedText)
		end
	end
end

local function updateBaseSkin(player: Player)
	local baseNumber = playerBaseNumbers[player]
	if not baseNumber then
		return
	end

	local metadata = baseMetadata[player]
	if not metadata then
		return
	end

	local updatedSkin = BaseSkinService.GetBaseSkin(player, baseNumber, metadata)
	if updatedSkin then
		metadata.Skin = updatedSkin
		updateAllDisplayEarnings(player)
	end
end

local function spawnTutorialBase(baseIndex: number, player: Player)
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	local cloneBase = tutorialBase:Clone() :: Model
	cloneBase.Name = `Base{baseIndex}`
	cloneBase:PivotTo(tutorialBaseLocations[baseIndex])
	cloneBase.Parent = tutorialBasesFolder

	if profile.TutorialStage > 2 then
		return
	end

	local commonWall = cloneBase:FindFirstChild("CommonWall", true) :: Part
	local spawnPosition = commonWall.Position - Vector3.new(0, commonWall.Position.Y / 2, 0)
	CharacterSystem.SpawnTutorialCharacter("Common", "Burbaloni Luliloli", spawnPosition, 1, player)
end

--[[
	Finds a random free base and assigns it to the player.
	Updates all internal tables.
]]
local function assignBase(player: Player)
	logger.log(`Assigning base for player: {player.Name}`)

	if playerBaseNumbers[player] then
		logger.log(`{player.Name} already has base assigned`)
		return
	end

	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	local assignedBaseIndex: number? = playerBaseNumbers[player]

	-- If not, find random unoccupied base...
	if not assignedBaseIndex then
		-- No bases available.
		if #freeBases == 0 then
			logger.log(`No free bases left for {player.Name}`, true)
			player:Kick(`An error occured while assigning you a base. Please rejoin!`)
			return
		end

		local randomIndex = math.random(#freeBases)
		assignedBaseIndex = table.remove(freeBases, randomIndex)
	end

	if not assignedBaseIndex then
		logger.log(`Failed to assign a base to {player.Name}: Invalid base index`, true)
		player:Kick(`An error occured while assigning you a base. Please rejoin!`)
		return
	end

	local currentTutorialStage = profile.TutorialStage
	local tutorialAreaCompletionStage = TutorialConfig.TutorialAreaCompletionStage
	local inTutorialArea = not profile.CompletedTutorial and currentTutorialStage < tutorialAreaCompletionStage

	local assignedTutorialBase: Model? = nil
	if inTutorialArea then
		spawnTutorialBase(assignedBaseIndex, player)
		assignedTutorialBase = tutorialBasesFolder:FindFirstChild(`Base{assignedBaseIndex}`) :: Model?
		assert(
			assignedTutorialBase and assignedTutorialBase:IsA("Model"),
			`Base{assignedBaseIndex} model missing from 'TutorialBases' folder.`
		)
	end

	local assignedBase = basesFolder:FindFirstChild(`Base{assignedBaseIndex}`)
	assert(assignedBase and assignedBase:IsA("Model"), `Base{assignedBaseIndex} model missing from 'Bases' folder.`)

	logger.log(`Base number {assignedBaseIndex} is being assigned to player: {player.Name}`)

	playerBaseNumbers[player] = assignedBaseIndex
	getSignal(player):Fire(assignedBaseIndex)
	baseMetadata[player] = {
		Skin = nil,
		TotalEarning = nil,
	}
	baseDisplays[player] = {
		[1] = {},
		[2] = {},
		[3] = {},
	}

	assignedBase:AddTag(`{player.UserId}`)
	assignedBase:SetAttribute("Owner", player.UserId)
	if assignedTutorialBase then
		assignedTutorialBase:AddTag(`Tutorial{player.UserId}`)
		assignedTutorialBase:SetAttribute("Owner", player.UserId)
		BaseInterfaceService.ResetBaseGui(assignedTutorialBase, player)
	end

	local unlockedFloors = profile.BaseInfo.UnlockedFloors or 1

	FloorService.syncFloorsVisibility(assignedBase, unlockedFloors)
	BaseInterfaceService.ResetBaseGui(assignedBase, player)

	local billboardGuiPart = assignedBase:FindFirstChild("BaseBillboardUI")
	local billboardGui = if billboardGuiPart then billboardGuiPart:FindFirstChildOfClass("BillboardGui") else nil

	if billboardGui then
		local playerImage = billboardGui:FindFirstChild("PlayerImage")
		local usernameLabel = billboardGui:FindFirstChild("Username")

		if playerImage and playerImage:IsA("ImageLabel") then
			local success, image = pcall(function()
				return Players:GetUserThumbnailAsync(
					player.User,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size420x420
				)
			end)

			if success and image then
				playerImage.Image = image
			end
		end

		if usernameLabel and usernameLabel:IsA("TextLabel") then
			usernameLabel.Text = player.Name
		end
	end

	logger.log(`Finished assigning base {assignedBaseIndex} to {player.Name}`)

	if inTutorialArea then
		recomputeTotalEarning(player)
		return
	end

	placeAllCharacters(player, profile, assignedBase)

	updateBaseSkin(player)
	updateOfflineEarning(player)
	FriendBoostService.UpdateFriendships()

	-- Ensure the base billboard UI is updated to $0/s if no characters were placed.
	recomputeTotalEarning(player)
end

--[[
	Runs when player leaves; saves accumulated cash and clears all runtime state.
	TODO: Maybe hide the display?
]]
local function onPlayerRemove(player: Player)
	local baseNumber = playerBaseNumbers[player]
	if not baseNumber then
		return
	end

	local baseId = `Base{baseNumber}`

	local assignedBase = BaseSystem.GetPlayerBaseModel(player)
	if not assignedBase then
		return
	end

	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	local currentTutorialStage = profile.TutorialStage
	local tutorialAreaCompletionStage = TutorialConfig.TutorialAreaCompletionStage
	local inTutorialArea = not profile.CompletedTutorial and currentTutorialStage < tutorialAreaCompletionStage

	if inTutorialArea and assignedBase.Parent == tutorialBasesFolder then
		assignedBase:Destroy()
	end

	-- Settle and persist every display record that belongs to this player.
	local playerBase = baseDisplays[player]
	if playerBase then
		for floorId, floorRecord in playerBase do
			for displayId, record in floorRecord do
				local settled = settleDisplayRecord(player, floorId, displayId)
				if settled then
					local floorName = `Floor{floorId}` :: FloorName
					local displayName = `Display{displayId}`

					Network.fireAllClients(Network.RemoteEvents.PickupCharacter, baseId, floorId, displayId, true)

					profile.BaseInfo[floorName] = profile.BaseInfo[floorName] or {}
					profile.BaseInfo[floorName][displayName] = profile.BaseInfo[floorName][displayName]
						or { CharacterId = nil, CollectedCash = 0 }
					profile.BaseInfo[floorName][displayName].CollectedCash = settled.CashAmount
				end
				characterLocations[record.CharacterId] = nil
			end
		end
	end

	baseDisplays[player] = nil

	for _, character in CollectionService:GetTagged(`PlacedCharacter_{player.UserId}`) do
		character:Destroy()
	end

	playerBaseNumbers[player] = nil
	baseMetadata[player] = nil
	FriendBoostService.RemovePlayer(player)

	assignedBase = basesFolder:FindFirstChild(`Base{baseNumber}`)
	if not (assignedBase and assignedBase:IsA("Model")) then
		logger.log(`No main base model assigned to {player.Name} with base number '{baseNumber}'`)
		return
	end

	BaseSkinService.GetBaseSkin(player, assignedBase, nil, "Normal")
	FloorService.syncFloorsVisibility(assignedBase, 1) -- Only show first floor
	BaseInterfaceService.ResetBaseGui(assignedBase)
	assignedBase:SetAttribute("Owner", nil)
	assignedBase:RemoveTag(`{player.UserId}`)
	table.insert(freeBases, baseNumber)
end

local function collectCash(player: Player, floorId: number, displayId: number)
	logger.log(`{player.Name} is trying to collect cash`)

	if not playerBaseNumbers[player] then
		logger.log(`{player.Name} isn't assigned a base`, true)
		return
	end

	local displayModel = reconstructDisplayModelForServer(player, floorId, displayId)
	if not displayModel then
		logger.log(`No display model found for Floor {floorId} Display {displayId}`, true)
		return
	end

	local floorName = `Floor{floorId}` :: FloorName
	local displayName = `Display{displayId}`

	local record = if baseDisplays[player] and baseDisplays[player][floorId]
		then baseDisplays[player][floorId][displayId]
		else nil
	local collectedCash = 0

	if record then
		local settled = settleDisplayRecord(player, floorId, displayId)
		if settled and settled.CashAmount > 0 then
			collectedCash = settled.CashAmount
			settled.CashAmount = 0
		end
	else
		local profile = tryGetPlayerProfile(player)
		if not profile then
			return
		end

		-- Check profile for uncollected cash left by a removed character
		if profile.BaseInfo[floorName] and profile.BaseInfo[floorName][displayName] then
			local savedCash = profile.BaseInfo[floorName][displayName].CollectedCash or 0
			if savedCash > 0 then
				collectedCash = savedCash
				profile.BaseInfo[floorName][displayName].CollectedCash = 0

				if not profile.BaseInfo[floorName][displayName].CharacterId then
					profile.BaseInfo[floorName][displayName] = nil
				end
			end
		end
	end

	if collectedCash <= 0 then
		logger.log(`{player.Name} has nothing to collect from {displayName} on {floorName}`)
		return
	end

	PlayerDataService.AdjustCurrency(player, CurrencyEnum.Cash, collectedCash)
	BaseInterfaceService.UpdateOfflineEarning(displayModel, "")

	-- Notify the client so it can reset the display UI.
	local baseId = `Base{playerBaseNumbers[player]}`
	Network.fireAllClients(Network.RemoteEvents.CollectCash, baseId, floorId, displayId, collectedCash)

	logger.log(`{player.Name} succesfully collected {collectedCash} Cash from {displayName} on {floorName}`)
end

--[[
	Runs once player tries upgrading the character, updates all info if succesful.
]]
local function upgradeCharacter(player: Player, floorId: number, displayId: number)
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	local record = if baseDisplays[player] and baseDisplays[player][floorId]
		then baseDisplays[player][floorId][displayId]
		else nil
	if not record then
		logger.log(`Failed to upgrade character at floor {floorId}, display {displayId}: Missing display record`)
		return
	end

	local characterId = record.CharacterId
	if not characterId then
		logger.log(`Failed to upgrade character: Missing character at floor {floorId}, display {displayId}`, true)
		return
	end

	local displayModel = reconstructDisplayModelForServer(player, floorId, displayId)
	if not displayModel then
		logger.log(`Failed to find Display model in base.`, true)
		return
	end

	local floorName = `Floor{floorId}` :: FloorName
	logger.log(`{player.Name} is trying to upgrade character on {displayModel.Name} at {floorName}`)

	local characterModel = findPlacedCharacterModel(displayModel, characterId)
	if not characterModel then
		logger.log(`Failed character upgrade: No character model found at floor {floorId}, display {displayId}`, true)
		return
	end

	if not record.CharacterInfo then
		logger.log(`Failed to upgrade character: No character info in display record`, true)
		return
	end

	local characterInfo = profile.CollectedCharacters[characterId]
	if not characterInfo then
		logger.log(`{player.Name} doesn't own character they are trying to upgrade, character id: {characterId}`, true)
		return
	end

	local upgradePrice = CharacterUpgradeService.GetUpgradePrice(player, characterId)
	if not upgradePrice then
		logger.log(`Failed to get upgrade price for character '{characterId}' for player ID: {player.UserId}`, true)
		return
	end

	if upgradePrice < 0 then
		return -- Character at max level
	end

	-- Settle cash at the old CashPerSecond before the upgrade changes the earning rate.
	settleDisplayRecord(player, floorId, displayId)

	local characterWasUpgraded = PlayerDataService.UpgradeCharacter(player, upgradePrice, characterId)
	if not characterWasUpgraded then
		logger.log(`Failed character upgrade: PlayerDataService.UpgradeCharacter returned false.`)
		return
	end

	record.CharacterInfo.Level = characterInfo.Level

	local characterName = characterInfo.Name
	local characterLevel = characterInfo.Level
	local characterMutation = characterInfo.Mutation
	local characterTrait = characterInfo.Trait
	local proximityMultiplier = getProximityMultiplier(player, floorId, displayId)

	local cashPerSecond = CharacterEarningService.GetEarningPerSecond(player, characterId, proximityMultiplier)

	record.CashPerSecond = cashPerSecond

	updateDisplayUpgradeUi(player, characterId, displayModel, characterLevel)

	CharacterInfoService.UpdateUiInfo(
		characterModel,
		characterName,
		characterLevel,
		cashPerSecond,
		characterMutation,
		characterTrait
	)

	PlayerDataService.AdjustCurrency(player, CurrencyEnum.Cash, -upgradePrice)

	recomputeTotalEarning(player)

	-- Tell the client the new CashPerSecond so it can restart its display ticker at the upgraded rate.
	local baseId = `Base{playerBaseNumbers[player]}`
	Network.fireAllClients(Network.RemoteEvents.UpgradeCharacter, baseId, floorId, displayId, cashPerSecond)

	logger.log(`Succesfully upgraded {characterName} from {characterLevel - 1} to {characterLevel} for {upgradePrice}$`)
end

local function onCharacterLoaded(player: Player, character: Model)
	logger.log(`Character loaded for {player.Name}, running function`)
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	local currentTutorialStage = profile.TutorialStage
	local tutorialAreaCompletionStage = TutorialConfig.TutorialAreaCompletionStage
	local inTutorialArea = not profile.CompletedTutorial and currentTutorialStage < tutorialAreaCompletionStage

	local assignedBaseIndex = playerBaseNumbers[player]
	if not assignedBaseIndex then
		assignedBaseIndex = getSignal(player):Wait()
	end

	local assignedBase = basesFolder:FindFirstChild(`Base{assignedBaseIndex}`)
	if not assignedBase then
		logger.log(`Assigned base index not found for {player.Name}`)
		return
	end

	local assignedTutorialBase: Model? = nil
	if inTutorialArea then
		assignedTutorialBase = tutorialBasesFolder:FindFirstChild(`Base{assignedBaseIndex}`) :: Model?
		assert(
			assignedTutorialBase and assignedTutorialBase:IsA("Model"),
			`Base{assignedBaseIndex} model missing from 'TutorialBases' folder.`
		)
	end

	local baseSpawn = if inTutorialArea
		then if assignedTutorialBase then assignedTutorialBase:FindFirstChildOfClass("SpawnLocation") else nil
		else assignedBase:FindFirstChildOfClass("SpawnLocation")
	if not baseSpawn then
		logger.log(`SpawnLocation missing for base {assignedBaseIndex}`, true)
		return
	end

	MovementValidationSystem.ExemptPlayer(player, 2)

	character:PivotTo(baseSpawn.CFrame + Vector3.new(0, 3, 0))
end

function BaseSystem.Start()
	for i = 1, MAX_BASES do
		table.insert(freeBases, i)
	end

	for _, baseModel in basesFolder:GetChildren() do
		if baseModel:IsA("Model") then
			FloorService.syncFloorsVisibility(baseModel, 1) -- Only show first floor
			BaseInterfaceService.ResetBaseGui(baseModel)
		end
	end

	Players.PlayerAdded:Connect(assignBase)

	for _, player in Players:GetPlayers() do
		assignBase(player)
	end

	PlayerCharacterService.Signals.CharacterLoaded:Connect(function(player: Player, character: Model)
		task.spawn(onCharacterLoaded, player, character)
	end)

	Players.PlayerRemoving:Connect(onPlayerRemove)

	Network.connectEvent(Network.RemoteEvents.FinishedTutorialArea, function(player: Player)
		logger.log(`{player.Name} finished tutorial area, moving them to main base`)

		local profile = tryGetPlayerProfile(player)
		if not profile then
			return
		end

		local character = player.Character
		if not character then
			logger.log(`Failed to finish tutorial area: Unabel to find character for {player.Name}`, true)
			return
		end

		-- TODO: We should account for possible issues like this, such as reloading the player.
		local baseNumber = playerBaseNumbers[player]
		if not baseNumber then
			logger.log(`Failed to find a base number for {player.Name}`, true)
			return
		end

		local assignedBase = BaseSystem.GetPlayerBaseModel(player)
		if not assignedBase then
			logger.log(`Failed to find an assigned base for {player.Name}`, true)
			return
		end
		logger.log(`Reassigned base for {player.Name} to '{assignedBase:GetFullName()}'`)

		local baseSpawn = assignedBase:FindFirstChildOfClass("SpawnLocation")
		if not baseSpawn then
			logger.log(`SpawnLocation missing for base {baseNumber}`, true)
			return
		end

		MovementValidationSystem.ExemptPlayer(player, 2)
		character:PivotTo(baseSpawn.CFrame + Vector3.new(0, 3, 0))
		
		local assignedTutorialBase = tutorialBasesFolder:FindFirstChild(`Base{baseNumber}`) :: Model?
		if not assignedTutorialBase then
			logger.log(`Failed to find {player.Name}'s tutorial base for deletion.`)
			return
		end
		
		placeAllCharacters(player, profile, assignedBase)
		
		assignedTutorialBase:Destroy()
		Network.fireClient(Network.RemoteEvents.FinishedTutorialArea, player)
	end)

	Network.connectEvent(
		Network.RemoteEvents.PlaceCharacter,
		function(player: Player, characterId: string, floorNumber: number, displayModelNumber: number)
			local profile = tryGetPlayerProfile(player)
			if not profile then
				return
			end

			local playerBase = BaseSystem.GetPlayerBaseModel(player)
			if not playerBase then
				return
			end

			local floorModel = playerBase:FindFirstChild(`Floor{floorNumber}`)
			local displayModel = if floorModel then floorModel:FindFirstChild(`Display{displayModelNumber}`) else nil

			if not (displayModel and displayModel:IsA("Model")) then
				logger.log(
					`{player.Name} failed to place character in Display{tostring(displayModelNumber)} of Floor{tostring(
						floorNumber
					)}: Missing Display model`
				)
				return
			end

			if characterId and displayModel:GetAttribute("Occupied") then
				logger.log(`{player.Name} is trying to swap character on {displayModel.Name}`)
				pickupCharacter(player, profile, floorNumber, displayModelNumber, displayModel)
				placeCharacter(player, characterId, floorNumber, displayModelNumber, displayModel)
			elseif not characterId and displayModel:GetAttribute("Occupied") then
				logger.log(`{player.Name} is trying to pick up character from {displayModel.Name}`)
				pickupCharacter(player, profile, floorNumber, displayModelNumber, displayModel)
			elseif characterId and not displayModel:GetAttribute("Occupied") then
				logger.log(`{player.Name} is trying to place character on {displayModel.Name}`)
				placeCharacter(player, characterId, floorNumber, displayModelNumber, displayModel)
			end
		end
	)

	Network.connectEvent(Network.RemoteEvents.SellCharacter, sellCharacter)
	Network.connectEvent(Network.RemoteEvents.CollectCash, collectCash)
	Network.connectEvent(Network.RemoteEvents.UpgradeCharacter, upgradeCharacter)

	CharacterSystem.UnlockedBaseSkin:Connect(updateBaseSkin)
	FriendBoostService.MultiplierChanged:Connect(updateAllDisplayEarnings)

	RebirthSystem.Rebirthed:Connect(function(player: Player)
		FriendBoostService.UpdateBaseMultiplier(player)
	end)
end

return BaseSystem
