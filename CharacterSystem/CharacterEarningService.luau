--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BrainrotCharacterConfigs = require(ReplicatedStorage.Source.Configs.BrainrotCharacterConfigs)
local Characters = require(ReplicatedStorage.Source.Data.Characters)
local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local MutationEnum = require(ReplicatedStorage.Source.Enums.MutationEnum)
local MutationsConfig = require(ReplicatedStorage.Source.Configs.MutationsConfig)
local TraitsConfig = require(ReplicatedStorage.Source.Configs.TraitsConfig)
local TraitsEnum = require(ReplicatedStorage.Source.Enums.TraitsEnum)
local tryGetPlayerProfile = require(ServerScriptService.Source.PlayerData.tryGetPlayerProfile)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

local UPGRADE_CASH_INCREASE = BrainrotCharacterConfigs.UPGRADE_CASH_INCREASE
local SELL_PRICE_MULTIPLIER = BrainrotCharacterConfigs.SELL_PRICE_MULTIPLIER
local OFFLINE_EARNING_MULTIPLIER = BrainrotCharacterConfigs.OFFLINE_EARNING_MULTIPLIER

type Floor = "Floor1" | "Floor2" | "Floor3"
type DisplayName = string

type ReturnTable = {
	-- Tracks how much each display per floor has collected
	[Floor]: {
		[DisplayName]: number,
	},
}

local CharacterEarningService = {}

--[[
	Applies formula for earning, called by multiple systems.
]]
function CharacterEarningService.ApplyEarningFormula(
	baseCharacterEarning: number,
	characterLevel: number,
	characterMutation: MutationEnum.EnumType?,
	characterTrait: TraitsEnum.EnumType?,
	proximityMultiplier: number?
)
	local leveledEarning = math.floor(baseCharacterEarning * (UPGRADE_CASH_INCREASE ^ (characterLevel - 1)))
	local mutationMultiplier = if characterMutation then MutationsConfig.Multiplier[characterMutation] else 1
	local traitMultiplier = 1
	local realProximityMultiplier = proximityMultiplier or 1

	local trait = if characterTrait and TraitsConfig[characterTrait] then TraitsConfig[characterTrait] else nil
	if trait and trait.Boost then
		local cashBoost = trait.Boost.CashBoost
		if cashBoost then
			traitMultiplier = cashBoost
		end
	end

	local finalEarning = leveledEarning * mutationMultiplier * traitMultiplier * realProximityMultiplier
	return finalEarning
end

--[[
	Returns how much a character earns online per second.
]]
function CharacterEarningService.GetEarningPerSecond(
	player: Player,
	characterId: string,
	proximityMultiplier: number?
): number
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return 0
	end

	local characterInfo = profile.CollectedCharacters[characterId]
	if not characterInfo then
		logger.log(
			`{player.Name} does not own character they are trying to get earning for, character id: {characterId}`
		)
		return 0
	end

	-- Use the pre-cached base CashPerSecond from the profile when available.
	-- Falls back to full recalculation only if the cached value is missing.
	local baseEarning = if characterInfo.CashPerSecond
		then characterInfo.CashPerSecond * (proximityMultiplier or 1)
		else CharacterEarningService.ApplyEarningFormula(
			Characters[characterInfo.Name].CashPerSecond,
			characterInfo.Level,
			characterInfo.Mutation,
			characterInfo.Trait,
			proximityMultiplier
		)

	local rebirthMultiplier = profile.CashBoosts.RebirthMultiplier
	local finalEarning = baseEarning
		* (rebirthMultiplier + (profile.CashBoosts.FriendsBoost + profile.CashBoosts.SkinBoost) / 100)
	return finalEarning
end

--[[
	Returns how much character earns offline per second
]]
function CharacterEarningService.GetOfflineEarning(player: Player, characterId: string): number
	return CharacterEarningService.GetEarningPerSecond(player, characterId) * OFFLINE_EARNING_MULTIPLIER
end

function CharacterEarningService.GetOfflineEarningTable(player: Player): ReturnTable?
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return nil
	end

	local lastTimeOnline = profile.lastOnline or os.time()
	local now = os.time()
	local returnTable: ReturnTable = {}

	for floorName, floorInfo in profile.BaseInfo do
		if type(floorInfo) ~= "table" then
			continue
		end

		for displayName, displayInfo in floorInfo do
			local characterId = displayInfo.CharacterId
			if not characterId then
				continue
			end

			local offlineRate = CharacterEarningService.GetOfflineEarning(player, characterId)
			local amountGained = (now - lastTimeOnline) * offlineRate

			returnTable[floorName] = returnTable[floorName] or {}
			returnTable[floorName][displayName] = amountGained

			logger.log(`{player.Name} earned {amountGained} Cash while offline at {displayName} on {floorName}`)
		end
	end

	return returnTable
end

function CharacterEarningService.GetSellPrice(player: Player, characterId: string): number?
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return nil
	end

	local characterTrait = profile.CollectedCharacters[characterId].Trait
	local cashPerSecond = profile.CollectedCharacters[characterId].CashPerSecond
	local traitMultiplier = 1
	if characterTrait and TraitsConfig[characterTrait] then
		local boostData = TraitsConfig[characterTrait].Boost
		if boostData and boostData.SellValueIncrease then
			traitMultiplier = boostData.SellValueIncrease
		end
	end

	local sellAmount = cashPerSecond * SELL_PRICE_MULTIPLIER * traitMultiplier
	return sellAmount
end

return CharacterEarningService
