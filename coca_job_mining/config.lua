Config = {}

Config.MaxMiningCount = 8

Config.MiningBlip = { x = 2992.85, y = 2753.84, z = 43.16 }

Config.Remelting = { x = 1109.03, y = -2007.61, z = 30.94 }

Config.Sell = { x = 246.66, y = 371.53, z = 104.33, heading = 154.63 }

Config.Ores = {
    ['iron'] = {
        label = 'Iron ore',
        weight = 1,
        canStack = true,
        price = 120.00,
        usetype = 'never',
        imgname = 'iron.png',
        category = "pawn",
        chance = 35,
    },
    ['gold'] = {
        label = 'Gold ore',
        weight = 0.4,
        canStack = true,
        price = 300.00,
        usetype = 'never',
        imgname = 'gold.png',
        category = "pawn",
        chance = 20, 
    },
    ['copper'] = {
        label = 'Copper ore',
        weight = 1,
        canStack = true,
        price = 150.00,
        usetype = 'never',
        imgname = 'copper.png',
        category = "pawn",
        chance = 30, 
    },
    ['diamond'] = {
        label = 'Diamond',
        weight = 0.1,
        canStack = false,
        price = 1200.00,
        usetype = 'never',
        imgname = 'Diamond.png',
        category = "pawn",
        chance = 2, 
    },
    ['ruby'] = {
        label = 'Ruby',
        weight = 0.1,
        canStack = false,
        price = 750.00,
        usetype = 'never',
        imgname = 'ruby.png',
        category = "pawn",
        chance = 5, 
    },
    ['bluediamond'] = {
        label = 'Blue Diamond',
        weight = 0.1,
        canStack = false,
        price = 500.00,
        usetype = 'never',
        imgname = 'bluediamond.png',
        category = "pawn",
        chance = 8, 
    },
}
