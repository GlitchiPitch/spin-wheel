local Constants = {
	PLAYER_ATTRIBUTE = "SpinWheel",
	DATA_STORE_NAME = "SpinWheel_1",
	TIMER_DURATION_SEC = 30,
	CLAIMED_COOLDOWN_SEC = 2 * 60,
	STATES = {
        CAN_CLAIM = "canClaim",
        CLAIMED = "claimed",
        TIMER = "timer",
    },
    REMOTE_EVENTS = {
        TIME_PASSED = "timePassed",
        CLAIM_REWARD = "claimReward",
    },
	REWARDS = {
		upgrade = {
			image = "rbxassetid://114440493073627",
			desc = "Upgrade your account",
			name = "upgrade",
			displayName = "Прокачку",
			weight = 1,
		},
		robux = {
			image = "rbxassetid://114440493073627",
			desc = "Free Robux",
			name = "robux",
			displayName = "Робуксы",
			weight = 2,
		},
		coins = {
			image = "rbxassetid://114440493073627",
			desc = "In-game coins",
			name = "coins",
			displayName = "Монеты",
			weight = 5,
		},
	},
}

return Constants