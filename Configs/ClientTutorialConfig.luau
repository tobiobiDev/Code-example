--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local BaseProvider = require(ReplicatedStorage.Source.Utility.BaseProvider)
local ClientDataService = require(ReplicatedStorage.Source.PlayerData.ClientDataService)
local Connections = require(ReplicatedStorage.Source.Utility.Connections)
local LoadingScreen = require(StarterPlayer.StarterPlayerScripts.Source.Gui.LoadingScreen)
local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local Network = require(ReplicatedStorage.Source.Libs.Network)
local Promise = require(ReplicatedStorage.Source.Libs.LeanPromise)
local RebirthConfig = require(script.Parent.RebirthConfig)
local Signal = require(ReplicatedStorage.Source.Libs.Signal)
local SoundEffects = require(ReplicatedStorage.Source.Utility.SoundEffects)
local TutorialConfig = require(ReplicatedStorage.Source.Configs.TutorialConfig)
local formatNumber = require(ReplicatedStorage.Source.Utility.formatNumber)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

local LOADING_SCREEN_TEXT = "Moving to the main area..."

export type Context = {
	player: Player,
	dropButton: ImageButton,
	rebirthButton: ImageButton,
	upgradesTeleportButton: ImageButton,
	notificationPrompt: ImageLabel,
	notificationTextLabel: TextLabel,
	pickaxeUpgradesZone: BasePart,
	baseId: string?,
	upgradePrice: number,

	pointArrowAt: (targetObject: GuiObject) -> (),
	pointBeamArrowAt: (targetObject: Model | BasePart) -> (),
	pointToCharacter: () -> (),
	showExtraInfo: (text: string) -> ImageLabel?,
}

export type StageConfig = {
	OnStart: ((context: Context, connections: Connections.Connections?) -> Promise.Promise<any>)?,
	OnEnd: ((context: Context) -> ...any?)?,
}

local typewriterThread: thread? = nil

--[[
    Displays text character-by-character for a typewriter-style effect.
    Plays a typing sound each step for added feedback.
]]
local function showText(context: Context, text: string, skipEffect: boolean?)
	if not context.notificationTextLabel then
		return
	end

	if typewriterThread then
		task.cancel(typewriterThread)
		typewriterThread = nil
	end

	context.notificationTextLabel.Text = ""
	logger.log(`Typewriter effect started for text: {text}`)

	if context.notificationPrompt then
		context.notificationPrompt.Visible = true
	end

	if skipEffect then
		-- If skipped, show full text immediately and exit.
		context.notificationTextLabel.Text = text
		logger.log("Typewriter skipped. Full text displayed.")
		return
	end

	typewriterThread = task.spawn(function()
		for i = 1, #text do
			context.notificationTextLabel.Text = text:sub(1, i)
			SoundEffects.PlaySound("DialogueText")
			task.wait(TutorialConfig.NotificationTextTypewritingSpeed)
		end

		logger.log("Typewriter effect completed.")
		typewriterThread = nil
	end)
end

local function clearText(context: Context)
	if typewriterThread then
		task.cancel(typewriterThread)
		typewriterThread = nil
	end

	if context.notificationPrompt then
		context.notificationPrompt.Visible = false
	end
	if context.notificationTextLabel then
		context.notificationTextLabel.Text = ""
	end
end

--[[
	Displays the loading screen while the player teleports to the main area.
]]
local function playLoadingScreen()
	LoadingScreen.enableAsync()
	LoadingScreen.updateDetailText(LOADING_SCREEN_TEXT)
end

