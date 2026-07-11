--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefaultConfigs = require(ReplicatedStorage.Source.Configs.DefaultConfigs)
local UpgradeInfoType = require(ReplicatedStorage.Source.Types.UpgradeInfoType)

local UpgradesConfig: UpgradeInfoType.UpgradeInfo = {
	CarryCapacity = {
		BasePrice = 250000,
		BaseAmount = DefaultConfigs.CarryingCapacity,
		Multiplier = 80,
		Increase = 1,
		MaxLevel = 5,
	},
	-- Pickaxe values are stored in `PickaxeConfigs`.
	PickaxeUpgrade = {
		FixedMultiplier = 100,
		CurveGrowth = 1.05,
		LevelMultiplier = {
			{ Level = 1, Multiplier = 1 },
			{ Level = 11, Multiplier = 21 },
			{ Level = 31, Multiplier = 167 },
			{ Level = 51, Multiplier = 1410 },
			{ Level = 71, Multiplier = 5610 },
			{ Level = 101, Multiplier = 7650 },
			{ Level = 131, Multiplier = 122500 },
			{ Level = 171, Multiplier = 371500 },
			{ Level = 211, Multiplier = 854500 },
		},
	},
	Walkspeed = {
		BasePrice = 5000,
		BaseAmount = DefaultConfigs.WalkSpeed,
		Multiplier = 1.6,
		Increase = 1,
		MaxLevel = 22,
	},
}

return table.freeze(UpgradesConfig)
