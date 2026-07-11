--!strict
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local Network = require(ReplicatedStorage.Source.Libs.Network)
local UIEffects = require(ReplicatedStorage.Source.Utility.UIEffects)
local formatTime = require(ReplicatedStorage.Source.Utility.formatTime)
local waitForChildInstanceAsync = require(ReplicatedStorage.Source.Utility.waitForChildInstanceAsync)
local waitForChildOfClassAsync = require(ReplicatedStorage.Source.Utility.waitForChildOfClassAsync)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

local localPlayer = assert(Players.LocalPlayer, "No player found")
local playerGui = localPlayer:WaitForChild("PlayerGui")

local hudUi = playerGui:WaitForChild("HUD")
local shopUi = playerGui:WaitForChild("Shop")

local mainFrame = shopUi:WaitForChild("Shop") :: Frame
local giftFrame = mainFrame:WaitForChild("Gifting") :: Frame
local shopContainer = waitForChildInstanceAsync(mainFrame, "Shop", "Container", "ShopContainer") :: ScrollingFrame
local giftContainer = waitForChildInstanceAsync(giftFrame, "Container", "GiftContainer") :: ScrollingFrame
local giftBuyButton = waitForChildInstanceAsync(giftFrame, "RobuxBuy", "GiftBuyButton") :: ImageButton
local giftBuyButtonPrice = waitForChildOfClassAsync(giftBuyButton, "TextLabel") :: TextLabel

local closeButton = mainFrame:FindFirstChild("CloseButton", true) :: ImageButton
local shopButton = hudUi:FindFirstChild("ShopButton", true) :: ImageButton
local luckTimer = shopContainer:FindFirstChild("Timer", true) :: TextLabel
local luckThread: thread? = nil

local frameSize = mainFrame.Size

local ShopController = {}

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size150x150

local currentlySelected: Frame?
local giftingInfo = {
	Id = nil,
	infoType = nil,
}

local buttonConnections = {}
local expiredProducts: { [number]: boolean } = {}

local function populateGiftFrame(player: Player)
	if not giftContainer then
		logger.log(`Gift container not found in Gifting Frame of Shop UI`, true)
		return
	end
	local userTemplate = giftContainer:FindFirstChild("User")
	if not userTemplate then
		logger.log(`User template frame not found in Gift Container of Shop UI`, true)
		return
	end

	local templateClone = userTemplate:Clone() :: Frame
	templateClone.Name = tostring(player.UserId)
	local profilePicture = templateClone:FindFirstChild("ProfilePicture", true) :: ImageLabel
	local username = templateClone:FindFirstChild("Username") :: TextLabel
	local displayName = templateClone:FindFirstChild("DisplayName") :: TextLabel
	local selectButton = templateClone:FindFirstChild("UserHitbox") :: ImageButton

	if username then
		username.Text = `@{player.Name}`
	end

	if displayName then
		displayName.Text = player.DisplayName
	end

	if profilePicture then
		local content, _ = Players:GetUserThumbnailAsync(player.UserId :: any, thumbType, thumbSize)
		profilePicture.Image = content
	end

	selectButton.Activated:Connect(function()
		if currentlySelected then
			currentlySelected.BackgroundColor3 = Color3.new(1, 1, 1)
		end

		if currentlySelected and currentlySelected == templateClone then
			currentlySelected = nil
			return
		end

		templateClone.BackgroundColor3 = Color3.new(0.788235, 0.133333, 0.133333)
		currentlySelected = templateClone
	end)

	templateClone.Visible = true
	templateClone.Parent = giftContainer
end

local function getPrice(id: any, infoType)
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfoAsync(id, infoType)
	end)

	if success and result then
		return result.PriceInRobux
	else
		logger.log(`Failed to get price: {tostring(result)}`, true)
		return nil
	end
end

