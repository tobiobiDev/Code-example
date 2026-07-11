--!strict

type ExplosivesConfig = {
    read MinHitboxSize: number,
    read MaxHitboxSize: number,
    read ScaleModifier: number,
    read BaseMinVoxelSize: number,
}

local ExplosivesConfig: ExplosivesConfig = {
    MinHitboxSize = 4, -- Smallest total size allowable for detection and destruction hitbox
    MaxHitboxSize = 24, -- Largest diameter size allowable for both detection and destruction hitbox
    ScaleModifier = 2, -- Designates how fast the hole grows per ratio tier
    BaseMinVoxelSize = 1, -- The smallest fragment size in cubic studs
}

return table.freeze(ExplosivesConfig)
