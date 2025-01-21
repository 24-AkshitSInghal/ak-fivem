-- to add item, first add item in Config.Items then add its png in ui/images/items also make the use function of it in use_function
-- also add the name in usefunctions and then implement it how to spawn that item in game


Config = {}

Config.invetoryData = {
    ['player'] = {
        MaxWeight = 60, -- in kg
        Slots = 35,
    },
    ['store'] = {
        MaxWeight = 2000, -- in kg
        Slots = 80,
    },
    ['glovebox'] = {
        MaxWeight = 10, -- in kg
        Slots = 80,
    },
    ['gangstash'] = {
        MaxWeight = 500, -- in kg
        Slots = 80,
    },
    ['motelstash'] = {
        MaxWeight = 500, -- in kg
        Slots = 80,
    },
    ['drop'] = {
        MaxWeight = 200, -- in kg
        Slots = 80,
    },
    ['mechanicstash'] = {
        MaxWeight = 250, -- in kg
        Slots = 80,
    },
    ['policestash'] = {
        MaxWeight = 1000, -- in kg
        Slots = 80,
    },
}

Config.Stashes = {
    ['tlmcmain'] = {
        stashname = "tlmcmain",
        coords = vector3(977.06, -103.813, 74.845),
        type = 'gangstash',
        color = { r = 140, g = 140, b = 140 },
        fraction = "tlmc",
        post = { 'leader', "righthand", "lefthand" }
    },
    ['tlmcsecondary'] = {
        stashname = "tlmcsecondary",
        coords = vector3(971.91, -99.01, 74.84),
        type = 'gangstash',
        color = { r = 140, g = 140, b = 140 },
        fraction = "tlmc",
        post = nil
    },
    ['ballasmain'] = {
        stashname = "ballasmain",
        coords = vector3(120.09, -1968.67, 21.328),
        type = 'gangstash',
        color = { r = 128, g = 0, b = 128 },
        fraction = "ballas",
        post = { 'leader', "righthand", "lefthand" }
    },
    ['ballassecondary'] = {
        stashname = "ballassecondary",
        coords = vector3(106.669, -1981.855, 20.96),
        type = 'gangstash',
        color = { r = 128, g = 0, b = 128 },
        fraction = "ballas",
        post = nil
    },
    ['gsfmain'] = {
        stashname = "gsfmain",
        coords = vector3(-157.614, -1603.10, 35.04),
        type = 'gangstash',
        color = { r = 119, b = 48, g = 172 },
        fraction = "gsf",
        post = { 'leader', "righthand", "lefthand" }
    },
    ['gsfsecondary'] = {
        stashname = "gsfsecondary",
        coords = vector3(-136.75, -1608.44, 35.03),
        type = 'gangstash',
        color = { r = 119, b = 48, g = 172 },
        fraction = "gsf",
        post = nil
    },
    ['vagosmain'] = {
        stashname = "vagosmain",
        coords = vector3(315.25, -2048.78, 20.97),
        type = 'gangstash',
        color = { r = 237, g = 177, b = 32 },
        fraction = "vagos",
        post = { 'leader', "righthand", "lefthand" }

    },
    ['vagossecondary'] = {
        stashname = "vagossecondary",
        coords = vector(323.98, -2057.59, 24.00),
        type = 'gangstash',
        color = { r = 237, g = 177, b = 32 },
        fraction = "vagos",
        post = nil
    },
    ['cartelmain'] = {
        stashname = "cartelmain",
        coords = vector3(1391.75, 1159.14, 114.33),
        type = 'gangstash',
        color = { r = 225, g = 140, b = 0 },
        fraction = "cartel",
        post = { 'leader', "righthand", "lefthand" }
    },
    ['cartelsecondary'] = {
        stashname = "cartelsecondary",
        coords = vector(1399.670, 1139.590, 114.335),
        type = 'gangstash',
        color = { r = 225, g = 140, b = 0 },
        fraction = "cartel",
        post = nil
    },
    ['marabuntamain'] = {
        stashname = "marabuntamain",
        coords = vector3(1445.08, -1488.53, 66.61),
        type = 'gangstash',
        color = { r = 0, g = 191, b = 255 },
        fraction = "marabunta",
        post = { 'leader', "righthand", "lefthand" }
    },
    ['marabuntasecondary'] = {
        stashname = "marabuntasecondary",
        coords = vector3(1436.97, -1489.02, 66.61),
        type = 'gangstash',
        color = { r = 0, g = 191, b = 255 },
        fraction = "marabunta",
        post = nil
    },
    ['bennysmain'] = {
        stashname = "bennysmain",
        coords = vector3(-41.71, -1067.25, 28.39),
        type = 'mechanicstash',
        color = { r = 0, g = 0, b = 0 },
        fraction = "mechanic",
        post = nil
    },
    ['policelocker'] = {
        stashname = "policelocker",
        coords = vector3(461.31, -982.49, 30.69),
        type = 'policestash',
        color = { r = 0, g = 0, b = 139 },
        fraction = "police",
        post = nil
    },
}


