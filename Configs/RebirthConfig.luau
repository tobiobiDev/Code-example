--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RarityEnum = require(ReplicatedStorage.Source.Enums.RarityEnum)
local RebirthInfoType = require(ReplicatedStorage.Source.Types.RebirthInfoType)

local RebirthConfig: RebirthInfoType.RebirthInfo = {
	Config = {
		BonusIncrease = 0.15, -- Cash multiplier per level
		MaxRebirth = 25,
		UpgradesPerRebirth = 5, -- How many upgrades needed per rebirth
		FloorIncreaseRebirth = 10, -- Every how many rebirths does player get a floor
		RebirthIncrease = {
			[5] = 2,
			[10] = 1.83,
			[15] = 1.83,
			[20] = 1.9,
		}, -- At which rebirth does cash bonus multiply by which value
	},

	Requirements = {
		-- Special requirements, for example character or specific amount of upgrades
		[1] = {
			PickaxeUpgrade = 5,
		},
		[2] = {
			PickaxeUpgrade = 15,
		},
		[3] = {
			PickaxeUpgrade = 12,
		},
		[4] = {
			PickaxeUpgrade = 3,
			OwnedCharacters = {
				Rarity = RarityEnum.Epic,
				Amount = 3,
			},
		},
		[5] = {
			PickaxeUpgrade = 7,
			OwnedCharacters = {
				Rarity = RarityEnum.Epic,
				Amount = 7,
			},
		},
		[6] = {
			PickaxeUpgrade = 1,
			OwnedCharacters = {
				Rarity = RarityEnum.Legendary,
				Amount = 3,
			},
		},
		[7] = {
			PickaxeUpgrade = 4,
			OwnedCharacters = {
				Rarity = RarityEnum.Legendary,
				Amount = 6,
			},
		},
		[8] = {
			PickaxeUpgrade = 3,
			OwnedCharacters = {
				Rarity = RarityEnum.Legendary,
				Amount = 10,
			},
		},
		[9] = {
			PickaxeUpgrade = 3,
			OwnedCharacters = {
				Rarity = RarityEnum.Mythical,
				Amount = 2,
			},
		},
		[10] = {
			PickaxeUpgrade = 2,
			Character = "Bombardino Crocodilo",
		},
		[11] = {
			PickaxeUpgrade = 2,
			OwnedCharacters = {
				Rarity = RarityEnum.Mythical,
				Amount = 7,
			},
		},
		[12] = {
			PickaxeUpgrade = 2,
			OwnedCharacters = {
				Rarity = RarityEnum.Mythical,
				Amount = 10,
			},
		},
		[13] = {
			PickaxeUpgrade = 4,
			OwnedCharacters = {
				Rarity = RarityEnum.Divine,
				Amount = 2,
			},
		},
		[14] = {
			PickaxeUpgrade = 7,
			OwnedCharacters = {
				Rarity = RarityEnum.Divine,
				Amount = 4,
			},
		},
		[15] = {
			PickaxeUpgrade = 15,
			OwnedCharacters = {
				Rarity = RarityEnum.Divine,
				Amount = 8,
			},
		},
		[16] = {
			PickaxeUpgrade = 10,
			OwnedCharacters = {
				Rarity = RarityEnum.Secret,
				Amount = 3,
			},
		},
		[17] = {
			PickaxeUpgrade = 15,
			OwnedCharacters = {
				Rarity = RarityEnum.Secret,
				Amount = 8,
			},
		},
		[18] = {
			PickaxeUpgrade = 15,
			OwnedCharacters = {
				Rarity = RarityEnum.Secret,
				Amount = 18,
			},
		},
		[19] = {
			PickaxeUpgrade = 10,
			OwnedCharacters = {
				Rarity = RarityEnum.Celestial,
				Amount = 1,
			},
		},
		[20] = {
			PickaxeUpgrade = 10,
			Character = "La Grande Combination",
		},
		[21] = {
			PickaxeUpgrade = 10,
			OwnedCharacters = {
				Rarity = RarityEnum.Celestial,
				Amount = 4,
			},
		},
		[22] = {
			PickaxeUpgrade = 10,
			OwnedCharacters = {
				Rarity = RarityEnum.Celestial,
				Amount = 7,
			},
		},
		[23] = {
			PickaxeUpgrade = 10,
			OwnedCharacters = {
				Rarity = RarityEnum.Celestial,
				Amount = 12,
			},
		},
		[24] = {
			PickaxeUpgrade = 10,
			OwnedCharacters = {
				Rarity = RarityEnum.Celestial,
				Amount = 20,
			},
		},
		[25] = {
			PickaxeUpgrade = 10,
			OwnedCharacters = {
				Rarity = RarityEnum.Celestial,
				Amount = 25,
			},
		},
	},
}

return table.freeze(RebirthConfig)
