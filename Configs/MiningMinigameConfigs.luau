--!strict

type Accuracy = "PERFECT" | "GOOD" | "OKAY" | "BAD"
type AccuracyColorsTable = {
    [Accuracy]: {
        Text: Color3,
        Stroke: Color3,
    }
}

type MiningMinigameConfigs = {
	-- Success thresholds (0.0 to 1.0, where 1.0 is the peak/target).
	read THRESHOLDS: {
		read PERFECT: number,
		read GOOD: number,
		read OKAY: number,
	},
	-- Damage scales/multipliers based on success tier.
	read SIZE_MULTIPLIERS: {
		read PERFECT: number,
		read GOOD: number,
		read OKAY: number,
		read BAD: number,
	},
	read ACCURACY_COLORS: AccuracyColorsTable,
	-- How long after submitting a mining result before a player can start another swing.
	read POST_MINING_COOLDOWN: number,
	-- Absolute minimum time the minigame takes to play out before a submit is possible.
	read MINIMUM_SUBMIT_TIME: number, -- e.g., MID_SWING_PAUSE_TIME + minimum cycle time to reach a threshold
	-- How many seconds for the for resulting accuracy text to tween from bottom to top.
	read RESULT_TWEEN_DURATION: number,
	-- How many seconds for the "strength too low" notification text to tween in.
	read TOO_LOW_TWEEN_DURATION: number,
	-- How many seconds for the "strength too low" notification to remain on screen before fading out.
	read TOO_LOW_DISPLAY_TIME: number,
	-- How many seconds the pickaxe takes to go from bottom to top and back.
	read MAX_CYCLE_DURATION: number,
	read MIN_CYCLE_DURATION: number,
	-- Curve strength applied to cycle duration by upgrading Speed attribute of pickaxe.
	-- Higher number = slow early progression, fater later; Lower number = fast early progression
	read CYCLE_EXPONENT: number,
	-- Maximum distance the pickaxe icon can travel in the UI (relative to Background size).
	read UI_MAX_ALPHA: number,
	-- How many seconds from starting the mining swing animation before pausing it for the minigame.
	read MID_SWING_PAUSE_TIME: number,
}

local MiningMinigameConfigs: MiningMinigameConfigs = {
	THRESHOLDS = {
		PERFECT = 0.95,
		GOOD = 0.82,
		OKAY = 0.6,
	},
	SIZE_MULTIPLIERS = {
		PERFECT = 1.5,
		GOOD = 1.0,
		OKAY = 0.75,
		BAD = 0.5,
	},
	ACCURACY_COLORS = {
		PERFECT = {
			Text = Color3.new(1, 0.835294, 0),
			Stroke = Color3.new(0, 0, 0)
		},
		GOOD = {
			Text = Color3.new(0, 1, 0.54902),
			Stroke = Color3.new(0, 0, 0)
		},
		OKAY = {
			Text = Color3.new(0.545098, 1, 0.772549),
			Stroke = Color3.new(0, 0, 0)
		},
		BAD = {
			Text = Color3.new(0.811765, 0.0196078, 0.0196078),
			Stroke = Color3.new(0.0588235, 0.0588235, 0.0588235)
		},
	},
	POST_MINING_COOLDOWN = 0.3,
	MINIMUM_SUBMIT_TIME = 0.2,
	RESULT_TWEEN_DURATION = 1,
	TOO_LOW_TWEEN_DURATION = 0.5,
	TOO_LOW_DISPLAY_TIME = 2,
	MAX_CYCLE_DURATION = 2,
	CYCLE_EXPONENT = 2.2,
	UI_MAX_ALPHA = 1,
	MID_SWING_PAUSE_TIME = 0.4,
	MIN_CYCLE_DURATION = 0.7,
}

return MiningMinigameConfigs
