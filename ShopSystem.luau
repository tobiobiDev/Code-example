--!strict
--Connected Discord-GitHub

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CarryCapacityService = require(ServerScriptService.Source.Systems.UpgradeSystem.CarryCapacityService)
local CharacterNameEnum = require(ReplicatedStorage.Source.Enums.CharacterNameEnum)
local CharacterSystem = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterSystem)
local CharacterToolService = require(ServerScriptService.Source.Systems.CharacterSystem.CharacterToolService)
local Characters = require(ReplicatedStorage.Source.Data.Characters)
local CurrencyEnum = require(ReplicatedStorage.Source.Enums.CurrencyEnum)
local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local LootTable = require(ReplicatedStorage.Source.Utility.LootTable)
local MutationEnum = require(ReplicatedStorage.Source.Enums.MutationEnum)
local Network = require(ReplicatedStorage.Source.Libs.Network)
local PickaxeUpgradeService = require(ServerScriptService.Source.Systems.UpgradeSystem.PickaxeUpgradeService)
local PlayerDataService = require(ServerScriptService.Source.PlayerData.PlayerDataService)
local RandomBrainrot = require(ReplicatedStorage.Source.Data.RandomBrainrot)
local RandomBrainrotConfig = require(ReplicatedStorage.Source.Configs.RandomBrainrotConfig)
local RebirthConfig = require(ReplicatedStorage.Source.Configs.RebirthConfig)
local RebirthSystem = require(ServerScriptService.Source.Systems.RebirthSystem)
local ShopProducts = require(ReplicatedStorage.Source.Data.ShopProducts)
local TraitsEnum = require(ReplicatedStorage.Source.Enums.TraitsEnum)
local UpgradesConfig = require(ReplicatedStorage.Source.Configs.UpgradesConfig)
local WalkspeedService = require(ServerScriptService.Source.Systems.UpgradeSystem.WalkspeedService)
local WeaponNameEnum = require(ReplicatedStorage.Source.Enums.WeaponNameEnum)
local generateCharacterId = require(ServerScriptService.Source.Systems.CharacterSystem.generateCharacterId)
local tryGetPlayerProfile = require(ServerScriptService.Source.PlayerData.tryGetPlayerProfile)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

type EntryType = {
	Type: "Product" | "GamePass",
	TimeLimit: number?,
	Name: string,
	Id: number,
	OneTime: boolean,
	GiftProductId: number?,
	Reward: (player: Player) -> (),
}

type GetActiveIdEntry = EntryType & {
	GetActiveId: (player: Player) -> number?,
}

type CanPurchaseEntry = EntryType & {
	CanPurchase: (player: Player) -> boolean,
}

-- The main configuration table type
type ProductsConfigType = { [string]: GetActiveIdEntry } | { [string]: CanPurchaseEntry }

local sessionTracker: { [Player]: number } = {}

local ShopSystem = {}

