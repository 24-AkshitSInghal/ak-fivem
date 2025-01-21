Config = {}
Config.Fishes = {
    ['salmon'] = {
        ['name'] = 'salmon',
        ['label'] = 'Salmon',
        ['chance'] = 0.10, -- 10% chance of catching a salmon
    },
    ['trout'] = {
        ['name'] = 'trout',
        ['label'] = 'Trout',
        ['chance'] = 0.15, -- 15% chance of catching a trout
    },
    ['char'] = {
        ['name'] = 'char',
        ['label'] = 'Char',
        ['chance'] = 0.10, -- 10% chance of catching a char
    },
    ['pike'] = {
        ['name'] = 'pike',
        ['label'] = 'Pike',
        ['chance'] = 0.08, -- 8% chance of catching a pike
    },
    ['goldfish'] = {
        ['name'] = 'goldfish',
        ['label'] = 'Goldfish',
        ['chance'] = 0.01, -- 2% chance of catching a goldfish
    },
    ['whitefish'] = {
        ['name'] = 'whitefish',
        ['label'] = 'White Fish',
        ['chance'] = 0.19, -- 18% chance of catching a whitefish
    },
    ['roach'] = {
        ['name'] = 'roach',
        ['label'] = 'Roach',
        ['chance'] = 0.20, -- 20% chance of catching a roach
    },
    ['mackerel'] = {
        ['name'] = 'mackerel',
        ['label'] = 'Mackerel',
        ['chance'] = 0.10, -- 10% chance of catching a mackerel
    },
    ['lobster'] = {
        ['name'] = 'lobster',
        ['label'] = 'Lobster',
        ['chance'] = 0.02, -- 2% chance of catching a lobster
    },
    ['crawfish'] = {
        ['name'] = 'crawfish',
        ['label'] = 'Craw Fish',
        ['chance'] = 0.05, -- 5% chance of catching a crawfish
    },
}

Config.Locations = {
    --los_santos_pier
    { ["x"] = -1852.014, ["y"] = -1248.75,  ["z"] = 8.61,   ["h"] = 140.70,  ['position'] = 'los_santos_pier', ['fishes'] = { 'mackerel', 'roach', 'whitefish', 'goldfish', 'trout', 'pike' } },
    -- --chumash_pier
    { ["x"] = -3428.312, ["y"] = 978.115,   ["z"] = 8.346,  ["h"] = 97.41,   ['position'] = 'chumash_pier',    ['fishes'] = { 'mackerel', 'roach', 'whitefish', 'goldfish', 'trout', 'pike' } },
    --paleto_cove
    { ["x"] = -1612.862, ["y"] = 5262.573,  ["z"] = 3.974,  ["h"] = 32.252,  ['position'] = 'paleto_cove',     ['fishes'] = { 'mackerel', 'roach', 'whitefish', 'goldfish', 'trout', 'pike' } },
    --lighthouse
    { ["x"] = 3867.39,   ["y"] = 4462.628,  ["z"] = 2.7240, ["h"] = 277.77,  ['position'] = 'lighthouse',      ['fishes'] = { 'mackerel', 'roach', 'whitefish', 'goldfish', 'trout', 'pike' } },
    --yacht
    { ["x"] = -2099.880, ["y"] = -1019.595, ["z"] = 8.971,  ["h"] = 173.36,  ['position'] = 'yacht',           ['fishes'] = { 'goldfish', 'lobster', 'crawfish', 'salmon', 'char', 'trout' } },   --klar
    --alamo_sea_pier
    { ["x"] = 1299.313,  ["y"] = 4215.784,  ["z"] = 33.96,  ["h"] = 174.910, ['position'] = 'alamo_sea_pier',  ['fishes'] = { 'mackerel', 'roach', 'whitefish', 'goldfish', 'trout', 'pike' } },
    --train_passage
    { ["x"] = -508.62,   ["y"] = 4423.89,   ["z"] = 89.636, ["h"] = 286.164, ['position'] = 'train_passage',   ['fishes'] = { 'salmon', 'goldfish' } },               --klar
    --mountain_river
    { ["x"] = -860.486,  ["y"] = 4437.512,  ["z"] = 15.219, ["h"] = 228.95,  ['position'] = 'mountain_river',  ['fishes'] = { 'goldfish', 'lobster', 'crawfish' } },  --klar
}

Config.sellinglocation = {x = 89.1, y = -2564.07, z = 5.00, heading= 4.07}
