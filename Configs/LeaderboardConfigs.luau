--!strict

type Config = {
    read RefreshTime: number, -- How many seconds between updating the leaderboard stats
    read MaxPlayersDisplayed: number, -- The maximum number of players to show in the list
    read MemoryExpirationSeconds: number, -- How long before the MemoryStore items expire if not updated
    read PlacementColor: { -- ColorSequence to color the labels for first, second, third place (defaults to 'Other')
        read First: ColorSequence,
        read Second: ColorSequence,
        read Third: ColorSequence,
        read Other: ColorSequence,
    }
}

local LeaderboardConfigs: Config = {
    RefreshTime = 120,
    MaxPlayersDisplayed = 50,
    MemoryExpirationSeconds = 2592000, -- 2592000 expires in 30 days
    PlacementColor = {
        First = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 163, 16)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(255, 190, 37)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0)),
        }),
        Second = ColorSequence.new(Color3.new(1, 1, 1)),
        Third = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(131, 44, 12)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 67, 34)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(173, 111, 23)),
        }),
        Other = ColorSequence.new(Color3.fromRGB(107, 107, 107)),
    },
}

return LeaderboardConfigs
