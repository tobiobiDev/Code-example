--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MutationInfoType = require(ReplicatedStorage.Source.Types.MutationInfoType)

export type BaseColor = MutationInfoType.BaseColor

local MutationsConfig: MutationInfoType.MutationType = {
	Chance = {
		Gold = 50,
		Diamond = 35,
		Ruby = 12,
		Blaze = 3,
		Normal = 0,
	},

	Multiplier = {
		Normal = 1,
		Gold = 1.5,
		Diamond = 2.5,
		Ruby = 5,
		Blaze = 8.5,
	},

	Color = {
		Normal = Color3.new(1, 1, 1),
		Gold = Color3.new(1, 0.882353, 0),
		Diamond = Color3.new(0, 1, 0.917647),
		Ruby = Color3.new(0.882353, 0.117647, 0.117647),
		Blaze = Color3.new(1, 0.317647, 0),
	},

	SkinCashBoost = {
		Normal = 0,
		Silver = 15,
		Gold = 35,
		Diamond = 75,
		Ruby = 150,
		Blaze = 300,
	},

	BaseColors = {
		Normal = {
			Primary = Color3.new(0.357, 0.365, 0.412),
			Secondary = Color3.new(0.447, 0.455, 0.514),
			Tertiary = Color3.new(0.357, 0.365, 0.412),
		},
		Silver = {
			Primary = Color3.new(0.12549, 0.560784, 0.792157),
			Secondary = Color3.new(0.00784314, 0.866667, 1),
			Tertiary = Color3.new(0.611765, 0.611765, 0.611765),
		},
		Diamond = {
			Primary = Color3.new(0.12549, 0.560784, 0.792157),
			Secondary = Color3.new(0.00784314, 0.866667, 1),
			Tertiary = Color3.new(0.611765, 0.611765, 0.611765),
		},
		Gold = {
			Primary = Color3.new(0.792157, 0.603922, 0.0470588),
			Secondary = Color3.new(1, 0.501961, 0),
			Tertiary = Color3.new(0.611765, 0.611765, 0.611765),
		},
		Ruby = {
			Primary = Color3.new(0.792157, 0.133333, 0.2),
			Secondary = Color3.new(1, 0, 0.0156863),
			Tertiary = Color3.new(0.427451, 0.105882, 0.105882),
		},
		Blaze = {
			Primary = Color3.new(0.792157, 0.133333, 0.2),
			Secondary = Color3.new(1, 0, 0.0156863),
			Tertiary = Color3.new(0.427451, 0.105882, 0.105882),
		},
	},

	MutationImage = {
		Blaze = "rbxassetid://138021450456712",
		Diamond = "rbxassetid://122412147457508",
		Gold = "rbxassetid://92313051515730",
		Ruby = "rbxassetid://123175952407096",
	}
}

return MutationsConfig
