--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TraitsInfoType = require(ReplicatedStorage.Source.Types.TraitsInfoType)

local TraitsConfig: TraitsInfoType.TraitType = {
	Ancient = {
		Chance = 3,
		Decorator = { Color = Color3.new(0, 1, 0.533333), Effect = "Lava" },
		Boost = {
			MaxUpgradeIncrease = 10,
		},
	},
	["Ancient Wealth"] = {
		Chance = 3,
		Decorator = { Color = Color3.new(1, 0, 0.482353), Effect = "Silver" },
		Boost = {
			CashBoost = 2,
		},
	},
	Ascended = {
		Chance = 7,
		Decorator = { Color = Color3.new(0, 0.568627, 1), Effect = "Silver" },
		Boost = {
			MaxUpgradeIncrease = 5,
			UpgradeDecrease = 0.85,
		},
	},
	Efficient = {
		Chance = 17,
		Decorator = { Color = Color3.new(0.223529, 0.572549, 1)},
		Boost = {
			UpgradeDecrease = 0.9,
		},
	},
	Enhanced = {
		Chance = 12,
		Decorator = { Color = Color3.new(0, 0.733333, 1)},
		Boost = {
			MaxUpgradeIncrease = 3,
		},
	},
	Godlike = {
		Chance = 1,
		Decorator = { Color = Color3.new(1, 1, 1), Effect = "Rainbow" },
		Boost = {
			MaxUpgradeIncrease = 12,
			UpgradeDecrease = 0.85,
			CashBoost = 1.15,
		},
	},
	["Golden Touch"] = {
		Chance = 19,
		Decorator = { Color = Color3.new(1, 0.984314, 0.54902)},
		Boost = {
			SellValueIncrease = 1.15,
		},
	},
	Greedy = {
		Chance = 15,
		Decorator = { Color = Color3.new(0.768627, 1, 0.419608)},
		Boost = {
			CashBoost = 1.15,
		},
	},
	Hyperactive = {
		Chance = 8,
		Decorator = { Color = Color3.new(0.784314, 1, 0)},
		Boost = {
			CashBoost = 1.5,
		},
	},
	Loaded = {
		Chance = 10,
		Decorator = { Color = Color3.new(0.956863, 1, 0.172549)},
		Boost = {
			CashBoost = 1.3,
		},
	},
	Radiating = {
		Chance = 5,
		Decorator = { Color = Color3.new(0.74902, 0, 1), Effect = "Silver" },
		Boost = {
			BoostNearby = 1.5,
		},
	},
	Traitless = {
		Chance = 0,
		Decorator = { Color = Color3.new(1, 1, 1)},
	},
}

return table.freeze(TraitsConfig)
