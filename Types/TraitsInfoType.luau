--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TraitsEnum = require(ReplicatedStorage.Source.Enums.TraitsEnum)
local applyTypeIndexer = require(ReplicatedStorage.Source.Utility.applyTypeIndexer)

type boostOptionsType = {
	CashBoost: number?,
	UpgradeDecrease: number?,
	SellValueIncrease: number?,
	MaxUpgradeIncrease: number?,
	BoostNearby: number?,
}?

type DecoratorOptionsType = {
	Color: Color3,
	Effect: string?,
}

type TraitEntry = {
	read Chance: number,
	read Boost: boostOptionsType,
	read Decorator: DecoratorOptionsType,
}

export type TraitType = applyTypeIndexer.apply<TraitsEnum.EnumType, TraitEntry>

return nil
