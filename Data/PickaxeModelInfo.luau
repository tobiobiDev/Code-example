local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PickaxeModelInfoType = require(ReplicatedStorage.Source.Types.PickaxeModelInfoType)

local PickaxeModelInfo: PickaxeModelInfoType.PickaxeModel = {
    [0] = "Bronze",
    [10] = "Emerald",
    [20] = "Demonite",
}



return PickaxeModelInfo