local productsConfig: ProductsConfigType = {
	ServerLuck = {
		Type = "Product",
		Id = ShopProducts.ServerLuck1,
		OneTime = false,
		--[[
		Function to determine which ID to prompt based on current game state, 
		for example determines product based on current server luck
		]]
		GetActiveId = function()
			local currentLevel = CharacterSystem.currentLuckLevel
			local tierIds = {
				[0] = ShopProducts.ServerLuck1,
				[1] = ShopProducts.ServerLuck2,
				[2] = ShopProducts.ServerLuck3,
			}
			return tierIds[currentLevel] or tierIds[#tierIds]
		end,
		Reward = function(player: Player)
			CharacterSystem.UpdateServerLuck(player)
		end,
	},
	RandomBrainrot = {
		Name = "Random Brainrot",
		Type = "Gamepass",
		Id = ShopProducts.RandomBrainrot,
		OneTime = false,
		Reward = function(player: Player)
			local selector = LootTable.new(RandomBrainrot.LootDrop :: any)
			local characterName = selector:getRandomItem() :: CharacterNameEnum.EnumType
			local characterId = generateCharacterId()
			local characterLevel = 1
			local characterMutation: MutationEnum.EnumType = "Normal"
			local characterTrait: TraitsEnum.EnumType = "Traitless"

			local characterInfo = Characters[characterName]
			local characterRarity = characterInfo.Rarity

			Network.fireClient(Network.RemoteEvents.PlayRollAnimation, player, characterName)
			task.wait(RandomBrainrotConfig.TOTAL_ROLLING_LENGTH)
			PlayerDataService.SaveCollectedCharacter(
				player,
				characterId,
				characterName,
				characterLevel,
				characterMutation,
				characterTrait,
				characterRarity
			)

			CharacterSystem.CheckBaseSkin(player, characterMutation, characterName)
			CharacterToolService.GiveCharactersTools(player, characterName, characterId)
			Network.fireClient(
				Network.RemoteEvents.PlayNotification,
				player,
				`You have received {characterName} Brainrot!`
			)
		end,
	},
	RandomBrainrotX3 = {
		Name = "Random Brainrot X3",
		Type = "Product",
		Id = ShopProducts.RandomBrainrotX3,
		OneTime = false,
		Reward = function(player: Player)
			local amountOfRolls = 3

			for i = 1, amountOfRolls do
				local selector = LootTable.new(RandomBrainrot.LootDrop :: any)
				local characterName = selector:getRandomItem() :: CharacterNameEnum.EnumType
				local characterId = generateCharacterId()
				local characterLevel = 1
				local characterMutation: MutationEnum.EnumType = "Normal"
				local characterTrait: TraitsEnum.EnumType = "Traitless"

				local characterInfo = Characters[characterName]
				local characterRarity = characterInfo.Rarity

				Network.fireClient(Network.RemoteEvents.PlayRollAnimation, player, characterName, i ~= amountOfRolls)
				task.wait(RandomBrainrotConfig.TOTAL_ROLLING_LENGTH)
				PlayerDataService.SaveCollectedCharacter(
					player,
					characterId,
					characterName,
					characterLevel,
					characterMutation,
					characterTrait,
					characterRarity
				)

				CharacterSystem.CheckBaseSkin(player, characterMutation, characterName)
				CharacterToolService.GiveCharactersTools(player, characterName, characterId)
				Network.fireClient(
					Network.RemoteEvents.PlayNotification,
					player,
					`You have received {characterName} Brainrot!`
				)
				task.wait(RandomBrainrotConfig.REVEAL_DURATION)
			end
		end,
	},
	PickaxeUpgrade = {
		Name = "Pickaxe Upgrade",
		Type = "Product",
		Id = ShopProducts.PickaxeUpgrade1,
		OneTime = false,
		--[[
		Function to determine which ID to prompt based on current game state, 
		for example determines product based on current server luck
		]]

		GetActiveId = function(player: Player): number?
			local profile = tryGetPlayerProfile(player)
			if not profile then
				return nil
			end
			local currentLevel = profile.Upgrades.Pickaxe

			local tierIds = {
				[0] = ShopProducts.PickaxeUpgrade1,
				[9] = ShopProducts.PickaxeUpgrade2,
				[19] = ShopProducts.PickaxeUpgrade3,
				[29] = ShopProducts.PickaxeUpgrade4,
				[49] = ShopProducts.PickaxeUpgrade5,
				[99] = ShopProducts.PickaxeUpgrade6,
				[149] = ShopProducts.PickaxeUpgrade7,
				[249] = ShopProducts.PickaxeUpgrade8,
			}

			local levels: { number } = {}
			for level in pairs(tierIds) do
				table.insert(levels, level)
			end

			table.sort(levels, function(a: number, b: number)
				return a > b
			end)

			for _, level in ipairs(levels) do
				local id = tierIds[level]

				if currentLevel >= level then
					return id
				end
			end

			return tierIds[#tierIds]
		end,
		Reward = function(player: Player)
			PickaxeUpgradeService.UpgradePickaxe(player, true, true)
		end,
	},

	CarryCapacity = {
		Type = "Product",
		Name = "Carry Capacity",
		Id = ShopProducts.CarryCapacity,
		OneTime = false, -- If gamepass/dev product can only be purchased once
		Reward = function(player: Player)
			CarryCapacityService.UpgradeCarryCapacity(player, true)
		end,
		--Checks if player can purchase a product/gamepas, for example if they already have max carry capacity
		CanPurchase = function(player: Player): boolean
			local profile = tryGetPlayerProfile(player)
			if not profile then
				return false
			end

			local currentLevel = profile.Upgrades.CarryCapacity
			local maxLevel = UpgradesConfig.CarryCapacity.MaxLevel
			return currentLevel < maxLevel
		end,
	},

	Walkspeed = {
		Type = "Product",
		Name = "Walkspeed Upgrade",
		Id = ShopProducts.Walkspeed,
		OneTime = false, -- If gamepass/dev product can only be purchased once
		Reward = function(player: Player)
			WalkspeedService.UpgradeWalkspeed(player, true)
		end,
		CanPurchase = function(player: Player): boolean
			local profile = tryGetPlayerProfile(player)
			if not profile then
				return false
			end

			local currentLevel = profile.Upgrades.Walkspeed
			local maxLevel = UpgradesConfig.Walkspeed.MaxLevel
			return currentLevel < maxLevel
		end,
	},

	Rebirth = {
		Type = "Product",
		Name = "Rebirth",
		Id = ShopProducts.Rebirth,
		OneTime = false, -- If gamepass/dev product can only be purchased once
		Reward = function(player: Player)
			RebirthSystem.AttemptRebirth(player, true)
		end,
		CanPurchase = function(player: Player): boolean
			local profile = tryGetPlayerProfile(player)
			if not profile then
				return false
			end

			return profile.Rebirths < RebirthConfig.Config.MaxRebirth
		end,
	},

	StarterPack = {
		Type = "Product",
		Name = "Starter Pack",
		TimeLimit = 800,
		Id = ShopProducts.StarterPack,
		OneTime = true, -- If gamepass/dev product can only be purchased once
		Reward = function(player: Player)
			PlayerDataService.AdjustCurrency(player, CurrencyEnum.Cash, 30000) -- This is how to award cash
			PlayerDataService.AddThievesTool(player, WeaponNameEnum.MetalBat)

			-- This is how to reward Character
			local characterId = generateCharacterId()
			local characterName: CharacterNameEnum.EnumType = "Lirili Larila"
			local characterLevel = 1
			local characterMutation: MutationEnum.EnumType = "Normal"
			local characterTrait: TraitsEnum.EnumType = "Traitless"

			local characterInfo = Characters[characterName]
			local characterRarity = characterInfo.Rarity

			PlayerDataService.SaveCollectedCharacter(
				player,
				characterId,
				characterName,
				characterLevel,
				characterMutation,
				characterTrait,
				characterRarity
			)

			CharacterSystem.CheckBaseSkin(player, characterMutation, characterName)
			CharacterToolService.GiveCharactersTools(player, characterName, characterId)
		end,
	},
	NovicePack = {
		Type = "Product",
		Name = "Novice Pack",
		Id = ShopProducts.NovicePack,
		OneTime = true, -- If gamepass/dev product can only be purchased once
		Reward = function(player: Player)
			PlayerDataService.AdjustCurrency(player, CurrencyEnum.Cash, 100000) -- This is how to award cash

			local characterId = generateCharacterId()
			local characterName: CharacterNameEnum.EnumType = "Melanini Pandanini"
			local characterLevel = 1
			local characterMutation: MutationEnum.EnumType = "Normal"
			local characterTrait: TraitsEnum.EnumType = "Traitless"

			local characterInfo = Characters[characterName]
			local characterRarity = characterInfo.Rarity

			PlayerDataService.SaveCollectedCharacter(
				player,
				characterId,
				characterName,
				characterLevel,
				characterMutation,
				characterTrait,
				characterRarity
			)

			CharacterSystem.CheckBaseSkin(player, characterMutation, characterName)
			CharacterToolService.GiveCharactersTools(player, characterName, characterId)

			-- This is how to reward Character
			local characterId1 = generateCharacterId()
			local characterName1: CharacterNameEnum.EnumType = "Glorbo Fruttodrillo"
			local characterLevel1 = 1
			local characterMutation1: MutationEnum.EnumType = "Normal"
			local characterTrait1: TraitsEnum.EnumType = "Traitless"

			local characterInfo1 = Characters[characterName1]
			local characterRarity1 = characterInfo1.Rarity

			PlayerDataService.SaveCollectedCharacter(
				player,
				characterId1,
				characterName1,
				characterLevel1,
				characterMutation1,
				characterTrait1,
				characterRarity1
			)

			CharacterSystem.CheckBaseSkin(player, characterMutation1, characterName1)
			CharacterToolService.GiveCharactersTools(player, characterName1, characterId1)
		end,
	},
	ProPack = {
		Type = "Product",
		Name = "Pro Pack",
		Id = ShopProducts.ProPack,
		OneTime = true, -- If gamepass/dev product can only be purchased once
		Reward = function(player: Player)
			PlayerDataService.AdjustCurrency(player, CurrencyEnum.Cash, 1000000) -- This is how to award cash
			PlayerDataService.AddThievesTool(player, WeaponNameEnum.GoldenBat)

			-- This is how to reward Character
			local characterId = generateCharacterId()
			local characterName: CharacterNameEnum.EnumType = "Cappuccino Assassino"
			local characterLevel = 1
			local characterMutation: MutationEnum.EnumType = "Normal"
			local characterTrait: TraitsEnum.EnumType = "Traitless"

			local characterInfo = Characters[characterName]
			local characterRarity = characterInfo.Rarity

			PlayerDataService.SaveCollectedCharacter(
				player,
				characterId,
				characterName,
				characterLevel,
				characterMutation,
				characterTrait,
				characterRarity
			)

			CharacterSystem.CheckBaseSkin(player, characterMutation, characterName)
			CharacterToolService.GiveCharactersTools(player, characterName, characterId)
		end,
	},
	UltimatePack = {
		Type = "Product",
		Name = "Ultimate Pack",
		Id = ShopProducts.UltimatePack,
		OneTime = true, -- If gamepass/dev product can only be purchased once
		Reward = function(player: Player)
			PlayerDataService.AddThievesTool(player, WeaponNameEnum.RubyBat)
			CharacterSystem.UpdateServerLuck(player)

			-- This is how to reward Character
			local characterId = generateCharacterId()
			local characterName: CharacterNameEnum.EnumType = "Udin Din Din Dun"
			local characterLevel = 1
			local characterMutation: MutationEnum.EnumType = "Normal"
			local characterTrait: TraitsEnum.EnumType = "Traitless"

			local characterInfo = Characters[characterName]
			local characterRarity = characterInfo.Rarity

			PlayerDataService.SaveCollectedCharacter(
				player,
				characterId,
				characterName,
				characterLevel,
				characterMutation,
				characterTrait,
				characterRarity
			)

			CharacterSystem.CheckBaseSkin(player, characterMutation, characterName)
			CharacterToolService.GiveCharactersTools(player, characterName, characterId)
		end,
	},

	BrainrotDetector = {
		Name = "Brainrot Detector",
		Type = "Gamepass",
		Id = ShopProducts.BrainrotDetector,
		OneTime = true, -- If gamepass/dev product can only be purchased once
		Reward = function(player: Player)
			local profile = tryGetPlayerProfile(player)
			if not profile then
				return
			end
			PlayerDataService.UnlockBrainrotDetector(player)
			PlayerDataService.ChangeDetectorSetting(player, true)
			Network.fireClient(Network.RemoteEvents.ChangeSettings, player, profile.Settings)
		end,
	},
}

local GiftingRegistry = {}

local function checkRobloxOwnership(player: Player, passId: number): boolean
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.User, passId)
	end)

	if not success then
		warn("Gamepass check failed for", passId)
		return false
	end

	return owns == true
