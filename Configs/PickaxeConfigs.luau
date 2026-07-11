--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PickaxeNameEnum = require(ReplicatedStorage.Source.Enums.PickaxeNameEnum)

type ModelData = {
    Level: number,
    Name: PickaxeNameEnum.EnumType,
}
type StrengthData = {
    Level: number,
    AddedStrength: number,
}

local PickaxeConfigs = {
    DefaultMinimumStrength = 25,
    DefaultMinimumSpeed = 1,

    MaximumLevel = math.huge,
    MaximumStrength = math.huge,
    MaximumSpeed = 20,

    -- Mining Config Values
    BaseHitboxSize = 5, -- The default hitbox size, if strength is even
    MinHitboxSize = 2, -- Smallest total size allowable for detection and destruction hitbox
    MaxHitboxSize = 12, -- Largest X and Z size allowable for both detection and destruction hitbox
    ScaleModifier = 2, -- Designates how fast the hole grows per ratio tier
    BaseMinVoxelSize = 1, -- The smallest fragment size in cubic studs

    -- Model Thresholds
    ModelThresholds = {
        { Level = 0, Name = "Stone" },
		{ Level = 10, Name = "Copper" },
        { Level = 30, Name = "Bronze" },
        { Level = 50, Name = "Iron" },
		{ Level = 60, Name = "Silver" },
        { Level = 70, Name = "Steel" },
        { Level = 80, Name = "Gold" },
		{ Level = 100, Name = "Mithril" },
		{ Level = 130, Name = "Amethyst" },
        { Level = 150, Name = "Sapphire" },
        { Level = 170, Name = "Emerald" },
        { Level = 210, Name = "Ruby" },
        { Level = 230, Name = "Platinum" },
        { Level = 250, Name = "Obsidian" },
        { Level = 300, Name = "Onyx" },
		{ Level = 400, Name = "Demonite" },
        { Level = 450, Name = "Adamantite" },
        { Level = 750, Name = "Void" },
    } :: { ModelData },

    StrengthUpgradeThresholds = {
        { Level = 1, AddedStrength = 2 },
        { Level = 10, AddedStrength = 3 },
        { Level = 25, AddedStrength = 5 },
        { Level = 50, AddedStrength = 8 },
        { Level = 100, AddedStrength = 12 },
        { Level = 150, AddedStrength = 18 },
		{ Level = 200, AddedStrength = 25 },
		{ Level = 250, AddedStrength = 35 },
		{ Level = 300, AddedStrength = 50 },
    } :: { StrengthData },

    SpeedUpgradeIncreaseAmount = 0.1,
}

return table.freeze(PickaxeConfigs)
