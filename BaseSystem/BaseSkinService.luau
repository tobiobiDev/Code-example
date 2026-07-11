--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local MutationEnum = require(ReplicatedStorage.Source.Enums.MutationEnum)
local MutationsConfig = require(ReplicatedStorage.Source.Configs.MutationsConfig)
local PlayerDataService = require(ServerScriptService.Source.PlayerData.PlayerDataService)
local tryGetPlayerProfile = require(ServerScriptService.Source.PlayerData.tryGetPlayerProfile)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

local BaseSkinService = {}

local basesFolder = assert(workspace:FindFirstChild("Bases"), "Workspace is missing 'Bases' folder")

local function getBaseSkin(player: Player): MutationEnum.EnumType?
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return nil
	end
	local sortedChances: { { Name: string, Weight: number } } = {}

	for name, weight in MutationsConfig.SkinCashBoost :: { [string]: number } do
		table.insert(sortedChances, { Name = name, Weight = weight })
	end

	table.sort(sortedChances, function(a: { Name: string, Weight: number }, b: { Name: string, Weight: number })
		return a.Weight > b.Weight
	end)

	for _, info in sortedChances do
		if table.find(profile.BaseSkins, info.Name) then
			local infoName = info.Name :: MutationEnum.EnumType
			return infoName
		end
	end

	return nil
end

function BaseSkinService.GetBaseSkin(
	player: Player,
	playerBase: number | Model,
	baseInfo: any,
	mutation: MutationEnum.EnumType?
): MutationEnum.EnumType?
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return nil
	end

	if not playerBase then
		return nil
	end

	local mutationName = mutation or getBaseSkin(player)
	if mutationName then
		logger.log(`{player.Name} has {mutationName} Base skin`)
	else
		logger.log(`{player.Name} doesn't have any base skins unlocked`)
		return nil
	end

	if baseInfo and baseInfo.Skin == mutationName then
		logger.log(`{player.Name} already has {mutationName} skin equipped`, true)
		return nil
	end

	local baseFolder = if type(playerBase) == "number"
		then basesFolder:FindFirstChild(`Base{playerBase}`)
		else playerBase

	if not baseFolder then
		logger.log(`{player.Name} doesn't own any base`, true)
		return nil
	end

	local unlockedFloors = profile.BaseInfo.UnlockedFloors or 1
	local mutationColors = MutationsConfig.BaseColors[mutationName :: MutationsConfig.BaseColor]

	if not mutationColors then
		logger.log(`No base colors table in MutationsConfig found for {mutationName}`)
		return nil
	end

	for i = 1, unlockedFloors do
		local floorName = "Floor" .. i
		local floorFolder = baseFolder:FindFirstChild(floorName)

		if not floorFolder then
			logger.log(`No floor folder found for floor number {i}`)
			continue
		end

		for _, skinFolder in floorFolder:GetChildren() do
			for _, descendant in skinFolder:GetDescendants() do
				local isCurrentSkin = (skinFolder.Name == mutationName)

				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = isCurrentSkin
					continue
				end

				if not descendant:IsA("BasePart") then
					continue
				end

				local name = descendant.Name

				if isCurrentSkin and name ~= "Effects" then
					descendant.Transparency = 0
				elseif (name == "Primary" or name == "Secondary" or name == "Tertiary") and mutationColors[name] then
					-- Finds parts that should be recolored
					descendant.Color = mutationColors[name]
				elseif skinFolder:IsA("Folder") or name == "Pillar" then
					-- Hides pillars and parts from other mutations
					descendant.Transparency = 1
				end
			end
		end
	end

	local boostAmount = MutationsConfig.SkinCashBoost[mutationName]
	PlayerDataService.SetSkinBoost(player, boostAmount)
	logger.log(`Succesfully applied {mutationName} skin to {player.Name} Base`)
	return mutationName
end

return BaseSkinService
