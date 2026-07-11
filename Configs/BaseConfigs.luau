--!strict

type BaseConfigs = {
	read MaxCharactersPerFloor: number,
	read CashTickerUpdateInterval: number,
}

local BaseConfigs: BaseConfigs = {
    MaxCharactersPerFloor = 8,
	CashTickerUpdateInterval = 0.1, -- How frequently to have the cash tickers update
}

return BaseConfigs
