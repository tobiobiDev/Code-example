--!strict
export type EventType = "Warning" | "FinalCountdown" | "Reset"

type EventsType = {
	{
		read offset: number, -- Seconds before reset
		read type: EventType,
	}
}

type CaveResetConfigs = {
	read RESET_INTERVAL: number,
	read CAVE_COLLAPSE_TIME: number,
	read RESET_EVENTS: EventsType,
}

local CaveResetConfigs: CaveResetConfigs = {
	RESET_INTERVAL = 1110, -- Time (s) between resetting the cave walls (18.5 minutes)
	CAVE_COLLAPSE_TIME = 5, -- Time when cave collapse effect starts before reset
	RESET_EVENTS = {
		{ offset = 300, type = "Warning" },
		{ offset = 60, type = "Warning" },
		{ offset = 30, type = "FinalCountdown" },
		{ offset = 0, type = "Reset" },
	},
}

return CaveResetConfigs
