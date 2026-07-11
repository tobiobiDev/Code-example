local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TimedEventsEnum = require(ReplicatedStorage.Source.Enums.TimedEventsEnum)

type EventDataType = {
	[TimedEventsEnum.EnumType]: {
		Chance: number,
	},
}

local EventData: EventDataType = {
	["Inferno Surge"] = {
		Chance = 10,
	},
	["Unstable Cave"] = {
		Chance = 90,
	},
}

return table.freeze(EventData)
