--!strict

type UI_Configs = {
	-- NotificationsSystem
	read MAX_MESSAGES: number,
	read DISPLAY_TIME: number,
	read TYPING_SPEED: number,
    read SOURCE_COOLDOWN: number,

	-- Dialogue
	read DEFAULT_INTERACTION_DISTANCE: number,
	read DISTANCE_TOLERANCE: number,

	-- Touch Device Button Icons
	read TouchMiningButtonEmoji: string,
	read TouchAttackButtonEmoji: string,
}

local UI_Configs: UI_Configs = {
	-- NotificationsSystem
	MAX_MESSAGES = 3, -- Max messages on screen
	DISPLAY_TIME = 3, -- Seconds each notification stays up
	TYPING_SPEED = 0.03, -- Seconds between each character
	SOURCE_COOLDOWN = 2, -- Seconds between notification of same source

	-- Dialogue
	DEFAULT_INTERACTION_DISTANCE = 25,
	DISTANCE_TOLERANCE = 10, -- How far past activation distance can the player move before exiting conversation

	-- Touch Device Button Icons
	TouchMiningButtonEmoji = "⛏️",
	TouchAttackButtonEmoji = "⚔️",
}

return UI_Configs
