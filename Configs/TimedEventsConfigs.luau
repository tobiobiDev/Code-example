--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TimedEventsConfigTypes = require(ReplicatedStorage.Source.Types.TimedEventsConfigTypes)

type InfernoSurgeConfigType = TimedEventsConfigTypes.InfernoSurgeConfigType
type UnstableCaveConfigType = TimedEventsConfigTypes.UnstableCaveConfigType

export type GlobalSettingsType = {
	EventResetInterval: number,
	EventDuration: number,
	SyncInterval: number,
	MemoryStoreDataExpiration: number,
}

export type TimedEventsConfigsType = {
	GlobalSettings: GlobalSettingsType,
	InfernoSurge: InfernoSurgeConfigType,
	UnstableCave: UnstableCaveConfigType,
}

local TimedEventsConfigs: TimedEventsConfigsType = {
	GlobalSettings = {
		EventResetInterval = 2400, -- 40 minutes between events
		EventDuration = 120, -- Default duration if not overridden
		SyncInterval = 10,
		MemoryStoreDataExpiration = 86400, -- 24 hours
	},

	InfernoSurge = {
		Messages = {
			First = "The cave begins to heat up…",
			Second = "The cave begins to rumble",
			Third = "INFERNO SURGE HAS STARTED!",
			Fourth = "The heat inside the cave intensifies.",
			Fifth = "The inferno surge fades…",
		},
		ClockTimes = {
			Event = 20.1,
			Normal = 14.5,
		},
		Durations = {
			Overall = 300, -- 5 minutes long
			Rumble = 5,
			Tween = 10,
		},
		DropSettings = {
			SpawnRate = 0.001,
			Speed = 20,
			IntensifyMultiplier = 2,
		},
		Audio = {
			BaseVolume = 0.3,
			BaseSpeed = 1,
			StartVolume = 0.8,
			IntensifyVolume = 1,
			IntensifySpeed = 1.2,
		},
	},

	UnstableCave = {
		Messages = {
			First = "The cave rumbles and begins to become unstable",
			Second = "Unstable Cave event has started!",
			Third = "The cave rumbles as it becomes more unstable",
			Fourth = "The cave heavily rumbles as it reaches it’s maximum instability",
			Fifth = "Cave stability returns back to normal...",
			Warning = "The cave begins to collapse in on itself.",
		},

		ClockTimes = {
			Event =  17.6,
			Normal = 14.5,
		},

		Lighting = {
			EventAmbient = Color3.fromRGB(108, 108, 108),
			NormalAmbient = Color3.fromRGB(170, 170, 170),
		},

		Durations = {
			Overall = 420, -- 7 minutes long
			ResetInterval = 60, -- How often it checks if it will reset in seconds
			ResetWarning = 30, -- How many seconds is there between warning and reset
			StartShake = 3,
			FirstIntesify = 3,
			SecondIntesify = 5,
			Tween = 10,
		},

		Effects = {
			ResetChance = 4, -- 1 in 4 base chance
			StrengthMultiplier = 2,
			FirstIntensifyMultiplier = 0.75,
			SecondIntensifyMultiplier = 0.5,
			StartShakeStrength = 3,
			FirstIntensifyShakeStrength = 5,
			SecondIntensifyShakeStrength = 8,
			MinimumShakeTime = 15,
			MaximumShakeTime = 20,
			RandomShakeDuration = 4,
			RandomShakeStrength = 3,
		},

		Audio = {
			StartSpeed = 1,
			StartVolume = 0.8,
		},
	},
}

return table.freeze(TimedEventsConfigs)