Config.Items = {

    -- ## tools

    ['lockpick'] = {
        label = 'Lockpick',
        weight = 0.4, -- in kg
        canStack = true,
        price = 1000.00,
        usetype = 'multipetime',
        imgname = 'lockpick.png',
        category = "tool",
        breakchance = 13 -- in %
    },
    ['phone'] = {
        label = 'Simple Phone',
        weight = 0.4,
        canStack = false,
        price = 3000.00,
        usetype = 'never',
        imgname = 'phone.png',
        category = "tool",
        breakchance = 0
    },
    ['radio'] = {
        label = 'Radio',
        weight = 1,
        canStack = false,
        price = 10000.00,
        usetype = 'never',
        imgname = 'radio.png',
        category = "tool",
        breakchance = 0
    },
    ['fishingrod'] = {
        label = 'Fishing Rod',
        weight = 0.5,
        canStack = false,
        price = 600.00,
        usetype = 'never',
        imgname = 'fishingrod.png',
        category = "tool",
        breakchance = 10 --> if change than change from coca_job_fishing too
    },
    ['pickaxe'] = {
        label = 'Pickaxe',
        weight = 2,
        canStack = false,
        price = 800.00,
        usetype = 'never',
        imgname = 'pickaxe.png',
        category = "tool",
        breakchance = 5
    },
    ['binoculars'] = {
        label = 'binoculars',
        weight = 1,
        canStack = false,
        price = 1200.00,
        usetype = 'multipetime',
        imgname = 'binoculars.png',
        category = "tool",
        breakchance = 0
    },
    ['enginerepairkit'] = {
        label = 'Engine repair kit',
        weight = 5,
        canStack = false,
        price = 0.00,
        usetype = 'onetime',
        imgname = 'enginerepairkit.png',
        category = "tool",
        breakchance = 5
    },

    -- ## material
    ['salvage'] = {
        label = 'Crushed Salvage',
        weight = 1,
        canStack = true,
        price = 0.00,
        usetype = 'onetime',
        imgname = 'salvage.png',
        category = "material",
        breakchance = 100 
    },
    ['rubber'] = {
        label = 'rubber',
        weight = 0.6,
        canStack = true,
        price = 0.00,
        usetype = 'never',
        imgname = 'rubber.png',
        category = "material",
        breakchance = 0 
    },
    ['wire'] = {
        label = 'wire',
        weight = 0.3,
        canStack = true,
        price = 0.00,
        usetype = 'never',
        imgname = 'wire.png',
        category = "material",
        breakchance = 0 
    },
    ['scrap'] = {
        label = 'scrap',
        weight = 0.7,
        canStack = true,
        price = 0.00,
        usetype = 'never',
        imgname = 'scrap.png',
        category = "material",
        breakchance = 0
    },
    ['electronics'] = {
        label = 'electronics',
        weight = 0.4,
        canStack = true,
        price = 0.00,
        usetype = 'never',
        imgname = 'electronics.png',
        category = "material",
        breakchance = 0 
    },
    ['steel'] = {
        label = 'steel',
        weight = 1,
        canStack = true,
        price = 0.00,
        usetype = 'never',
        imgname = 'steel.png',
        category = "material",
        breakchance = 0 
    },
    ['glass'] = {
        label = 'glass',
        weight = 0.3,
        canStack = true,
        price = 0.00,
        usetype = 'never',
        imgname = 'glass.png',
        category = "material",
        breakchance = 0 
    },
    ['aluminum'] = {
        label = 'aluminum',
        weight = 0.8,
        canStack = true,
        price = 0.00,
        usetype = 'never',
        imgname = 'aluminum.png',
        category = "material",
        breakchance = 0 
    },

    -- ## FISHES]
    ['salmon'] = {
        label = 'Salmon Fish',
        weight = 4.0, -- Average weight of a salmon
        canStack = false,
        price = 150.00,
        usetype = 'never',
        imgname = 'salmon.png',
        category = "fish",
        chance = 0.10
    },
    ['trout'] = {
        label = 'Trout Fish',
        weight = 2.0, -- Average weight of a trout
        canStack = true,
        price = 125.00,
        usetype = 'never',
        imgname = 'trout.png',
        category = "fish",
        chance = 0.15
    },
    ['char'] = {
        label = 'Char Fish',
        weight = 1.5, -- Average weight of a char
        canStack = false,
        price = 200.00,
        usetype = 'never',
        imgname = 'char.png',
        category = "fish",
        chance = 0.10
    },
    ['pike'] = {
        label = 'Pike Fish',
        weight = 3.0, -- Average weight of a pike
        canStack = false,
        price = 125.00,
        usetype = 'never',
        imgname = 'pike.png',
        category = "fish",
        chance = 0.08
    },
    ['goldfish'] = {
        label = 'Goldfish',
        weight = 0.1, -- Average weight of a goldfish
        canStack = false,
        price = 500.00,
        usetype = 'never',
        imgname = 'goldfish.png',
        category = "fish",
        chance = 0.02
    },
    ['whitefish'] = {
        label = 'White Fish',
        weight = 1.0, -- Average weight of a whitefish
        canStack = true,
        price = 75.00,
        usetype = 'never',
        imgname = 'whitefish.png',
        category = "fish",
        chance = 0.19
    },
    ['roach'] = {
        label = 'Roach Fish',
        weight = 0.2, -- Average weight of a roach
        canStack = true,
        price = 50.00,
        usetype = 'never',
        imgname = 'roach.png',
        category = "fish",
        chance = 0.20
    },
    ['mackerel'] = {
        label = 'Mackerel Fish',
        weight = 0.6, -- Average weight of a mackerel
        canStack = false,
        price = 100.00,
        usetype = 'never',
        imgname = 'mackerel.png',
        category = "fish",
        chance = 0.10
    },
    ['lobster'] = {
        label = 'Lobster Fish',
        weight = 1.0, -- Average weight of a lobster
        canStack = false,
        price = 300.00,
        usetype = 'never',
        imgname = 'lobster.png',
        category = "fish",
        chance = 0.02
    },
    ['crawfish'] = {
        label = 'Craw Fish',
        weight = 0.05, -- Average weight of a crawfish
        canStack = false,
        price = 100.00,
        usetype = 'never',
        imgname = 'crawfish.png',
        category = "fish",
        chance = 0.05
    }, 

    -- ## drugs

    ['oxy'] = {
        label = 'Oxy',
        weight = 0.1,
        canStack = true,
        price = 0.00,
        usetype = 'onetime',
        imgname = 'oxy.png',
        category = "drugs",
        breakchance = 100
    },

    -- ## stones

    ['stones'] = {
        label = 'Stones x 5',
        weight = 4, -- Average weight of a crawfish
        canStack = false,
        price = 0.00,
        usetype = 'never',
        imgname = 'stones.png',
        category = "stone",
    },
    ['washedstones'] = {
        label = 'Washed Stones x 5',
        weight = 3.5, -- Average weight of a crawfish
        canStack = false,
        price = 0.00,
        usetype = 'never',
        imgname = 'washedstones.png',
        category = "stone",
    },

    -- ## Pawn Items

    ['iron'] = {
        label = 'Iron ore',
        weight = 1, -- Average weight of a crawfish
        canStack = true,
        price = 120.00,
        usetype = 'never',
        imgname = 'iron.png',
        category = "pawn",
    },
    ['gold'] = {
        label = 'Gold ore',
        weight = 0.4, -- Average weight of a crawfish
        canStack = true,
        price = 300.00,
        usetype = 'never',
        imgname = 'gold.png',
        category = "pawn",
    },
    ['copper'] = {
        label = 'Copper ore',
        weight = 1, -- Average weight of a crawfish
        canStack = true,
        price = 150.00,
        usetype = 'never',
        imgname = 'copper.png',
        category = "pawn",
    },
    ['diamond'] = {
        label = 'Diamond',
        weight = 0.1, -- Average weight of a crawfish
        canStack = false,
        price = 1200.00,
        usetype = 'never',
        imgname = 'Diamond.png',
        category = "pawn",
    },
    ['ruby'] = {
        label = 'Ruby',
        weight = 0.1, -- Average weight of a crawfish
        canStack = false,
        price = 600.00,
        usetype = 'never',
        imgname = 'ruby.png',
        category = "pawn",
    },
    ['bluediamond'] = {
        label = 'Blue Diamond',
        weight = 0.1, -- Average weight of a crawfish
        canStack = false,
        price = 750.00,
        usetype = 'never',
        imgname = 'bluediamond.png',
        category = "pawn",
    },


    -- ## Consumables

    ['water'] = {
        label = 'Water',
        weight = 0.15,
        canStack = true,
        price = 20.00,
        usetype = 'onetime',
        imgname = 'water.png',
        category = "consumable",
        breakchance = 100
    },
    ['sandwich'] = {
        label = 'Sandwich',
        weight = 0.15,
        canStack = true,
        price = 40.00,
        usetype = 'onetime',
        imgname = 'sandwich.png',
        category = "consumable",
        breakchance = 100
    },
    ['bread'] = {
        label = 'Bread',
        weight = 0.10,
        canStack = true,
        price = 30.00,
        usetype = 'onetime',
        imgname = 'bread.png',
        category = "consumable",
        breakchance = 100
    },
    ['sportsdrink'] = {
        label = 'Green Sports Drink',
        weight = 0.20,
        canStack = true,
        price = 60.00,
        usetype = 'onetime',
        imgname = 'sportsdrink.png',
        category = "consumable",
        breakchance = 100
    },
    ['bandage'] = {
        label = 'Bandage',
        weight = 0.10,
        canStack = true,
        price = 30.00,
        usetype = 'onetime',
        imgname = 'bandage.png',
        category = "consumable",
        breakchance = 100
    },
    ['medicines'] = {
        label = 'Medicines',
        weight = 0.10,
        canStack = true,
        price = 20.00,
        usetype = 'onetime',
        imgname = 'medicines.png',
        category = "consumable",
        breakchance = 100
    },
    ['firstaidkit'] = {
        label = 'First Aid Kit',
        weight = 0.40,
        canStack = true,
        price = 100.00,
        usetype = 'onetime',
        imgname = 'firstaidkit.png',
        category = "consumable",
        breakchance = 100
    },
    ['bait'] = {
        label = 'Fishing Bait',
        weight = 0.10,
        canStack = true,
        price = 30.00,
        usetype = 'onetime',
        imgname = 'bait.png',
        category = "consumable",
        breakchance = 100
    },

    -- items

    ['carkey'] = {
        label = 'carkey',
        weight = 0.1,
        canStack = false,
        price = 0.00,
        usetype = 'never',
        imgname = 'carkey.png',
        category = "item",
        breakchance = 0
    },

    -- wearable

    ['mininghelmet'] = {
        label = 'Mining Helmet',
        weight = 1,
        canStack = false,
        price = 350.00,
        usetype = 'never',
        imgname = 'mininghelmet.png',
        category = "wearable",
        breakchance = 10
    },

    -- ## Weapons

    ['assaultrifle'] = {
        label = 'Assault Rifle',
        weight = 3.5,
        canStack = false,
        price = nil,
        usetype = 'never',
        imgname = 'assaultrifle.png',
        category = "weapon",
        breakchance = 0,
        weaponHash = -1074790547,
    },
    ['flaregun'] = {
        label = 'Flare Gun',
        weight = 1.0,
        canStack = false,
        price = nil,
        usetype = 'never',
        imgname = 'flaregun.png',
        category = "weapon",
        breakchance = 0,
        weaponHash = 0x47757124,
    },
    ['pistol'] = {
        label = 'Pistol',
        weight = 1.0,
        canStack = false,
        price = 3500,
        usetype = 'never',
        imgname = 'pistol.png',
        category = "weapon",
        breakchance = 0,
        weaponHash = 0x1B06D571,
    },

    -- ## Mission Keys

    ['weaponfactoykey'] = {
        label = 'Unknown Key',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'weaponfactoykey.png',
        category = "mission",
        breakchance = 0
    },
    ['policelockercard'] = {
        label = 'PD Locker Card',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'policelockercard.png',
        category = "mission",
        breakchance = 0
    },
    ['vanillacard'] = {
        label = 'VU Access Card',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'vanillacard.png',
        category = "mission",
        breakchance = 0
    },
    ['vunormalcard'] = {
        label = 'VU Lapdance Card',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'vunormalcard.png',
        category = "mission",
        breakchance = 100
    },
    ['vuwildcard'] = {
        label = 'VU Wild Lapdance Card',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'vuwildcard.png',
        category = "mission",
        breakchance = 100
    },
    ['weaponstorekey'] = {
        label = 'Weapon Store Key',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'weaponstorekey.png',
        category = "mission",
        breakchance = 0
    },
    ['weedfactorykey'] = {
        label = 'Unknown Key',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'weedfactorykey.png',
        category = "mission",
        breakchance = 0
    },
    ['methlabkey'] = {
        label = 'Unknown Key',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'methlabkey.png',
        category = "mission",
        breakchance = 0
    },
    ['cocainwarehousekey'] = {
        label = 'Unknown Key',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'cocainwarehousekey.png',
        category = "mission",
        breakchance = 0
    },
    ['accesscard'] = {
        label = 'Syndicate Bunder Key',
        weight = 0.1,
        canStack = false,
        price = nil,
        type = 'never',
        imgname = 'accesscard.png',
        category = "mission",
        breakchance = 0
    },

    -- #Ammos

    ['76239mm'] = {
        label = '7.62×39mm x 30',
        weight = 3.0,
        canStack = true,
        price = 2100,
        type = 'onetime',
        imgname = '76239mm.png',
        category = "ammo",
        breakchance = 100,
        ammocount = 30,
    },
    ['flareammo'] = {
        label = 'Flare Ammo',
        weight = 0.2,
        canStack = false,
        price = nil,
        type = 'onetime',
        imgname = 'flareammo.png',
        category = "ammo",
        breakchance = 100,
        ammocount = 1,
    },
}