end

local function getConfigByAnything(idOrName, player): (EntryType?, string)
	local query = tostring(idOrName)

	if productsConfig[query] then
		return productsConfig[query], query
	end

	for name, config in productsConfig do
		if tostring(config.Id) == query or tostring(config.GiftProductId) == query then
			return config, name
		end
		local activeId = if config.GetActiveId then config.GetActiveId(player) else nil
		if activeId and tostring(activeId) == query then
			return config, name
		end
	end
	return nil, ""
end

local function setupPurchaseListeners()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
		if wasPurchased and player:IsA("Player") then
			logger.log(`{player.Name} succesfuly bought gamepass with id: {passId}`)

			local config, _ = getConfigByAnything(passId, player)
			if not config then
				return
			end
			config.Reward(player)

			Network.fireClient(Network.RemoteEvents.ShopPurchase, player, passId)
		end
	end)

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local buyerId = receiptInfo.PlayerId
		local recipientId = GiftingRegistry[buyerId] or buyerId
		local buyer = Players:GetPlayerByUserId(buyerId)
		local recipient = Players:GetPlayerByUserId(recipientId)

		if not recipient then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local profile = tryGetPlayerProfile(recipient)
		if not profile then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local config, internalName = getConfigByAnything(receiptInfo.ProductId, recipient)

		if config then
			config.Reward(recipient)

			if buyer ~= recipient then
				Network.fireClient(
					Network.RemoteEvents.PlayNotification,
					recipient,
					`{buyer} has gifted you {config.Name}`,
					true
				)
			end

			local saveKey = config.Id or internalName
			profile.PurchaseHistory[tostring(saveKey)] = profile.PurchaseHistory[tostring(saveKey)] or {}
			table.insert(profile.PurchaseHistory[tostring(saveKey)], os.time())

			GiftingRegistry[buyerId] = nil

			if config.OneTime then
				Network.fireClient(Network.RemoteEvents.ShopPurchase, recipient, saveKey)
			end

			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

