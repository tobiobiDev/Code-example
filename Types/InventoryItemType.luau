local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemIdEnum = require(ReplicatedStorage.Source.Enums.ItemIdEnum)
local MutationEnum = require(ReplicatedStorage.Source.Enums.MutationEnum)
local TraitsEnum = require(ReplicatedStorage.Source.Enums.TraitsEnum)

export type ITEM_TYPE = {
	ItemName: string,
	ItemType: "Pickaxe" | "Weapon" | "Character" | "Item",
	Model: Instance?,
	Rarity: number?,
	CashPerSecond: number?,
	Mutation: MutationEnum.EnumType?,
	MutationPriority: number?,
	Trait: TraitsEnum.EnumType?,
	Level: number?,
	IsMutated: boolean?,
	IsEquipped: boolean?,
	SortPriority: number?,
	CharacterId: string?,
	Quantity: number?,
	ItemId: ItemIdEnum.EnumType? -- Only used for Items
}


return nil
