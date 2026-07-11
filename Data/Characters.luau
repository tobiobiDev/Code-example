--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterInfoType = require(ReplicatedStorage.Source.Types.CharacterInfoType)

local Characters: CharacterInfoType.CharacterInfo = {
	["Noobini Appleini"] = {
		Rarity = "Common",
		SpawnChance = 30,
		CashPerSecond = 5,
	},
	["Burbaloni Luliloli"] = {
		Rarity = "Common",
		SpawnChance = 25,
		CashPerSecond = 6,
	},
	["Tung Tung Sahur"] = {
		Rarity = "Common",
		SpawnChance = 20,
		CashPerSecond = 7,
	},
	["Trippi Troppi Troppa Trippa"] = {
		Rarity = "Common",
		SpawnChance = 15,
		CashPerSecond = 9,
	},
	["Trulimero Trulichina"] = {
		Rarity = "Common",
		SpawnChance = 10,
		CashPerSecond = 12,
	},

	["Boneca Ambalabu"] = {
		Rarity = "Uncommon",
		SpawnChance = 30,
		CashPerSecond = 38,
	},
	["Frigo Camelo"] = {
		Rarity = "Uncommon",
		SpawnChance = 25,
		CashPerSecond = 44,
	},
	["Lirili Larila"] = {
		Rarity = "Uncommon",
		SpawnChance = 20,
		CashPerSecond = 53,
	},
	["Il Cacto Hipopotamo"] = {
		Rarity = "Uncommon",
		SpawnChance = 15,
		CashPerSecond = 67,
	},
	["Unta Tobi Tob Tob"] = {
		Rarity = "Uncommon",
		SpawnChance = 10,
		CashPerSecond = 94,
	},
	["Pipi Kiwi"] = {
		Rarity = "Rare",
		SpawnChance = 35,
		CashPerSecond = 281,
	},

	["Bananita Dolfinita"] = {
		Rarity = "Rare",
		SpawnChance = 25,
		CashPerSecond = 347,
	},

	["Zibra Zubra Zibralini"] = {
		Rarity = "Rare",
		SpawnChance = 18,
		CashPerSecond = 425,
	},

	["Linguicine Serpentine"] = {
		Rarity = "Rare",
		SpawnChance = 14,
		CashPerSecond = 497,
	},

	["Crocodillo Ananasinno"] = {
		Rarity = "Rare",
		SpawnChance = 8,
		CashPerSecond = 703,
	},

	["Spiuniro Golubiro"] = {
		Rarity = "Epic",
		SpawnChance = 25,
		CashPerSecond = 2_110,
	},
	["Ballerina Capuccina"] = {
		Rarity = "Epic",
		SpawnChance = 22,
		CashPerSecond = 2_520,
	},
	["Ta Ta Ta Sahur"] = {
		Rarity = "Epic",
		SpawnChance = 18,
		CashPerSecond = 2_900,
	},
	["Glorbo Fruttodrillo"] = {
		Rarity = "Epic",
		SpawnChance = 15,
		CashPerSecond = 3_180,
	},
	["Melanini Pandanini"] = {
		Rarity = "Epic",
		SpawnChance = 12,
		CashPerSecond = 3_810,
	},
	["Bluberini Octopussini"] = {
		Rarity = "Epic",
		SpawnChance = 8,
		CashPerSecond = 5_270,
	},

	["Chimpanzini Cocosini"] = {
		Rarity = "Legendary",
		SpawnChance = 35,
		CashPerSecond = 15_800,
	},
	["Bulliccinni Bananini"] = {
		Rarity = "Legendary",
		SpawnChance = 25,
		CashPerSecond = 19_500,
	},
	["Cocosino Rhino"] = {
		Rarity = "Legendary",
		SpawnChance = 20,
		CashPerSecond = 22_400,
	},
	["Cappuccino Assassino"] = {
		Rarity = "Legendary",
		SpawnChance = 12,
		CashPerSecond = 30_700,
	},
	["Cabrospaghetti Mistico"] = {
		Rarity = "Legendary",
		SpawnChance = 8,
		CashPerSecond = 39_600,
	},

	["Elefantucci Bananucci"] = {
		Rarity = "Mythical",
		SpawnChance = 40,
		CashPerSecond = 120_000,
	},
	["Chimpanzini Bananini"] = {
		Rarity = "Mythical",
		SpawnChance = 27,
		CashPerSecond = 160_000,
	},
	["Bombardino Crocodilo"] = {
		Rarity = "Mythical",
		SpawnChance = 15,
		CashPerSecond = 190_000,
	},
	["Coccodrillo Formagioso"] = {
		Rarity = "Mythical",
		SpawnChance = 10,
		CashPerSecond = 225_000,
	},
	["Bobritto Bandito"] = {
		Rarity = "Mythical",
		SpawnChance = 5,
		CashPerSecond = 251_000,
	},
	["Giraffa Celestre"] = {
		Rarity = "Mythical",
		SpawnChance = 3,
		CashPerSecond = 300_000,
	},

	["Brr Brr Patapim"] = {
		Rarity = "Divine",
		SpawnChance = 32,
		CashPerSecond = 890_000,
	},
	["garamaran"] = {
		Rarity = "Divine",
		SpawnChance = 24,
		CashPerSecond = 1_000_000,
	},
	["Tric Trac Baraboom"] = {
		Rarity = "Divine",
		SpawnChance = 18,
		CashPerSecond = 1_200_000,
	},
	["Madu dung dung"] = {
		Rarity = "Divine",
		SpawnChance = 13,
		CashPerSecond = 1_400_000,
	},
	["Udin Din Din Dun"] = {
		Rarity = "Divine",
		SpawnChance = 8,
		CashPerSecond = 1_760_000,
	},
	["Perochello Lemonchello"] = {
		Rarity = "Divine",
		SpawnChance = 5,
		CashPerSecond = 2_220_000,
	},

	["Centralucci Nuclearucci"] = {
		Rarity = "Secret",
		SpawnChance = 33,
		CashPerSecond = 6_600_000,
	},
	["Tralalero Tralala"] = {
		Rarity = "Secret",
		SpawnChance = 25,
		CashPerSecond = 7_500_000,
	},
	["Pakrahmatmamat"] = {
		Rarity = "Secret",
		SpawnChance = 18,
		CashPerSecond = 8_680_000,
	},
	["La Esok Sekola"] = {
		Rarity = "Secret",
		SpawnChance = 12,
		CashPerSecond = 10_400_000,
	},
	["Karkerkar Kurkur"] = {
		Rarity = "Secret",
		SpawnChance = 8,
		CashPerSecond = 13_000_000,
	},
	["Chef Crabracadabra"] = {
		Rarity = "Secret",
		SpawnChance = 4,
		CashPerSecond = 16_700_000,
	},

	["Truliluru Tralaluno"] = {
		Rarity = "Celestial",
		SpawnChance = 35,
		CashPerSecond = 45_500_000,
	},
	["La Grande Combination"] = {
		Rarity = "Celestial",
		SpawnChance = 25,
		CashPerSecond = 57_000_000,
	},
	["Los Tralaleritos"] = {
		Rarity = "Celestial",
		SpawnChance = 18,
		CashPerSecond = 64_100_000,
	},
	["Torrtuginni Dragonfrutinni"] = {
		Rarity = "Celestial",
		SpawnChance = 12,
		CashPerSecond = 74_600_000,
	},
	["Ketupat Kuprat"] = {
		Rarity = "Celestial",
		SpawnChance = 7,
		CashPerSecond = 91_200_000,
	},
	["Pot Hotspot"] = {
		Rarity = "Celestial",
		SpawnChance = 3,
		CashPerSecond = 125_000_000,
	},
}

return table.freeze(Characters)
