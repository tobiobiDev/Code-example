--!strict
local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType =
	"Ballerina Capuccina"
	| "Bananita Dolfinita"
	| "Bluberini Octopussini"
	| "Bombardino Crocodilo"
	| "Boneca Ambalabu"
	| "Brr Brr Patapim"
	| "Bulliccinni Bananini"
	| "Burbaloni Luliloli"
	| "Cabrospaghetti Mistico"
	| "Cappuccino Assassino"
	| "Centralucci Nuclearucci"
	| "Chef Crabracadabra"
	| "Chimpanzini Bananini"
	| "Chimpanzini Cocosini"
	| "Crocodillo Ananasinno"
	| "Coccodrillo Formagioso"
	| "Cocosino Rhino"
	| "Elefantucci Bananucci"
	| "Frigo Camelo"
	| "garamaran"
	| "Giraffa Celestre"
	| "Glorbo Fruttodrillo"
	| "Il Cacto Hipopotamo"
	| "Karkerkar Kurkur"
	| "La Esok Sekola"
	| "La Grande Combination"
	| "Linguicine Serpentine"
	| "Lirili Larila"
	| "Los Tralaleritos"
	| "Noobini Appleini"
	| "Pakrahmatmamat"
	| "Perochello Lemonchello"
	| "Pipi Kiwi"
	| "Pot Hotspot"
	| "Spiuniro Golubiro"
	| "Ta Ta Ta Sahur"
	| "Tralalero Tralala"
	| "Tric Trac Baraboom"
	| "Trippi Troppi Troppa Trippa"
	| "Truliluru Tralaluno"
	| "Trulimero Trulichina"
	| "Tung Tung Sahur"
	| "Udin Din Din Dun"
	| "Unta Tobi Tob Tob"
	| "Melanini Pandanini"
	| "Bobritto Bandito"
	| "Madu dung dung"
	| "Ketupat Kuprat"
	| "Torrtuginni Dragonfrutinni"
	| "Zibra Zubra Zibralini"

local CharacterNameEnum: StrictEnum.FromUnion<EnumType> = {
	["Ballerina Capuccina"] = "Ballerina Capuccina",
	["Bananita Dolfinita"] = "Bananita Dolfinita",
	["Bluberini Octopussini"] = "Bluberini Octopussini",
	["Bombardino Crocodilo"] = "Bombardino Crocodilo",
	["Boneca Ambalabu"] = "Boneca Ambalabu",
	["Brr Brr Patapim"] = "Brr Brr Patapim",
	["Bulliccinni Bananini"] = "Bulliccinni Bananini",
	["Burbaloni Luliloli"] = "Burbaloni Luliloli",
	["Cabrospaghetti Mistico"] = "Cabrospaghetti Mistico",
	["Cappuccino Assassino"] = "Cappuccino Assassino",
	["Centralucci Nuclearucci"] = "Centralucci Nuclearucci",
	["Chef Crabracadabra"] = "Chef Crabracadabra",
	["Chimpanzini Bananini"] = "Chimpanzini Bananini",
	["Chimpanzini Cocosini"] = "Chimpanzini Cocosini",
	["Crocodillo Ananasinno"] = "Crocodillo Ananasinno",
	["Coccodrillo Formagioso"] = "Coccodrillo Formagioso",
	["Cocosino Rhino"] = "Cocosino Rhino",
	["Elefantucci Bananucci"] = "Elefantucci Bananucci",
	["Frigo Camelo"] = "Frigo Camelo",
	garamaran = "garamaran",
	["Giraffa Celestre"] = "Giraffa Celestre",
	["Glorbo Fruttodrillo"] = "Glorbo Fruttodrillo",
	["Il Cacto Hipopotamo"] = "Il Cacto Hipopotamo",
	["Karkerkar Kurkur"] = "Karkerkar Kurkur",
	["La Esok Sekola"] = "La Esok Sekola",
	["La Grande Combination"] = "La Grande Combination",
	["Linguicine Serpentine"] = "Linguicine Serpentine",
	["Lirili Larila"] = "Lirili Larila",
	["Los Tralaleritos"] = "Los Tralaleritos",
	["Noobini Appleini"] = "Noobini Appleini",
	Pakrahmatmamat = "Pakrahmatmamat",
	["Perochello Lemonchello"] = "Perochello Lemonchello",
	["Pipi Kiwi"] = "Pipi Kiwi",
	["Pot Hotspot"] = "Pot Hotspot",
	["Spiuniro Golubiro"] = "Spiuniro Golubiro",
	["Ta Ta Ta Sahur"] = "Ta Ta Ta Sahur",
	["Tralalero Tralala"] = "Tralalero Tralala",
	["Tric Trac Baraboom"] = "Tric Trac Baraboom",
	["Trippi Troppi Troppa Trippa"] = "Trippi Troppi Troppa Trippa",
	["Truliluru Tralaluno"] = "Truliluru Tralaluno",
	["Trulimero Trulichina"] = "Trulimero Trulichina",
	["Tung Tung Sahur"] = "Tung Tung Sahur",
	["Udin Din Din Dun"] = "Udin Din Din Dun",
	["Unta Tobi Tob Tob"] = "Unta Tobi Tob Tob",
	["Melanini Pandanini"] = "Melanini Pandanini",
	["Bobritto Bandito"] = "Bobritto Bandito",
	["Madu dung dung"] = "Madu dung dung",
	["Ketupat Kuprat"] = "Ketupat Kuprat",
	["Torrtuginni Dragonfrutinni"] = "Torrtuginni Dragonfrutinni",
	["Zibra Zubra Zibralini"] = "Zibra Zubra Zibralini",
}

return table.freeze(CharacterNameEnum)
