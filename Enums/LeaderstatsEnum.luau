local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType = "Cash" | "CashPerSecond"

local LeaderstatsEnum: StrictEnum.FromUnion<EnumType> = {
	Cash = "Cash",
	CashPerSecond = "CashPerSecond",
}

return table.freeze(LeaderstatsEnum)
