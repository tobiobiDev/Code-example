--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RarityEnum = require(ReplicatedStorage.Source.Enums.RarityEnum)

type RarityConfigTable = { [RarityEnum.EnumType]: Color3 }

local RarityColorConfigs: RarityConfigTable = {
	Common = Color3.fromRGB(175, 175, 175),
	Uncommon = Color3.fromRGB(50, 180, 43),
	Rare = Color3.fromRGB(13, 149, 212),
	Epic = Color3.fromRGB(149, 0, 255),
	Legendary = Color3.fromRGB(243, 142, 0),
	Mythical = Color3.fromRGB(244, 0, 53),
	Divine = Color3.fromRGB(5, 209, 232),
	Secret = Color3.fromRGB(38, 59, 74),
	Celestial = Color3.fromRGB(234, 0, 255)
}

return RarityColorConfigs
