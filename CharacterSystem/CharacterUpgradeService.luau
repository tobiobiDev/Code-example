--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BrainrotCharacterConfigs = require(ReplicatedStorage.Source.Configs.BrainrotCharacterConfigs)
local Characters = require(ReplicatedStorage.Source.Data.Characters)
local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local TraitsConfig = require(ReplicatedStorage.Source.Configs.TraitsConfig)
local tryGetPlayerProfile = require(ServerScriptService.Source.PlayerData.tryGetPlayerProfile)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

local UPGRADE_PRICE_INCREASE = BrainrotCharacterConfigs.UPGRADE_PRICE_INCREASE
local MAX_LEVEL = BrainrotCharacterConfigs.MAX_LEVEL

local CharacterUpgradeService = {}

function CharacterUpgradeService.ApplyUpgradeFormula(baseUpgradePrice: number, characterLevel: number): number
	local priceIncrease = 1
	for _, info in UPGRADE_PRICE_INCREASE do
		if characterLevel >= info.Level then
			priceIncrease = info.Multiplier
			break
		end
	end

	return math.floor(baseUpgradePrice * (priceIncrease ^ (characterLevel - 1)))
end

function CharacterUpgradeService.GetUpgradePrice(player: Player, characterId: string): number | nil
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return nil
	end

	local characterInfo = profile.CollectedCharacters[characterId]
	if not characterInfo then
		logger.log(
			`Tried getting upgrade price for character id: {characterId} for {player.Name} but they don't own it`
		)
		return nil
	end

	local characterName = characterInfo.Name
	local characterLevel = characterInfo.Level
	local characterMutation = characterInfo.Mutation
	local characterTrait = TraitsConfig[characterInfo.Trait]

	local traitMultiplier = 1
	local maxLevelIncrease = 0

	if characterTrait then
		local boostData = characterTrait.Boost
		traitMultiplier = if boostData and boostData.UpgradeDecrease then boostData.UpgradeDecrease else 1
		maxLevelIncrease = if boostData and boostData.MaxUpgradeIncrease then boostData.MaxUpgradeIncrease else 0
	end

	local baseUpgradePrice = Characters[characterName].CashPerSecond
		* BrainrotCharacterConfigs.BASE_UPGRADE_PRICE_MULTIPLIER
	local ugradePrice = baseUpgradePrice * traitMultiplier
	local additionalLevels = BrainrotCharacterConfigs.MUTATION_INCREASE[characterMutation] or 0

	if characterLevel >= MAX_LEVEL + additionalLevels + maxLevelIncrease then
		logger.log(`{characterName} is already at max level`)
		return -1
	end

	local upgradePrice = CharacterUpgradeService.ApplyUpgradeFormula(ugradePrice, characterLevel)

	return upgradePrice
end

return CharacterUpgradeService
