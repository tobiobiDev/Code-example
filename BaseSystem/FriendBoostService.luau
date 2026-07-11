--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DefaultConfigs = require(ReplicatedStorage.Source.Configs.DefaultConfigs)
local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local Network = require(ReplicatedStorage.Source.Libs.Network)
local PlayerDataService = require(ServerScriptService.Source.PlayerData.PlayerDataService)
local Signal = require(ReplicatedStorage.Source.Libs.Signal)
local tryGetPlayerProfile = require(ServerScriptService.Source.PlayerData.tryGetPlayerProfile)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})
local FRIEND_BOOST_AMOUNT = DefaultConfigs.FriendBoostAmount

local FriendBoostService = {}
FriendBoostService.MultiplierChanged = Signal.new() :: Signal.Signal<Player>

local basesFolder = assert(workspace:FindFirstChild("Bases"), "Workspace is missing 'Bases' folder")

local friendCounts: { [number]: number } = {}

function FriendBoostService.UpdateBaseMultiplier(player: Player, reset: boolean?)
	local baseModel: Model? = nil
	for _, child in basesFolder:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("Owner") == player.UserId then
			baseModel = child
			break
		end
	end

	if not baseModel then
		logger.log(`Base model not found for {player.Name}`, true)
		return
	end

	local cashMultiplierGui = baseModel:FindFirstChild("CashMultiplierGui", true) :: BillboardGui
	if not cashMultiplierGui then
		logger.log(`No cash multiplier Gui found for {baseModel.Name}`, true)
		return
	end

	local profile = tryGetPlayerProfile(player)
	if not profile then
		return
	end

	local friendBoost = cashMultiplierGui:FindFirstChild("FriendBoost") :: TextLabel
	local rebirthMultiplier = cashMultiplierGui:FindFirstChild("Rebirth") :: TextLabel
	local skinMultiplier = cashMultiplierGui:FindFirstChild("BaseSkin") :: TextLabel

	if skinMultiplier then
		skinMultiplier.Text = if reset then "" else `Base Skin: +{profile.CashBoosts.SkinBoost}% $`
	end

	if friendBoost then
		local playerId = player.UserId
		local totalFriends = friendCounts[playerId] or 0
		local friendBoostAmount = FRIEND_BOOST_AMOUNT

		PlayerDataService.SetFriendBoost(player, totalFriends * friendBoostAmount)
		friendBoost.Text = if reset then "" else `Friend boost: +{totalFriends * friendBoostAmount}% $`
		if not reset then
			Network.fireClient(Network.RemoteEvents.UpdateCashBoost, player, totalFriends * friendBoostAmount)
		end
	end

	if rebirthMultiplier then
		local cashMultiplier = profile.CashBoosts.RebirthMultiplier
		local totalRebirths = profile.Rebirths

		rebirthMultiplier.Text = if reset
			then ""
			else `Rebirths {totalRebirths} (${math.round(cashMultiplier * 100) / 100}x)`
	end
	cashMultiplierGui.Enabled = true

	if not reset then
		FriendBoostService.MultiplierChanged:Fire(player)
	end
end

local function checkFriendship(p1: Player, p2: Player)
	local success, isFriends = pcall(function()
		return p1:IsFriendsWithAsync(p2.UserId :: any)
	end)
	return success and isFriends
end

-- Function to get the current count for a player
function FriendBoostService.GetFriendCount(player: Player): number
	return friendCounts[player.UserId] or 0
end

-- This runs whenever someone Joins or Leaves
function FriendBoostService.UpdateFriendships(skipPlayer: Player?)
	local currentPlayers = Players:GetPlayers()
	local newCounts = {}

	-- Initialize counts
	for _, p in currentPlayers do
		newCounts[p.UserId] = 0
	end

	-- Compare pairs
	for i = 1, #currentPlayers do
		for j = i + 1, #currentPlayers do
			local p1 = currentPlayers[i]
			local p2 = currentPlayers[j]

			if checkFriendship(p1, p2) then
				newCounts[p1.UserId] += 1
				newCounts[p2.UserId] += 1
			end
		end
	end

	friendCounts = newCounts

	-- Automatically refresh the UI for everyone currently in the server
	for _, player in currentPlayers do
		if skipPlayer and skipPlayer == player then
			continue
		end

		task.spawn(function()
			FriendBoostService.UpdateBaseMultiplier(player)
		end)
	end

	return friendCounts
end

-- Cleanup when someone leaves
function FriendBoostService.RemovePlayer(player: Player)
	friendCounts[player.UserId] = nil

	FriendBoostService.UpdateFriendships(player)
	FriendBoostService.UpdateBaseMultiplier(player, true)
end

return FriendBoostService
