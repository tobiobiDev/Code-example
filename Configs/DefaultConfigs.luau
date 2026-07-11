--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RarityEnum = require(ReplicatedStorage.Source.Enums.RarityEnum)

type DefaultConfigs = {
	-- DefaultPlayerData
    read CarryingCapacity: number,
    read WalkSpeed: number,

    -- CharacterShopSystem
    read ConfirmSellRarityThreshold: RarityEnum.EnumType,

    -- PickaxeUpgradeService
    read BulkUpgradeAmount: number,
    read BulkUpgradeDiscount: number,

    -- FriendBoostService
    read FriendBoostAmount: number,
}

--[[
    Stores various miscellaneous default values used throughout the experience
    that either don't fit into other configs, or are to singular to ve their own.
]]
local DefaultConfigs = {
    -- DefaultPlayerData
    CarryingCapacity = 1,
    WalkSpeed = 18,

    -- CharacterShopSystem
    ConfirmSellRarityThreshold = RarityEnum.Common, -- Above which rarity is confirm UI shown when selling

    -- PickaxeUpgradeService
    BulkUpgradeAmount = 10, -- Bulk upgrade increases upgrade level by this amount
    BulkUpgradeDiscount = 0.9, -- Bulk discount is for this cost (i.e., 0.9 = 10% discount, costs 90% normal price)

    -- FriendBoostService
    FriendBoostAmount = 10 -- in %
}

return DefaultConfigs
