--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemCategoryEnum = require(ReplicatedStorage.Source.Enums.ItemCategoryEnum)
local ItemIdEnum = require(ReplicatedStorage.Source.Enums.ItemIdEnum)
local ItemTagEnum = require(ReplicatedStorage.Source.Enums.ItemTagEnum)
local DeploymentType = require(script.Parent.DeploymentType)

export type ItemInfoType = {
	read ItemId: ItemIdEnum.EnumType,
	-- This is useful in case we change names in the future but still use the same Ids.
	-- Prevents breaking player data in that case.
	read DisplayName: string,
	-- Used for hover text or other usage of descriptions.
	read Description: string,

	-- Price in the shop.
	read Cost: number,
	-- Number of rebirths required to have to unlock ability to purchase/use.
	read RebirthRequirement: number,

	-- Useful if the item is sold in batches, or bundles.
	read PurchaseQuantity: number?, -- Defaults to `1`

	-- The reference to the Tool or Model asset of the item in `ReplicatedStorage.Assets` (i.e., "Models/Scaffolding")
	read AssetPath: string,

	-- Most items should not stack inifinitely, can be set to `1` for single-owned items.
	read MaxStack: number?, -- Defaults to `1`
	-- Distinguishes persistent utility items from expendables.
	read UsageType: "Consumable" | "Persistent" | "Durability",
	-- Used for Durability Usagetype items.
	read Health: number?,
	-- Used for Consumable UsageType items that should expire after this period of time has passed.
	read ExpirationTime: number?, -- Defaults to 60 (s)
	-- Used for Explosives and determines the baseline strength of wall it deals damage to.
	read ExplosivePower: number?, -- Will have a randomized amoutn reduced/added during explosion.

	-- Useful for possible future shop tabs, inventory grouping, analytics, restrictions, etc.
	read ItemCategory: ItemCategoryEnum.EnumType,

	-- What deployment logic to use for the item (if any), e.g., GridPlacement, SurfacePlacement, Throwable, etc.
	read DeploymentType: DeploymentType.DeploymentType?,

	-- Useful if we want deterministic ordering independent of price or rebirth requirement.
	read UnlockOrder: number?,
	-- This avoids hardcoded exclusion lists for items we don't want visible all the time, such as admin/event items.
	read ShopVisible: boolean?, -- Deafults to `true`

	-- Lets us disable broken/problematic items without deleting configs.
	read Enabled: boolean?, -- Defaults to `true`

	-- Optional tags for capability checks without inheritance chains
	-- (i.e., `if Item:HasTag("Placeable") then` or `if table.find(itemInfo.Tags, "Explosive") then`)
	read Tags: { ItemTagEnum.EnumType }?,
}

return nil
