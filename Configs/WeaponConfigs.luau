--!strict

type WeaponConfigs = {
    read DefaultSwingSpeedMultiplier: number,
    read DefaultReach: number,
    read DefaultKnockbackStrength: number,
    read DefaultRagdollDuration: number,
    read HitboxSize: Vector3,
    read AttackCooldown: number,
    read SamePlayerCooldown: number,
}

local WeaponConfigs: WeaponConfigs = {
    DefaultSwingSpeedMultiplier = 1,
    DefaultReach = 4,
    DefaultKnockbackStrength = 10,
    DefaultRagdollDuration = 2,
    HitboxSize = Vector3.new(4, 4, 0),
    AttackCooldown = 1,
    SamePlayerCooldown = 5, -- The time between hitting a player that needs to have passed before allowing them to hit the same player again
}

return WeaponConfigs