local function setupBuyButton()
	if not shopContainer then
		logger.log(`No shop container found in Shop UI`, true)
		return
	end

	for _, descendant in shopContainer:GetDescendants() do
		if descendant:IsA("ImageButton") and descendant.Name == "BuyButton" then
			UIEffects.ApplyBounceClick(descendant)
			UIEffects.ApplyHoverEffect(descendant)
			UIEffects.ApplyClickSound(descendant)

			local priceLabel = descendant:FindFirstChildOfClass("TextLabel")

			local id = descendant:GetAttribute("GamepassId") or descendant:GetAttribute("ProductId")
			local infoType = descendant:GetAttribute("GamepassId") and Enum.InfoType.GamePass or Enum.InfoType.Product

			if id then
				local idNumber = tonumber(id)
				if idNumber and expiredProducts[idNumber] then
					if priceLabel then
						priceLabel.Text = "EXPIRED"
					end
					local parentFrame = descendant.Parent and descendant.Parent.Parent
					local timeLeftLabel = parentFrame and parentFrame:FindFirstChild("TimeLeft")
					if timeLeftLabel and timeLeftLabel:IsA("TextLabel") then
						timeLeftLabel.Visible = false
					end
				else
					local price = getPrice(id, infoType)
					if price and priceLabel then
						priceLabel.Text = `R$ {price}`
					elseif priceLabel then
						priceLabel.Text = "N/A"
					end
				end
			end

			buttonConnections[descendant] = descendant.Activated:Connect(function()
				if id then
					Network.fireServer(Network.RemoteEvents.ShopPurchase, id)
				end
			end)
		end

		if descendant:IsA("ImageButton") and descendant.Name == "GiftButton" then
			UIEffects.ApplyBounceClick(descendant)
			UIEffects.ApplyHoverEffect(descendant)
			UIEffects.ApplyClickSound(descendant)

			descendant.Activated:Connect(function()
				giftFrame.Visible = true

				if not giftBuyButton then
					return
				end

				local id = descendant:GetAttribute("GamepassId") or descendant:GetAttribute("ProductId")
				local infoType = descendant:GetAttribute("GamepassId") and Enum.InfoType.GamePass
					or Enum.InfoType.Product

				if id then
					giftingInfo = {
						Id = id,
						InfoType = infoType,
					}

					local price = getPrice(id, infoType)
					if price then
						giftBuyButtonPrice.Text = `R$ {price}`
					else
						giftBuyButtonPrice.Text = "N/A"
					end
				end
			end)
		end

		if descendant:IsA("TextButton") and descendant.Name == "ActivateButton" then
			local shouldOpen = false
			local connection: RBXScriptConnection?

			UIEffects.ApplyBounceClick(descendant)
			UIEffects.ApplyHoverEffect(descendant)
			UIEffects.ApplyClickSound(descendant)

			descendant.Activated:Connect(function()
				local screenName = descendant:GetAttribute("GuiName") :: string
				local screenGui = playerGui:WaitForChild(screenName)
				local activateFrame = screenGui:WaitForChild("MainFrame") :: Frame

				if connection then
					connection:Disconnect()
					connection = nil
				end
				shouldOpen = true

				mainFrame.Visible = not mainFrame.Visible
				connection = activateFrame:GetPropertyChangedSignal("Visible"):Connect(function()
					if activateFrame.Visible then
						return
					end

					if shouldOpen then
						mainFrame.Visible = true
					end

					shouldOpen = false
				end)

				UIEffects.ToggleBounceUI(activateFrame, not activateFrame.Visible)
			end)
		end
	end

	giftBuyButton.Activated:Connect(function()
		if giftingInfo.Id and giftingInfo.InfoType and currentlySelected then
			Network.fireServer(Network.RemoteEvents.ShopPurchase, giftingInfo.Id, currentlySelected.Name)
		end
	end)
end

local function setupPlayerConnections()
	for _, player in Players:GetPlayers() do
		if player == localPlayer then
			continue
		end
		populateGiftFrame(player)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		if player == localPlayer then
			return
		end

		populateGiftFrame(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		if not giftContainer then
			return
		end

		for _, child in giftContainer:GetChildren() do
			if child.Name ~= tostring(player.UserId) then
				continue
			end

			if child == currentlySelected then
				currentlySelected = nil
				child:Destroy()
			end
		end
	end)
end

local function updateBought(purchasedId: number)
	for _, descendant in shopContainer:GetDescendants() do
		if descendant:IsA("ImageButton") and descendant.Name == "BuyButton" then
			local id = descendant:GetAttribute("GamepassId") or descendant:GetAttribute("ProductId")

			if tonumber(id) == purchasedId then
				local buyButtonFrame = descendant.Parent
				local parentFrame = buyButtonFrame and buyButtonFrame.Parent
				local priceLabel = descendant:FindFirstChildOfClass("TextLabel")
				if not parentFrame or not priceLabel then
					return
				end

				local timeLabel = parentFrame:FindFirstChild("TimeLeft")
				if timeLabel and timeLabel:IsA("TextLabel") then
					timeLabel.Visible = false
				end
				priceLabel.Text = "BOUGHT"

				if buttonConnections[descendant] then
					buttonConnections[descendant]:Disconnect()
				end
			end
		end
	end
end

