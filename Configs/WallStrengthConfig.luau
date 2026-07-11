--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RarityEnum = require(ReplicatedStorage.Source.Enums.RarityEnum)

type WallStrengthMap = { [RarityEnum.WallEnumType]: number}
type Config = WallStrengthMap & {
	read CommonWall: number,
	read UncommonWall: number,
	read RareWall: number,
	read EpicWall: number,
	read LegendaryWall: number,
	read MythicalWall: number,
	read DivineWall: number,
	read SecretWall: number,
	read CelestialWall: number,
}

local WallStrengthConfig: Config = {
	CommonWall = 20,
	UncommonWall = 45,
	RareWall = 118,
	EpicWall = 221,
	LegendaryWall = 381,
	MythicalWall = 625,
    DivineWall = 985,
    SecretWall = 1_590,
    CelestialWall = 2_345,
}

return table.freeze(WallStrengthConfig)
