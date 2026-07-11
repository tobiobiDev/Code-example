--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Source.Utility.Logger)
local formatNumber = require(ReplicatedStorage.Source.Utility.formatNumber)

local logger = Logger.new({
	Debug = false,
	Prefix = script.Name,
})

local DEFAULT_IMAGE = "rbxassetid://7992557358"

local BaseInterfaceService = {}

function BaseInterfaceService.UpdateCashAmount(displayModel: Model, amount: string)
	local cashAmountButton = displayModel:FindFirstChild("CashAmount", true)
	if not cashAmountButton then
		return
	end

	local cashAmountLabel = cashAmountButton:FindFirstChild("Amount")
	if cashAmountLabel and cashAmountLabel:IsA("TextLabel") then
		cashAmountLabel.Text = amount
	end
end

function BaseInterfaceService.UpdateOfflineEarning(displayModel: Model, amountText: string)
	local cashEarnedOfflinePart = displayModel:FindFirstChild("CashEarnedOffline")
	local earnedOfflineGui = cashEarnedOfflinePart and cashEarnedOfflinePart:FindFirstChild("BillboardGui")
	if not earnedOfflineGui then
		return
	end

	local earnedOfflineAmount = earnedOfflineGui:FindFirstChild("Amount")
	if earnedOfflineAmount and earnedOfflineAmount:IsA("TextLabel") then
		earnedOfflineAmount.Visible = true
		earnedOfflineAmount.Text = amountText
	end
end

function BaseInterfaceService.UpdateTotalEarning(totalEarning: string | number, baseModel: Model)
	local billboardGuiPart = baseModel:FindFirstChild("BaseBillboardUI")
	if not billboardGuiPart then
		return
	end

	local billboardGui = billboardGuiPart:FindFirstChildOfClass("BillboardGui")
	if not billboardGui then
		return
	end

	local cashLabel = billboardGui:FindFirstChild("CashPerSecond") :: TextLabel
	if cashLabel then
        local cashEarningText = if type(totalEarning) == "number" then formatNumber(totalEarning, 2) else totalEarning
        cashLabel.Text = `Total cash per second: ${cashEarningText}/s`
	end
end

function BaseInterfaceService.UpdateUpgradeUI(displayModel: Model, levelText: string?, priceText: string?)
	local upgradeButton = displayModel:FindFirstChild("UpgradeButton", true)
	if not upgradeButton then
		logger.log(`Failed to update Upgrade UI: Failed to find "UpgradeButton" in {displayModel.Name}`, true)
		return
	end

	local levelLabel = upgradeButton:FindFirstChild("Level")
	local priceLabel = upgradeButton:FindFirstChild("Price")

	if levelLabel and levelLabel:IsA("TextLabel") and levelText then
		levelLabel.Text = levelText
	end

	if priceLabel and priceLabel:IsA("TextLabel") and priceText then
		priceLabel.Text = priceText
	end
end

local function updateBaseBillboard(baseFolder: Instance, player: Player?)
	local billboardGuiPart = baseFolder:FindFirstChild("BaseBillboardUI")
	if not billboardGuiPart then
		return
	end

	local billboardGui = billboardGuiPart:FindFirstChildOfClass("BillboardGui")
	if not billboardGui then
		return
	end

	billboardGui.Enabled = true
	local playerImage = billboardGui:FindFirstChild("PlayerImage")
	local usernameLabel = billboardGui:FindFirstChild("Username")

	if player then
		if playerImage and playerImage:IsA("ImageLabel") then
            task.spawn(function()
                local success, content = pcall(function()
					return Players:GetUserThumbnailAsync(
                        player.User,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size150x150
                    )
				end)
                if success then
                    playerImage.Image = content
                else
                    playerImage.Image = DEFAULT_IMAGE
                end
            end)
		end

		if usernameLabel and usernameLabel:IsA("TextLabel") then
			usernameLabel.Text = player.Name
		end
	else
		billboardGui.Enabled = false
	end
end

--[[
	Resets bases GUI back to default
]]
function BaseInterfaceService.ResetBaseGui(baseModel: Model, player: Player?)
	for _, floorFolder in baseModel:GetChildren() do
		if not string.match(floorFolder.Name, "Floor") then
			continue
		end

		for _, displayModel in floorFolder:GetChildren() do
			if not (string.match(displayModel.Name, "Display") and displayModel:IsA("Model")) then
				continue
			end

			BaseInterfaceService.UpdateCashAmount(displayModel, "$0")
			BaseInterfaceService.UpdateOfflineEarning(displayModel, "")
			BaseInterfaceService.UpdateUpgradeUI(displayModel, "", "")
		end
	end

	BaseInterfaceService.UpdateTotalEarning("???", baseModel)
	updateBaseBillboard(baseModel, player)
end

function BaseInterfaceService.ResetFloorUI(baseModel: Model, floorName: string)
	local floorFolder = baseModel:FindFirstChild(floorName)
	if not floorFolder then
		return
	end

	for _, child in floorFolder:GetChildren() do
		if child:IsA("Model") and string.find(child.Name, "Display") then
			BaseInterfaceService.UpdateCashAmount(child, "0")
			BaseInterfaceService.UpdateOfflineEarning(child, "")
			BaseInterfaceService.UpdateUpgradeUI(child, "", "")
		end
	end
end

return BaseInterfaceService