local ClientTutorialConfig: { [TutorialConfig.StageName]: StageConfig } = {
	InitiateTutorial = {
		OnStart = function(context)
			if context.dropButton then
				context.dropButton.Active = false
				context.dropButton.Visible = false
			end

			showText(context, "Equip your pickaxe and mine through that wall to get your first brainrot!", true)

			return Promise.new(function(resolve, _reject, onCancel)
				local conn: RBXScriptConnection
				conn = Network.connectEvent(Network.RemoteEvents.PickedUpCharacter, function()
					conn:Disconnect()
					context.pointToCharacter()
					clearText(context)
					resolve(true)
				end)

				onCancel(function()
					if conn then
						conn:Disconnect()
						clearText(context)
					end
				end)
			end)
		end,
	},

	LeaveCave = {
		OnStart = function(context)
			if context.dropButton then
				context.dropButton.Active = false
				context.dropButton.Visible = false
			end

			showText(context, "Leave the cave to collect the character!")

			return Promise.new(function(resolve, _reject, onCancel)
				local conn: RBXScriptConnection
				conn = Network.connectEvent(
					Network.RemoteEvents.CharacterCollected,
					function(_characterId: string, _isCarried: boolean, trulyCollected: boolean)
						if trulyCollected then
							conn:Disconnect()
							clearText(context)
							resolve(true)
						else
							conn:Disconnect()
							clearText(context)
						end
					end
				)

				onCancel(function()
					if conn then
						conn:Disconnect()
					end
				end)
			end)
		end,
	},

	PlaceCharacter = {
		OnStart = function(context)
			if context.dropButton then
				context.dropButton.Active = true
			end

			BaseProvider.GetBase()
				:andThen(function(base: Model)
					context.baseId = base.Name

					local display = base:FindFirstChild("Display1", true)
					if display and display:IsA("Model") then
						context.pointBeamArrowAt(display)
					end
				end)
				:catch(function(err)
					logger.log(`Failed to get player base: {tostring(err)}`, true)
				end)

			showText(context, "Hold your character and place it inside the base.")

			return Promise.new(function(resolve, _reject, onCancel)
				local conn: RBXScriptConnection
				conn = Network.connectEvent(Network.RemoteEvents.TutorialCharacterPlaced, function()
					conn:Disconnect()
					clearText(context)
					resolve(true)
				end)

				onCancel(function()
					if conn then
						conn:Disconnect()
						clearText(context)
					end
				end)
			end)
		end,
	},

	CollectCash = {
		OnStart = function(context)
			showText(context, "Your characters generate cash each second once placed, even when offline!")
			task.wait(3)
			showText(context, "Collect the cash!")

			return Promise.new(function(resolve, _reject, onCancel)
				local conn: Signal.Connection
				conn = ClientDataService.Signals.CurrencyChanged:Connect(
					function(_currencyType: any, _newBalance: number)
						conn:Disconnect()
						Network.fireServer(Network.RemoteEvents.FinishedTutorialArea, context.player)
						clearText(context)
						resolve(true)
					end
				)

				onCancel(function()
					if conn then
						conn:Disconnect()
						clearText(context)
					end
				end)
			end)
		end,
		OnEnd = function(context)
			playLoadingScreen()
			task.wait(1)
			LoadingScreen.DisableAsync()
			task.wait(1)
			showText(context, "That tutorial area must have felt cramped, welcome to the main area!")
			task.wait(3)
			clearText(context)
		end,
	},

	UpgradeCharacter = {
		OnStart = function(context)
			showText(context, "Upgrade your character.")

			BaseProvider.GetBase():andThen(function(base: Model)
				if not base then
					return
				end

				context.baseId = base.Name
			end)

			for _, character in CollectionService:GetTagged(`PlacedCharacter_{context.player.UserId}`) do
				local displayModel = character.Parent
				if not (displayModel and string.find(displayModel.Name, "Display")) then
					continue
				end

				local upgradePart = displayModel:FindFirstChild("Upgrade")
				if not (upgradePart and upgradePart:IsA("Part")) then
					continue
				end

				context.pointBeamArrowAt(upgradePart)
			end

			return Promise.new(function(resolve, _reject, onCancel)
				local conn: RBXScriptConnection
				conn = Network.connectEvent(Network.RemoteEvents.UpgradeCharacter, function(receivedBaseId: string)
					if receivedBaseId ~= context.baseId then
						return
					end

					conn:Disconnect()
					clearText(context)
					resolve(true)
				end)

				onCancel(function()
					if conn then
						conn:Disconnect()
						clearText(context)
					end
				end)
			end)
		end,
		OnEnd = function(context)
			showText(context, "Good job, now collect enough cash to buy your first pickaxe upgrade!")
			task.wait(3)
			clearText(context)
		end,
	},

	CollectCashForPickaxeUpgrade = {
		OnStart = function(context)
			return Promise.new(function(resolve, _reject, onCancel)
				if context.notificationPrompt then
					context.notificationPrompt.Visible = true
				end

				local function updateUI(currentCash: number)
					if context.notificationTextLabel then
						context.notificationTextLabel.Text =
							`{formatNumber(currentCash)}/{formatNumber(context.upgradePrice)}`
					end
				end

				local profile = ClientDataService.GetProfile()
				if profile then
					local currentCash = profile.Currency.Cash
					if currentCash >= context.upgradePrice then
						resolve(true)
						return
					end

					updateUI(currentCash)
				end

				local conn: Signal.Connection
				conn = ClientDataService.Signals.CurrencyChanged:Connect(
					function(_currencyType: any, newBalance: number)
						updateUI(newBalance)

						if newBalance >= context.upgradePrice then
							conn:Disconnect()
							clearText(context)
							resolve(true)
						end
					end
				)

				onCancel(function()
					if conn then
						conn:Disconnect()
						clearText(context)
					end
				end)
			end)
		end,
	},

	UpgradePickaxe = {
		OnStart = function(context)
			if context.pickaxeUpgradesZone then
				context.pointBeamArrowAt(context.pickaxeUpgradesZone)
			end

			context.pointArrowAt(context.upgradesTeleportButton)

			showText(context, "Go over to the upgrade shop and upgrade your pickaxe.")

			return Promise.new(function(resolve, _reject, onCancel)
				local profile = ClientDataService.GetProfile()
				local currentLevel = if profile then profile.Upgrades.Pickaxe else 0
				if currentLevel >= 1 then
					clearText(context)
					resolve(true)
					return
				end

				local conn: Signal.Connection
				conn = ClientDataService.Signals.UpdatePickaxeLevel:Connect(function(level: number)
					if level >= 1 then
						conn:Disconnect()
						clearText(context)
						resolve(true)
					end
				end)

				onCancel(function()
					if conn then
						conn:Disconnect()
						clearText(context)
					end
				end)
			end)
		end,
		OnEnd = function(context)
			showText(context, "Good job!")
			task.wait(1.5)
			showText(context, "For your last task, get enough upgrades for your first rebirth.")
			task.wait(2)
			clearText(context)
		end,
	},

	GetPickaxeUpgradesForRebirth = {
		OnStart = function(context)
			return Promise.new(function(resolve, _reject, onCancel)
				if context.notificationPrompt then
					context.notificationPrompt.Visible = true
				end

				-- Get the upgrade requirement for the first rebirth
				local profile = ClientDataService:GetProfile()
				if not profile then
					return
				end
				local currentRebirths = profile.Rebirths
				local upgradesPerRebirth = RebirthConfig.Config.UpgradesPerRebirth

				-- Base calculation
				local requiredUpgrades = upgradesPerRebirth + (currentRebirths * upgradesPerRebirth)
				local targetRebirth = currentRebirths + 1

				-- Add cumulative upgrades up to targetRebirth
				for i = 1, targetRebirth do
					local requirementInfo = RebirthConfig.Requirements[i]
					if requirementInfo and requirementInfo.PickaxeUpgrade then
						requiredUpgrades += requirementInfo.PickaxeUpgrade
					end
				end
				
				local function updateUI(currentUpgradeLevel: number)
					if context.notificationTextLabel then
						context.notificationTextLabel.Text =
							`{currentUpgradeLevel}/{requiredUpgrades} upgrades needed for rebirth`
					end
				end

				local currentLevel = profile.Upgrades.Pickaxe
				if currentLevel >= requiredUpgrades then
					resolve(true)
					return
				end

				updateUI(profile.Upgrades.Pickaxe)

				local conn: Signal.Connection
				conn = ClientDataService.Signals.UpdatePickaxeLevel:Connect(function(newLevel: number)
					updateUI(newLevel)

					if newLevel >= requiredUpgrades then
						conn:Disconnect()
						clearText(context)
						resolve(true)
					end
				end)

				onCancel(function()
					if conn then
						conn:Disconnect()
						clearText(context)
					end
				end)
			end)
		end,
	},

	Rebirth = {
		OnStart = function(context)
			if context.rebirthButton then
				context.pointArrowAt(context.rebirthButton)
			end

			showText(context, "Good job, now get your first rebirth")

			return Promise.new(function(resolve, _reject, onCancel)
				local conn: Signal.Connection
				conn = ClientDataService.Signals.UpdateRebirths:Connect(function(currentRebirths: number)
					if currentRebirths >= 1 then
						conn:Disconnect()
						clearText(context)
						resolve(true)
					end
				end)

				onCancel(function()
					if conn then
						conn:Disconnect()
						clearText(context)
					end
				end)
			end)
		end,
		OnEnd = function(context)
			showText(context, "Tutorial completed! Good luck on your mining journey!")
			task.wait(2)
			clearText(context)
		end,
	},
}

return ClientTutorialConfig
