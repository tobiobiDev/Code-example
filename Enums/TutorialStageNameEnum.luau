--!strict

local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType =
	"InitiateTutorial"
	| "LeaveCave"
	| "PlaceCharacter"
	| "CollectCash"
	| "UpgradeCharacter"
	| "CollectCashForPickaxeUpgrade"
	| "UpgradePickaxe"
	| "GetPickaxeUpgradesForRebirth"
	| "Rebirth"

local TutorialStageNameEnum: StrictEnum.FromUnion<EnumType> = {
	InitiateTutorial = "InitiateTutorial",
	LeaveCave = "LeaveCave",
	PlaceCharacter = "PlaceCharacter",
	CollectCash = "CollectCash",
	UpgradeCharacter = "UpgradeCharacter",
	CollectCashForPickaxeUpgrade = "CollectCashForPickaxeUpgrade",
	UpgradePickaxe = "UpgradePickaxe",
	GetPickaxeUpgradesForRebirth = "GetPickaxeUpgradesForRebirth",
	Rebirth = "Rebirth",
}

return TutorialStageNameEnum
