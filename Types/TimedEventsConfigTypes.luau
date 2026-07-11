--!strict

export type InfernoSurgeConfigType = {
	read Messages: {
		read First: string,
		read Second: string,
		read Third: string,
		read Fourth: string,
		read Fifth: string,
	},

	read ClockTimes: {
		read Event: number,
		read Normal: number,
	},

	read Durations: {
		read Overall: number,
		read Rumble: number,
		read Tween: number,
	},

	read DropSettings: {
		read SpawnRate: number,
		read Speed: number,
		read IntensifyMultiplier: number,
	},

	read Audio: {
		read BaseVolume: number,
		read BaseSpeed: number,
		read StartVolume: number,
		read IntensifyVolume: number,
		read IntensifySpeed: number,
	},
}

export type UnstableCaveConfigType = {
	read Messages: {
		read First: string,
		read Second: string,
		read Third: string,
		read Fourth: string,
		read Fifth: string,
		read Warning: string,
	},

	read ClockTimes: {
		read Event: number,
		read Normal: number,
	},

	Lighting: {
		EventAmbient: Color3,
		NormalAmbient: Color3,
	},

	read Durations: {
		read Overall: number,
		read ResetInterval: number,
		read ResetWarning: number,
		read StartShake: number,
		read FirstIntesify: number,
		read SecondIntesify: number,
		read Tween: number,
	},

	read Effects: {
		read ResetChance: number,
		read StrengthMultiplier: number,
		read FirstIntensifyMultiplier: number,
		read SecondIntensifyMultiplier: number,
		StartShakeStrength: number,
		FirstIntensifyShakeStrength: number,
		SecondIntensifyShakeStrength: number,
		MinimumShakeTime: number,
		MaximumShakeTime: number,
		RandomShakeStrength: number,
		RandomShakeDuration: number,
	},

	read Audio: {
		read StartSpeed: number,
		read StartVolume: number,
	},
}

return nil
