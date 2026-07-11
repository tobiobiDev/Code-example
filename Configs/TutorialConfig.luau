--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TutorialStageNameEnum = require(ReplicatedStorage.Source.Enums.TutorialStageNameEnum)

export type StageName = TutorialStageNameEnum.EnumType

type ConfigType = {
	StageOrder: { StageName },
	TotalStages: number,
	TutorialAreaCompletionStage: number,
	NotificationTextTypewritingSpeed: number,
	StageGuidanceDuration: number,
	ArrowPadding: number,
	ArrowBobOffset: number,
	ArrowBobSpeed: number,
	ArrowDiagonalThreshold: number,
}

local STAGE_ORDER: { StageName } = {
	"InitiateTutorial",
	"LeaveCave",
	"PlaceCharacter",
	"CollectCash",
	"UpgradeCharacter",
	"CollectCashForPickaxeUpgrade",
	"UpgradePickaxe",
	"GetPickaxeUpgradesForRebirth",
	"Rebirth",
}

local TutorialConfig: ConfigType = {
	StageOrder = STAGE_ORDER,
	TotalStages = #STAGE_ORDER,
	TutorialAreaCompletionStage = table.find(STAGE_ORDER :: { string }, "CollectCash") :: number,
	NotificationTextTypewritingSpeed = 0.025, -- The time between the typewriting effect printing each letter
	StageGuidanceDuration = 10, -- The time (s) to continue displaying the current stage's visuals
	
	ArrowPadding = 30, -- Padding distance between the Gui Arrow and the object it's pointing to
	ArrowBobOffset = 20, -- Distance the arrow will bounce back and forth
	ArrowBobSpeed = 0.6, -- Speeed at which the arrow tweens from one side ot the other
	ArrowDiagonalThreshold = 50, -- If the objects is within this distance from the corner, it's determined to be "in the corner"
}

return table.freeze(TutorialConfig)

