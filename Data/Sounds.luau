--!strict
local SoundService = game:GetService("SoundService")

local miscFolder = assert(SoundService:WaitForChild("Misc", 10), "Failed to find 'Misc' folder in SoundService")
local miningSounds = assert(SoundService:WaitForChild("MiningSounds", 10), "Failed to find 'MiningSounds' folder in SoundService")

-- this should tecnically all be handled in ReplicatedFirst
local Sounds: { [string]: Sound } = {
	Fail = miscFolder:WaitForChild("PurchaseUnsuccessful") :: Sound,
	Success = miscFolder:WaitForChild("UpgradeSuccessful") :: Sound,
	CelestialSpawn = miscFolder:WaitForChild("CelestialSpawn") :: Sound,
	Rebirth = miscFolder:WaitForChild("RebirthSound") :: Sound,
	CashEarned = miscFolder:WaitForChild("CashEarning") :: Sound,
	BrainrotCollected = miscFolder:WaitForChild("BrainrotCollected") :: Sound,
	PickaxeHit = miningSounds:WaitForChild("PickaxeHit") :: Sound,
	OreBreak = miningSounds:WaitForChild("OreBreak") :: Sound,
	DialogueText = SoundService:WaitForChild("DialogueText") :: Sound,
}

return Sounds
