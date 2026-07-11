--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local ConfirmUIController = require(StarterPlayer.StarterPlayerScripts.Source.Gui.ConfirmUIController)
local Network = require(ReplicatedStorage.Source.Libs.Network)
local Types = require(ReplicatedStorage.Source.Types.DialogueSystemTypes)
local formatNumber = require(ReplicatedStorage.Source.Utility.formatNumber)

-- Declare the table first so we can reference it within its own functions
local Conversation: Types.ConversationData = nil :: any

local localPlayer = assert(Players.LocalPlayer, "Failed to find LocalPlayer")
local playerGui = localPlayer:WaitForChild("PlayerGui")

local confirmUi = playerGui:WaitForChild("ConfirmUI")
local sellConfirmFrame = confirmUi:FindFirstChild("ConfirmSale")

Conversation = {
	Id = "CharacterShop",
	StartNode = "intro",
	Style = "Billboard",
	AdorneeProvider = function(context: Types.DialogueContext?): { [string]: BasePart }?
		if not (context and context.NPC and context.Player) then
			warn(`{script.Name}: Passed context missing 'NPC' and/or 'Player'.`)
			return nil
		end
		local modelNPC = context.NPC :: Model
		if not modelNPC:IsA("Model") then
			warn(`{script.Name}: Passed 'NPC' context is not a Model.`)
			return nil
		end

		local player = context.Player :: Player
		if not player:IsA("Player") then
			warn(`{script.Name}: Passed 'Player' context is not a Player object.`)
			return nil
		end

		local character = player.Character
		if not character then
			warn(`{script.Name}: Unabel to get character model from player.`)
			return nil
		end

		local rootPartNPC = modelNPC:FindFirstChild("HumanoidRootPart")
		local rootPartPlayer = character:FindFirstChild("HumanoidRootPart")
		if (rootPartNPC and rootPartNPC:IsA("BasePart")) and (rootPartPlayer and rootPartPlayer:IsA("BasePart")) then
			return { NPC = rootPartNPC, Player = rootPartPlayer }
		end

		warn(
			`{script.Name}: AdorneeProvider could not find HumanoidRootParts from context: NPC {modelNPC} Player {player.Name}`
		)
		return nil
	end,
	Nodes = {

		checkForAppraise = {
			Condition = function()
				local success, sellPrice, characterName =
					Network.invokeServerAsync(Network.RemoteFunctions.SellCharacter, "Appraise")
				if not success then
					return false
				end

				if sellPrice then
					Conversation.Nodes.appraise.Text = `Hmmm {characterName} could sell for ${formatNumber(sellPrice)}`
					return true
				else
					return false
				end
			end,
			Fallback = "noTool",
			Next = "appraise",
		},

		checkForSell = {
			Condition = function()
				Conversation.Nodes.checkForSell.Fallback = "noTool"
				local _, aboveThreshold = Network.invokeServerAsync(Network.RemoteFunctions.AboveRarityThreshold)
				local success, appraisePrice, characterName =
					Network.invokeServerAsync(Network.RemoteFunctions.SellCharacter, "Appraise")
				if not success then
					return false
				end

				local sold = true
				local decided = false

				if aboveThreshold and sellConfirmFrame and sellConfirmFrame:IsA("Frame") then
					sold, decided = ConfirmUIController.ConfirmOption(
						sellConfirmFrame,
						`Are you sure you want to sell {characterName} for ${formatNumber(appraisePrice)}`
					)
				else
					decided = true
				end

				while not decided do
					task.wait(1)
				end

				if not sold then
					Conversation.Nodes.checkForSell.Fallback = "goodbye"
					return false
				end

				local sellSuccess, sellPrice = Network.invokeServerAsync(Network.RemoteFunctions.SellCharacter, "Sell")
				if not sellSuccess then
					return false
				end

				if sellPrice then
					Conversation.Nodes.sell.Text = `Succesfully sold for ${formatNumber(sellPrice)}`
					return true
				else
					return false
				end
			end,
			Fallback = "noTool",
			Next = "sell",
		},
		checkForSellAll = {
			Condition = function()
				Conversation.Nodes.checkForSellAll.Fallback = "noCharacter"

				local successAppraise, appraiseAmount, appraiseNumber =
					Network.invokeServerAsync(Network.RemoteFunctions.SellCharacter, "AppraiseAll")
				if not successAppraise then
					return false
				end

				local sold = true
				local decided = false

				if sellConfirmFrame and sellConfirmFrame:IsA("Frame") then
					sold, decided = ConfirmUIController.ConfirmOption(
						sellConfirmFrame,
						`Are you sure you want to sell {appraiseNumber} brainrots for ${formatNumber(appraiseAmount)}`
					)
				else
					decided = true
				end

				while not decided do
					task.wait(1)
				end

				if not sold then
					Conversation.Nodes.checkForSellAll.Fallback = "goodbye"
					return false
				end

				local successSell, sellPrice, totalNumber =
					Network.invokeServerAsync(Network.RemoteFunctions.SellCharacter, "SellAll")
				if not successSell then
					return false
				end

				if sellPrice then
					Conversation.Nodes.sellAll.Text = `Succesfully sold {totalNumber} for ${formatNumber(sellPrice)}`
					return true
				else
					return false
				end
			end,
			Fallback = "noCharacter",
			Next = "sellAll",
		},

		sell = {
			Speaker = "Copper",
			Text = "",
			Choices = {
				{ Id = "bye", Text = "Goodbye" },
			},
		},
		intro = {
			Speaker = "Copper",
			Text = "H-hello What do you want?",
			Choices = {
				{ Id = "checkForSell", Text = "I want to sell this brainrot!" },
				{ Id = "checkForSellAll", Text = "I want to sell all brainrots in my inventory." },
				{ Id = "checkForAppraise", Text = "How much is this brainrot worth?" },
				{ Id = "nothing", Text = "Nothing." },
			},
		},
		noCharacter = {
			Speaker = "Copper",
			Text = "You don't own any characters.",
			Choices = {
				{ Id = "bye", Text = "Goodbye" },
			},
		},

		noTool = {
			Speaker = "Copper",
			Text = "If you want to sell or have a character appraised, you need to be holding one.",
			Choices = {
				{ Id = "bye", Text = "Goodbye" },
			},
		},

		sellAll = {
			Speaker = "Copper",
			Text = "",
			Choices = {
				{ Id = "bye", Text = "Goodbye" },
			},
		},
		appraise = {
			Speaker = "Copper",
			Text = "Succesfully appraised",
			Choices = {
				{ Id = "bye", Text = "Goodbye" },
			},
		},
		goodbye = {
			Speaker = "Copper",
			Text = "That's a shame. Goodbye",
			Choices = {
				{ Id = "bye", Text = "Goodbye" },
			},
		},

		nothing = {
			Speaker = "Copper",
			Text = "That's a shame. See you again soon!",
			Choices = {
				{ Id = "bye", Text = "Goodbye" },
			},
		},
		bye = {
			End = true,
		},
	},
}

return Conversation
