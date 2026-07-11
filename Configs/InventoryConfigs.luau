--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MutationEnum = require(ReplicatedStorage.Source.Enums.MutationEnum)
local RarityEnum = require(ReplicatedStorage.Source.Enums.RarityEnum)

local InventoryConfig = {
	MAX_INVENTORY_CAPACITY = 102, -- Starting number of characters a player cna store in inventory + Pickaxe + PVP Weapon
	HOTBAR_CAPACITY = 5,
	KEYBINDS = { 1, 2, 3, 4, 5 },

	OPEN_BTN_CLOSED_YPOS = 0.825,
	OPEN_BTN_OPENED_YPOS = 0.275,
	KEYBOARD_BUTTON_ICON = "rbxasset://textures/ui/Controls/key_single@3x.png",
	GAMEPAD_BUTTON_ICON = "rbxasset://textures/ui/Controls/dpadUp@3x.png",

	RARITY_MAP = {
		[RarityEnum.Common] = 1,
		[RarityEnum.Uncommon] = 2,
		[RarityEnum.Rare] = 3,
		[RarityEnum.Epic] = 4,
		[RarityEnum.Legendary] = 5,
		[RarityEnum.Mythical] = 6,
		[RarityEnum.Divine] = 7,
		[RarityEnum.Secret] = 8,
		[RarityEnum.Celestial] = 9,
	},

	CLIENT_RARITY_MAP = {
		RarityEnum.Common,
		RarityEnum.Uncommon,
		RarityEnum.Rare,
		RarityEnum.Epic,
		RarityEnum.Legendary,
		RarityEnum.Mythical,
		RarityEnum.Divine,
		RarityEnum.Secret,
		RarityEnum.Celestial,
	},

	MUTATION_MAP = {
		[MutationEnum.Normal] = 0,
		[MutationEnum.Gold] = 1,
		[MutationEnum.Diamond] = 2,
		[MutationEnum.Ruby] = 3,
		[MutationEnum.Blaze] = 4,
	},

	-- Backpack Inventory Visual Settings
	BP_CELL_PADDING = UDim2.fromScale(0.018, 0.04),
	BP_CELL_SIZE = UDim2.fromScale(0.182, 0.375),
	BP_FILL_DIRECTION_MAX_CELLS = 5,

	-- Hotbar Inventory Visual Settings
	HB_CELL_SIZE = UDim2.fromScale(0.19, 1),
	HB_CELL_PADDING = UDim2.fromScale(0.01, 0),
	HB_FILL_DIRECTION_MAX_CELLS = 5, -- Pickaxe, PvP Weapon, and 3 characters

	-- Equipped Slot Visual Settings
	EQUIPPED_SLOT_BG_COLOR = Color3.fromRGB(39, 80, 131),
	EQUIPPED_VIEWPORT_BG_COLOR = Color3.fromRGB(39, 80, 131),
	EQUIPPED_SLOT_STROKE_COLOR = Color3.fromRGB(0, 23, 230),
	EQUIPPED_SLOT_KEYBIND_TEXT_COLOR = Color3.fromRGB(255, 170, 0),

	DEFAULT_SLOT_BG_COLOR = Color3.fromRGB(15, 31, 51),
	DEFAULT_VIEWPORT_BG_COLOR = Color3.fromRGB(15, 31, 51),
	DEFAULT_SLOT_STROKE_COLOR = Color3.fromRGB(0, 2, 20),
	DEFAULT_SLOT_KEYBIND_TEXT_COLOR = Color3.fromRGB(255, 255, 255),

	CHARACTER_VIEWPORT_OFFSET = CFrame.Angles(0, 90, 0), -- Facing direction of the character
}

return InventoryConfig