local function connectPurchase(player: Player, id: string, giftTargetId: number)
	logger.log(`{player.Name} is trying to gift with id: {id} to {giftTargetId} or buy for themself`)
	local config, internalName = getConfigByAnything(id, player)

	if not config then
		logger.log(`Purchase failed: {id} not found in config`, true)
		return
	end

	local receivingPlayer = if giftTargetId then Players:GetPlayerByUserId(giftTargetId :: any) else player
	if not receivingPlayer then
		return
	end
	local profile = tryGetPlayerProfile(receivingPlayer)
	if not profile then
		return
	end

	local currentPlayTime = profile.PlayTime + os.time() - sessionTracker[receivingPlayer]
	if config.TimeLimit and currentPlayTime >= config.TimeLimit then
		logger.log(`{player.Name} tried buying {id} but time has  `)
		return
	end

	local canPurchaseFunction = (config :: CanPurchaseEntry).CanPurchase

	local canBuy = if canPurchaseFunction then canPurchaseFunction(receivingPlayer) else true

	if not canBuy and giftTargetId then
		Network.fireClient(
			Network.RemoteEvents.PlayNotification,
			player,
			`{receivingPlayer} doesn't meet requirements for this gift!`,
			false,
			`GiftedAlreadyOwns`
		)
		logger.log(`{receivingPlayer} doesn't meet requirements for purchase`)
		return
	elseif not canBuy then
		Network.fireClient(
			Network.RemoteEvents.PlayNotification,
			player,
			`You don't meet requirements to buy this!`,
			false,
			`GiftedAlreadyOwns`
		)
		logger.log(`{player.Name} doesn't meet requirements for purchase`)
		return
	end

	-- Check OneTime ownership
	if config.OneTime and profile.PurchaseHistory[tostring(config.Id or internalName)] then
		logger.log(`{receivingPlayer.Name} already owns {internalName}`, true)

		if giftTargetId then
			Network.fireClient(
				Network.RemoteEvents.PlayNotification,
				player,
				`{receivingPlayer} already owns this item!`,
				false,
				`GiftedAlreadyOwns`
			)
		else
			Network.fireClient(
				Network.RemoteEvents.PlayNotification,
				player,
				`You already own this!`,
				false,
				`AlreadyOwns`
			)
		end

		return
	end

	GiftingRegistry[player.UserId :: any] = giftTargetId :: any or player.UserId :: any

	local idToPrompt = config.Id -- Default fallback

	local getActiveFunction = (config :: GetActiveIdEntry).GetActiveId
	idToPrompt = if getActiveFunction then getActiveFunction(player) or config.Id else config.Id

	logger.log(`Found id to prompt to {player.Name} for purchase: {idToPrompt}`)

	if config.Type == "Gamepass" then
		logger.log(`ID belongs to a gamepass, checking if it's being gifted`)
		if giftTargetId and giftTargetId ~= player.UserId then
			logger.log(`Gamepass is being gifted, checking if gift product id exists`)
			-- Use the specific Gift Product for Gamepasses
			if config.GiftProductId then
				logger.log(`Gift product id exists, prompting to {player.Name}`)
				MarketplaceService:PromptProductPurchase(player, config.GiftProductId :: number)
			end
		else
			logger.log(`It's not being gifted, prompting to {player.Name}`)
			MarketplaceService:PromptGamePassPurchase(player, idToPrompt)
		end
	elseif config.Type == "Product" then
		logger.log(`ID belongs to developer product, prompting to {player.Name}`)
		MarketplaceService:PromptProductPurchase(player, idToPrompt)
	end
