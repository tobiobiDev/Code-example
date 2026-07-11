local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType = "Cash"

--[[
	Keys for currency types used to avoid typo-prone usage and as a container for
    the	various keys of currency types in one, easy to update and access place.
]]
local CurrencyEnum: StrictEnum.FromUnion<EnumType> = {
	Cash = "Cash",
}

return table.freeze(CurrencyEnum)