local function luckBoosted(endTime: number, currentLuck: number, multiplier: number, maxLuck: number)
	if luckThread then
		task.cancel(luckThread)
		luckThread = nil
	end

	local _, nextProductId = Network.invokeServerAsync(Network.RemoteFunctions.GetNextLuckProduct, localPlayer)
	if not nextProductId then
		return
	end

	local luckFrame = shopContainer:FindFirstChild("Luck")
	local buyButton = luckFrame and luckFrame:FindFirstChild("BuyButton", true)
	local luckIncrease = luckFrame and luckFrame:FindFirstChild("LuckIncrease") :: TextLabel
	if not buyButton or not luckIncrease then
		return
	end

	local defaultId = buyButton:GetAttribute("GamepassId") or buyButton:GetAttribute("ProductId")
	local nextPrice = getPrice(nextProductId, Enum.InfoType.Product)
	local defaultPrice = getPrice(defaultId, Enum.InfoType.Product)
	local priceLabel = buyButton:FindFirstChildOfClass("TextLabel")
	if not priceLabel then
		return
	end

	local nextLuck = math.min(maxLuck, currentLuck)
	local increaseText = `{multiplier ^ currentLuck}X -> {multiplier ^ (nextLuck + 1)}X`
	luckIncrease.Text = if nextLuck >= maxLuck then "+15 minutes(8X)" else increaseText

	priceLabel.Text = `R$ {nextPrice}`

	luckTimer.Visible = true

	luckThread = task.spawn(function()
		while true do
			local now = os.time()
			local remaining = endTime - now

			if remaining <= 0 then
				luckTimer.Text = "00:00"
				luckTimer.Visible = false

				priceLabel.Text = `R$ {defaultPrice}`
				break
			end

			luckTimer.Text = `Time left: {formatTime(remaining)}`

			task.wait(1)
		end

		luckThread = nil -- Clean up reference once finished
	end)
end

local function connectProductsTimer(timeLimit: number, id: number, playTime: number?)
	if not playTime then
		expiredProducts[id] = true
	end

	for _, buyButton in CollectionService:GetTagged("BuyButton") do
		if tonumber(buyButton:GetAttribute("ProductId")) ~= id then
			continue
		end

		local buyButtonFrame = buyButton.Parent
		local parentFrame = buyButtonFrame and buyButtonFrame.Parent
		if not parentFrame then
			return
		end

		local timeLeftLabel = parentFrame:WaitForChild("TimeLeft")
		local buyButtonLabel = waitForChildOfClassAsync(buyButton, "TextLabel") :: TextLabel
		if not (buyButtonLabel and timeLeftLabel and timeLeftLabel:IsA("TextLabel")) then
			continue
		end

		if not playTime then
			buyButtonLabel.Text = "EXPIRED"
			timeLeftLabel.Visible = false
			continue
		end

		local timeLeft = timeLimit - playTime

		task.spawn(function()
			while timeLeftLabel.Visible and timeLeft >= 0 do
				timeLeftLabel.Text = `{formatTime(timeLeft)}`
				timeLeft -= 1
				task.wait(1)
			end

			if timeLeft <= 0 then
				buyButtonLabel.Text = "EXPIRED"
				timeLeftLabel.Visible = false
				expiredProducts[id] = true
			end
		end)
	end
end

function ShopController.Start()
	setupBuyButton()
	UIEffects.ApplyBounceClick(closeButton)
	UIEffects.ApplyHoverEffect(closeButton)
	UIEffects.ApplyClickSound(closeButton)

	UIEffects.ApplyBounceClick(shopButton)
	UIEffects.ApplyHoverEffect(shopButton)
	UIEffects.ApplyClickSound(shopButton)

	UIEffects.ApplyBounceClick(giftBuyButton)
	UIEffects.ApplyHoverEffect(giftBuyButton)
	UIEffects.ApplyClickSound(giftBuyButton)

	closeButton.Activated:Connect(function()
		UIEffects.ToggleBounceUI(mainFrame, false)
	end)

	shopButton.Activated:Connect(function()
		UIEffects.ToggleBounceUI(mainFrame, not mainFrame.Visible, frameSize)
	end)

	setupPlayerConnections()

	mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if not mainFrame.Visible then
			giftFrame.Visible = false
			currentlySelected = nil
		end
	end)

	Network.connectEvent(Network.RemoteEvents.ShopPurchase, updateBought)
	Network.connectEvent(Network.RemoteEvents.LuckBoosted, luckBoosted)
end

Network.connectEvent(Network.RemoteEvents.ShopProductTimer, connectProductsTimer)

return ShopController