end

local function onPlayerAdded(player: Player)
	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	sessionTracker[player] = os.time()

	for _, gamepassConfig in productsConfig do
		if gamepassConfig.Type ~= "Gamepass" then
			continue
		end
		local passId = gamepassConfig.Id
		local idAsNumber = tonumber(passId)

		if not idAsNumber then
			continue
		end
		if checkRobloxOwnership(player, idAsNumber) then
			-- Grant benefits if they aren't already in the profile history
			if not profile.PurchaseHistory[tostring(gamepassConfig.Id)] then
				logger.log(`Syncing official purchase for {player.Name}: {passId}`)

				profile.PurchaseHistory[tostring(passId)] = profile.PurchaseHistory[tostring(passId)] or {}
				table.insert(profile.PurchaseHistory[tostring(passId)], os.time())

				-- Run the benefit (e.g., give items/perks)
				task.spawn(gamepassConfig.Reward, player)
			end
		end
	end

	for _, productInfo in productsConfig do
		if productInfo.OneTime and profile.PurchaseHistory[productInfo.Id] then
			continue
		end
		local playTime = profile.PlayTime
		if productInfo.TimeLimit and playTime >= productInfo.TimeLimit then
			Network.fireClient(Network.RemoteEvents.ShopProductTimer, player, productInfo.TimeLimit, productInfo.Id)
		elseif productInfo.TimeLimit then
			Network.fireClient(
				Network.RemoteEvents.ShopProductTimer,
				player,
				productInfo.TimeLimit,
				productInfo.Id,
				playTime
			)
		end
	end

	for productId, _ in profile.PurchaseHistory do
		local config = getConfigByAnything(productId, player)
		if config and config.OneTime then
			Network.fireClient(Network.RemoteEvents.ShopPurchase, player, tonumber(productId))
		end
	end
end

function ShopSystem.Start()
	Network.connectEvent(Network.RemoteEvents.ShopPurchase, connectPurchase)
	setupPurchaseListeners()
	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, player: Player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	Players.PlayerRemoving:Connect(function(player: Player)
		local addTime = os.time() - sessionTracker[player]
		PlayerDataService.AddPlayTime(player, addTime)
		sessionTracker[player] = nil
	end)

	Network.bindFunction(Network.RemoteFunctions.GetNextLuckProduct, function(player: Player)
		if not player then
			return
		end

		local serverLuckConfig = productsConfig.ServerLuck :: GetActiveIdEntry
		if serverLuckConfig.GetActiveId then
			return serverLuckConfig.GetActiveId(player)
		end
	end)

	Network.bindFunction(Network.RemoteFunctions.GetNextUpgradeProduct, function(player: Player): number?
		if not player then
			return nil
		end
		local pickaxeUpgradeConfig = productsConfig.PickaxeUpgrade :: GetActiveIdEntry
		if pickaxeUpgradeConfig.GetActiveId then
			return pickaxeUpgradeConfig.GetActiveId(player)
		end

		return nil
	end)
end

return ShopSystem
