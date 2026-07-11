--!strict
local FloorService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Logger = require(ReplicatedStorage.Source.Utility.Logger)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

-- Tracks actively cloned floors per base: [base] = { [floorName] = clonedInstance }
local activeFloors: { [Model]: { [string]: Model } } = {}

local basesFolder = workspace:FindFirstChild("Bases") :: Folder
local floorPlaceholders = ServerStorage:FindFirstChild("FloorPlaceholders") :: Folder

local MAX_FLOORS = 3

function FloorService.getOwnedBase(player: Player): Model | nil
	for _, baseFolder in basesFolder:GetChildren() do
		if baseFolder:IsA("Model") and baseFolder:GetAttribute("Owner") == player.UserId then
			return baseFolder
		end
	end

	return nil
end

--[[
	Returns the CFrame anchor for a given floor inside a base.
	Expects a part named e.g. "Floor2Anchor" inside the base model.
]]
local function getFloorAnchor(assignedBase: Model, floorName: string): CFrame?
	local anchor = assignedBase:FindFirstChild(floorName .. "Anchor")
	if anchor and anchor:IsA("BasePart") then
		return anchor.CFrame
	end
	return nil
end

--[[
	Syncs base floor instances based on how many floors are unlocked.
	Floor1 is assumed to always exist directly in the base.
	Floor2 and Floor3 are cloned from ServerStorage.FloorPlaceholders when unlocked,
	and destroyed when locked.
]]
function FloorService.syncFloorsVisibility(assignedBase: Model, unlockedFloors: number)
	logger.log(`Syncing floors for {assignedBase.Name}, unlocked: {unlockedFloors}`)

	if not activeFloors[assignedBase] then
		activeFloors[assignedBase] = {}
	end

	local baseActiveFloors = activeFloors[assignedBase]

	for i = 2, MAX_FLOORS do
		local floorName = "Floor" .. i
		local shouldBeActive = i <= unlockedFloors

		if shouldBeActive then
			if baseActiveFloors[floorName] then
				continue
			end

			local placeholder = floorPlaceholders:FindFirstChild(floorName) :: Model
			if not placeholder then
				logger.log(`Placeholder for {floorName} not found in ServerStorage.FloorPlaceholders`)
				continue
			end

			logger.log(`Unlocking {floorName} — cloning placeholder`)

			local cloned = placeholder:Clone()
			cloned.Name = floorName
			cloned.Parent = assignedBase

			local anchor = getFloorAnchor(assignedBase, floorName)
			if anchor then
				cloned:PivotTo(anchor)
			end

			baseActiveFloors[floorName] = cloned
		else
			local existing = baseActiveFloors[floorName]
			if existing then
				logger.log(`Locking {floorName} — removing clone`)
				existing:Destroy()
				baseActiveFloors[floorName] = nil
			end
		end
	end
end

--[[
	Cleans up all tracked floors for a base (e.g. when a player leaves).
]]
function FloorService.cleanup(assignedBase: Model)
	local baseActiveFloors = activeFloors[assignedBase]
	if not baseActiveFloors then
		return
	end

	for floorName, floor in baseActiveFloors do
		logger.log(`Cleaning up {floorName} for {assignedBase.Name}`)
		floor:Destroy()
	end

	activeFloors[assignedBase] = nil
end

return FloorService
