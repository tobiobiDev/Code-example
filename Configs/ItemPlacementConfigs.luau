--!strict

type ItemPlacementConfig = {
	read GRID_SIZE: number, -- The overall grid size to snap to (should ideally match up with item sizes)
	read MAX_DISTANCE: number, -- Moximum distance from the player an item may be placed
	read ROTATION_INCREMENT: number, -- The angle to snap rotation to
	read PREVIEW_COLOR: Color3,
	read PREVIEW_OVERLAP_COLOR: Color3,
}

local ItemPlacementConfigs: ItemPlacementConfig = {
	GRID_SIZE = 2,
	MAX_DISTANCE = 25,
	ROTATION_INCREMENT = 90,
	PREVIEW_COLOR = Color3.fromRGB(0, 110, 255),
	PREVIEW_OVERLAP_COLOR = Color3.new(1, 0, 0),
}

return ItemPlacementConfigs
