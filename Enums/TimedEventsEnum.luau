local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType = "None" | "Inferno Surge" | "Unstable Cave"

local TimedEventEnum: StrictEnum.FromUnion<EnumType> = {
	["None"] = "None",
	["Inferno Surge"] = "Inferno Surge",
	["Unstable Cave"] = "Unstable Cave",
}

return table.freeze(TimedEventEnum)
