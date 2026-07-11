--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponInfoType = require(ReplicatedStorage.Source.Types.WeaponInfoType)
local WeaponNameEnum = require(ReplicatedStorage.Source.Enums.WeaponNameEnum)

local Weapons: { [WeaponNameEnum.EnumType]: WeaponInfoType.WeaponInfo } = {
    Bat = {
        Reach = 4,
        KnockbackStrength = 20,
        RagdollDuration = 2,
        SwingSpeedMultiplier = 1,
		Quality = 1,
    },
	MetalBat = {
		Reach = 4,
		KnockbackStrength = 25,
		RagdollDuration = 2,
		SwingSpeedMultiplier = 1,
		Quality = 2,

	},
	GoldenBat = {
		Reach = 4,
		KnockbackStrength = 28,
		RagdollDuration = 2.5,
		SwingSpeedMultiplier = 1,
		Quality = 3,

	},
	RubyBat = {
		Reach = 4.5,
		KnockbackStrength = 33,
		RagdollDuration = 3,
		SwingSpeedMultiplier = 1,
		Quality = 4,
	},
}

return table.freeze(Weapons)
