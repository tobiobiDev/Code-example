--!strict

type GamepadType = "Xbox" | "Playstation"

local GamepadIcons: { [GamepadType]: { [Enum.KeyCode]: string } } = {
	Xbox = {
		[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA@2x.png",
		[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB@2x.png",
		[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX@2x.png",
		[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY@2x.png",
		[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLB@2x.png",
		[Enum.KeyCode.ButtonL2] = "rbxasset://textures/ui/Controls/xboxLT@2x.png",
		[Enum.KeyCode.ButtonL3] = "rbxasset://textures/ui/Controls/xboxLS@2x.png",
		[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRB@2x.png",
		[Enum.KeyCode.ButtonR2] = "rbxasset://textures/ui/Controls/xboxRT@2x.png",
		[Enum.KeyCode.ButtonR3] = "rbxasset://textures/ui/Controls/xboxRS@2x.png",
		[Enum.KeyCode.ButtonStart] = "rbxasset://textures/ui/Controls/xboxmenu@2x.png",
		[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxView@2x.png",
	},

	Playstation = {
		[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonCross@2x.png",
		[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonCircle@2x.png",
		[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonSquare@2x.png",
		[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonTriangle@2x.png",
		[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonL1@2x.png",
		[Enum.KeyCode.ButtonL2] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonL2@2x.png",
		[Enum.KeyCode.ButtonL3] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonL3@2x.png",
		[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonR1@2x.png",
		[Enum.KeyCode.ButtonR2] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonR2@2x.png",
		[Enum.KeyCode.ButtonR3] = "rbxasset://textures/ui/Controls/PlayStationController/ButtonR3@2x.png",
		[Enum.KeyCode.ButtonStart] = "rbxasset://textures/ui/Controls/PlayStationController/PS5/ButtonOptions@2x.png",
		[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/PlayStationController/PS5/ButtonTouchpad@2x.png",
		[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/PlayStationController/PS5/ButtonShare@2x.png",
	}
}

return GamepadIcons
