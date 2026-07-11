--!strict

local Keybinds = {
	KeyboardStartMining = Enum.UserInputType.MouseButton1,
	GamepadStartMining = Enum.KeyCode.ButtonR2,
	KeyboardAttack = Enum.UserInputType.MouseButton1,
	GamepadAttack = Enum.KeyCode.ButtonR2,
	KeyboardToggleInventory = Enum.KeyCode.Backquote,
	GamepadToggleInventory = Enum.KeyCode.DPadUp,

	-- Gamepad Hotbar Bindings
	GamepadHotbarModifier = Enum.KeyCode.ButtonL2, -- When held, the below buttons activate
	GamepadHotbarSlot1 = Enum.KeyCode.ButtonA,
	GamepadHotbarSlot2 = Enum.KeyCode.ButtonX,
	GamepadHotbarSlot3 = Enum.KeyCode.ButtonY,
	GamepadHotbarSlot4 = Enum.KeyCode.ButtonB,
	GamepadHotbarSlot5 = Enum.KeyCode.ButtonR1,

	-- Item Placement Controls
	KeyboardPlaceItem = Enum.UserInputType.MouseButton1,
	GamepadPlaceItem = Enum.KeyCode.ButtonR2,
	KeyboardRotateLeft = Enum.KeyCode.Q,
	KeyboardRotateRight = Enum.KeyCode.E,
	GamepadRotateLeft = Enum.KeyCode.ButtonL1,
	GamepadRotateRight = Enum.KeyCode.ButtonR1,
	KeyboardExitPlacementMode = Enum.KeyCode.X,
	GamepadExitPlacementMode = Enum.KeyCode.ButtonB,
}

return Keybinds
