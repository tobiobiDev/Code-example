--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MutationEnum = require(ReplicatedStorage.Source.Enums.MutationEnum)

type BrainrotCharacterConfigsType = {
	-- CharacterSystem
	read CHECK_INTERVAL: number,
	read CHECK_RADIUS: number,
	read DEFAULT_DESPAWN_TIME_MIN: number,
	read DEFAULT_DESPAWN_TIME_MAX: number,
	read CELESTIAL_SPAWN_TIME: number,
	read TRY_SPAWN_DELAY: number,
	read MAX_LUCK_LEVEL: number,
	read INCREMENT_TIME: number,
	read LUCK_MULTIPLIER: number,
	-- ProximityPrompt Settings
	read MAX_ACTIVATION_DISTANCE: number,
	read HOLD_DURATION: number,

	-- CharacterEarningService
	read UPGRADE_CASH_INCREASE: number,
	read SELL_PRICE_MULTIPLIER: number,
	read OFFLINE_EARNING_MULTIPLIER: number,

	-- CharacterSpawnService
	read MIN_DISTANCE: number,
	read MAX_ATTEMPTS: number,
	read RARE_THRESHOLD: number,
	read GRID_FLOOR_PADDING: number,
	read GRID_CEILING_PADDING: number,
	read GRID_DENSITY_MODIFIER: number,

	-- CharacterUpgradeService
	read BASE_UPGRADE_PRICE_MULTIPLIER: number,
	read UPGRADE_PRICE_INCREASE: { { Level: number, Multiplier: number } },
	read MAX_LEVEL: number,
	read MUTATION_INCREASE: { [MutationEnum.EnumType]: number },

	-- CharacterMutationService
	read MUTATION_CHANCE: number,
	read TRAIT_CHANCE: number,
}

local BrainrotCharacterConfigs: BrainrotCharacterConfigsType = {
	-- CharacterSystem
	CHECK_INTERVAL = 1, -- How often it checks if any of the players are close to spawned characters
	CHECK_RADIUS = 70, -- at which distance from a player does a character model spawn
	DEFAULT_DESPAWN_TIME_MIN = 60, -- seconds
	DEFAULT_DESPAWN_TIME_MAX = 90, -- seconds
	CELESTIAL_SPAWN_TIME = 480, -- How often celestial rarity spawns
	TRY_SPAWN_DELAY = 30, -- How much time to wait between trying to respawn if spawning fails
	MAX_LUCK_LEVEL = 3, -- Maximum number of times luck can be boosted
	INCREMENT_TIME = 15 * 60, -- 15 minutes in seconds
	LUCK_MULTIPLIER = 2, -- How much is luck multiplied each time, 1->2, 2->4 etc
	-- ProximityPrompt Settings
	MAX_ACTIVATION_DISTANCE = 10,
	HOLD_DURATION = 0.8,

	-- CharacterEarningService
	UPGRADE_CASH_INCREASE = 1.12, -- 1.2x or 20% per upgrade
	SELL_PRICE_MULTIPLIER = 133,
	OFFLINE_EARNING_MULTIPLIER = 1 / 25, -- How many times is it decreased

	-- CharacterSpawnService
	MIN_DISTANCE = 20, -- Minimum distance between characters
	MAX_ATTEMPTS = 50, -- Maximum number of attempts to find appropiate position for spawn
	RARE_THRESHOLD = 10, -- At which chance does spawn chance start getting multiplied
	GRID_FLOOR_PADDING = 5, -- Distance from the floor of the zone to start generating spawn points (allows spawning right near the floor)
	GRID_CEILING_PADDING = 5, -- Distance from the ceiling of the zone to stop generating spawn points
	GRID_DENSITY_MODIFIER = 1.5, -- Divides the MIN_DISTANCE step size to increase spawn point grid density. Higher number = denser grid, but more expensive to generate.

	-- CharacterUpgradeService
	BASE_UPGRADE_PRICE_MULTIPLIER = 1.5, -- How expensive is base upgrade price based on base cash per second
	UPGRADE_PRICE_INCREASE = {
		{ Level = 15, Multiplier = 1.365 },
		{ Level = 1, Multiplier = 1.3 },
	},
	MAX_LEVEL = 15, -- Maximum level for a non-mutated character
	MUTATION_INCREASE = { -- Amount over the base MAX_LEVEL a mutation applies
		Gold = 5,
		Diamond = 10,
		Ruby = 20,
		Blaze = 35,
	},

	-- CharacterMutationServ ice
	MUTATION_CHANCE = 10, --Chance for character spawning with mutation
	TRAIT_CHANCE = 15, --Chance for character spawning with trait
}

return BrainrotCharacterConfigs
