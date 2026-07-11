local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterNameEnum = require(ReplicatedStorage.Source.Enums.CharacterNameEnum)

type randomBrainrot = {
	LootDrop: { [CharacterNameEnum.EnumType]: number },
	CycleTable: { CharacterNameEnum.EnumType },
}

local RandomBrainrot: randomBrainrot = {
	LootDrop = {
		--COMMON (~22%)
		["Noobini Appleini"] = 5.5,
		["Burbaloni Luliloli"] = 5,
		["Tung Tung Sahur"] = 4.5,
		["Trippi Troppi Troppa Trippa"] = 4,
		["Trulimero Trulichina"] = 3,

		--UNCOMMON (~20%)
		["Boneca Ambalabu"] = 5,
		["Frigo Camelo"] = 4.5,
		["Lirili Larila"] = 4,
		["Il Cacto Hipopotamo"] = 3.5,
		["Unta Tobi Tob Tob"] = 3,

		--RARE (~18%)
		["Pipi Kiwi"] = 5,
		["Bananita Dolfinita"] = 4,
		["Zibra Zubra Zibralini"] = 3.5,
		["Linguicine Serpentine"] = 3,
		["Crocodillo Ananasinno"] = 2.5,

		--EPIC (~16%)
		["Spiuniro Golubiro"] = 3.2,
		["Ballerina Capuccina"] = 3,
		["Ta Ta Ta Sahur"] = 2.8,
		["Glorbo Fruttodrillo"] = 2.5,
		["Melanini Pandanini"] = 2.3,
		["Bluberini Octopussini"] = 2.2,

		--LEGENDARY (~10%)
		["Chimpanzini Cocosini"] = 2.5,
		["Bulliccinni Bananini"] = 2,
		["Cocosino Rhino"] = 2,
		["Cappuccino Assassino"] = 1.8,
		["Cabrospaghetti Mistico"] = 1.7,

		--MYTHICAL (~8%)
		["Elefantucci Bananucci"] = 1.8,
		["Chimpanzini Bananini"] = 1.5,
		["Bombardino Crocodilo"] = 1.4,
		["Coccodrillo Formagioso"] = 1.2,
		["Bobritto Bandito"] = 1.1,
		["Giraffa Celestre"] = 1,

		--DIVINE (~4%)
		["Brr Brr Patapim"] = 1,
		["garamaran"] = 0.8,
		["Tric Trac Baraboom"] = 0.7,
		["Madu dung dung"] = 0.6,
		["Udin Din Din Dun"] = 0.5,
		["Perochello Lemonchello"] = 0.4,

		--SECRET (~1.5%)
		["Centralucci Nuclearucci"] = 0.4,
		["Tralalero Tralala"] = 0.3,
		["Pakrahmatmamat"] = 0.25,
		["La Esok Sekola"] = 0.2,
		["Karkerkar Kurkur"] = 0.2,
		["Chef Crabracadabra"] = 0.15,

		--CELESTIAL (~0.5%)
		["Truliluru Tralaluno"] = 0.12,
		["La Grande Combination"] = 0.10,
		["Los Tralaleritos"] = 0.09,
		["Torrtuginni Dragonfrutinni"] = 0.08,
		["Ketupat Kuprat"] = 0.06,
		["Pot Hotspot"] = 0.05,
	},
	CycleTable = {
		"La Esok Sekola",
		"Pakrahmatmamat",
		"La Grande Combination",
		"Ketupat Kuprat",
		"Torrtuginni Dragonfrutinni"
	},
}

return RandomBrainrot