Config.VehicleLimit = {
    ['Compacts'] = 25.00,
    ['Sedans'] = 30.00,
    ['SUVs'] = 35.00,
    ['Coupes'] = 25.00,
    ['Muscle'] = 30.00,
    ['Sports Classics'] = 25.00,
    ['Sports'] = 25.00,
    ['Super'] = 20.00,
    ['Motorcycles'] = 0.00,
    ['Off-road'] = 20.00,
    ['Industrial'] = 50.00,
    ['Utility'] = 25.00,
    ['Vans'] = 40.00,
    ['Cycles'] = 0.00,
    ['Boats'] = 0.00,
    ['Helicopters'] = 0.00,
    ['Planes'] = 0.00,
    ['Service'] = 0.00,
    ['Emergency'] = 0.00,
    ['Military'] = 0.00,
    ['Commercial'] = 60.00,
    ['Trains'] = 0.00
}

exports("getItemConfig", Config.Items)


Config.Shops = {
    ["General Store"] = {
        Locations = {
            { x = 373.875,   y = 325.896,   z = 102.566 },
            { x = 2557.458,  y = 382.282,   z = 107.622 },
            { x = -3038.939, y = 585.954,   z = 6.908 },
            { x = -3241.927, y = 1001.462,  z = 11.830 },
            { x = 547.431,   y = 2671.710,  z = 41.156 },
            { x = 1961.464,  y = 3740.672,  z = 31.343 },
            { x = 2678.916,  y = 3280.671,  z = 54.241 },
            { x = 1729.216,  y = 6414.131,  z = 34.037 },
            { x = -48.519,   y = -1757.514, z = 28.421 },
            { x = 1163.373,  y = -323.801,  z = 68.205 },
            { x = -707.501,  y = -914.260,  z = 18.215 },
            { x = -1820.523, y = 792.518,   z = 137.118 },
            { x = 1698.388,  y = 4924.404,  z = 41.063 },
            { x = 25.723,    y = -1346.966, z = 28.497 },
        },
        Items = {
            { name = 'phone' },
            { name = 'bread' },
            { name = 'water' },
            { name = 'sandwich' },
            { name = 'sportsdrink' },
            { name = 'bandage' },
            { name = 'firstaidkit' },
            { name = 'bait' },
        },
        blipSprite = 52, -- example sprite for convenience store
        blipColour = 82, -- example colour for convenience store
        type = "Convenience Store"
    },

    ["Liquor Shop"] = {
        Locations = {
            { x = 1135.808,  y = -982.281, z = 45.415 },
            { x = -1222.915, y = -906.983, z = 11.326 },
            { x = -1487.553, y = -379.107, z = 39.163 },
            { x = -2968.243, y = 390.910,  z = 14.043 },
            { x = 1166.024,  y = 2708.930, z = 37.157 },
            { x = 1392.562,  y = 3604.684, z = 33.980 },
            { x = -1393.409, y = -606.624, z = 29.319 }
        },
        Items = {
            { name = 'beer' },
            { name = 'wine' },
            { name = 'vodka' },
            { name = 'tequila' },
            { name = 'whisky' },
        },
        blipSprite = 93, -- example sprite for liquor store
        blipColour = 0,  -- example colour for liquor store
        type = "Liquor Store"
    },

    ["Tool Shop"] = {
        Locations = {
            { x = 45.2,     y = -1748.43, z = 28.6 },
            { x = 2748.6,   y = 3473.14,  z = 54.70 },
            { x = -3153.36, y = 1054.41,  z = 19.86 }
        },
        Items = {
            { name = 'lockpick' },
            { name = 'binoculars' },
            { name = 'bulletproof' },
            { name = 'boltcutter' },
            { name = 'torch' },
            { name = 'pickaxe' },
            { name = 'fishingrod' },
            { name = 'radio' },
        },
        blipSprite = 105, -- example sprite for hardware store
        blipColour = 0,   -- example colour for hardware store
        type = "Hardware Store"
    },

    ["Weapon Locker"] = {
        Locations = {
            { x = 460.17, y = -979.39, z = 30.69 },
        },
        Items = {
            { name = 'nightstick' },
            { name = 'torch' },
            { name = 'stungun' },
            { name = 'pistolmkii' },
            { name = 'combatpistol' },
            { name = 'smg' },
            { name = 'advancerifle' },
            { name = 'pumpshortgun' },
            { name = 'bulletproof' },
            { name = '9mm' },
            { name = '76239mm' },
            { name = '12gauge' },
        },
        blipSprite = 60, -- example sprite for prison shop
        blipColour = 63, -- example colour for prison shop
        type = "Police Station"
    },

    ["Weapon Shop"] = {
        Locations = {
            { x = -662.180,  y = -934.961, z = 20.829 },
            { x = 810.25,    y = -2157.60, z = 28.62 },
            { x = 1693.44,   y = 3760.16,  z = 33.71 },
            { x = -330.24,   y = 6083.88,  z = 30.45 },
            { x = 252.63,    y = -50.00,   z = 68.94 },
            { x = 22.09,     y = -1107.28, z = 28.80 },
            { x = 2567.69,   y = 294.38,   z = 107.73 },
            { x = -1117.58,  y = 2698.61,  z = 17.55 },
            { x = 842.44,    y = -1033.42, z = 27.19 },
            { x = -3172.079, y = 1088.341, z = 20.039 },
        },
        Items = {
            { name = 'pistol' },
            { name = 'vintagepistol' },
            { name = 'snspisol' },
            { name = '9mm' },
            { name = '76239mm' },
            { name = '12gauge' },
        },
        blipSprite = 110, -- example sprite for weapon shop
        blipColour = 0,   -- example colour for weapon shop
        type = "Weapon Shop"
    },
}

Config.WeaponAmmo = {
    ['9mm'] = 220,
    [584646201] = "9mm", -- AP SMG
    [0x1B06D571] = "9mm",

    ['flareammo'] = 1,
    [0x47757124] = "flareammo", -- flaregun

    ['76239mm'] = 250,
    [-1074790547] = "76239mm", -- Assault Rifle

}
