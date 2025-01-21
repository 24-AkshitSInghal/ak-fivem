Config = {

    -- Debug mode
    debug       = false,

    -- Locale (en / zh / es)
    locale      = 'en',

    -- Which framework you are using, can be 'standalone', 'esx', 'esx1.9' or 'qbcore'
    framework   = 'standalone',

    -- Compatible with zerodream_vehplate script (0: only GTA plate, 1: only Chinese plate, 2: all)
    plateType = 0,

    -- Require stop the engine before parking car?
    stopEngine  = true,

    -- Allow park not owned vehicles?
    notOwnedCar = false,

    -- Locked car for everyone (included owner)?
    lockedCar   = true,

    -- Parking card item name
    parkingCard = 'parkingcard',

    -- Default key binding, use false to disable, player can change key binding in pause menu > settings > key binding > FiveM
    keyBinding  = {
        -- Park vehicle
        parkingVehicle = 'H',
    },

    -- Impound settings
    impound     = {
        loc = vector3(-191.949, -1162.354, 23.671),
        blipSprite = 357,
        blipColor  = 0,
    },

    parking     = {
        -- Parking id, should be unique, DO NOT USE 'global' AS PARKING ID
        ['parking_1']  = {
            name       = 'Centeral Garage',
            pos        = vec3(-320.1, -921.38, 30.0),
            size       = 50.0,  --area
            maxCars    = 10,
            allowTypes = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, -- for all vehicle category change to { -1 }, 
            parkingFee = 1000,                             -- Parking fee per day in real life time
            notify     = true,
            -- White list, can be identifier, ip and job name, player will not need to pay parking fee if they are in the whitelist
            whitelist  = {
                'identifier.steam:110000131d62281',
                'ip.127.0.0.1',
                'job.admin',
            },
            -- Black list of vehicle model
            blacklist  = {
            },
            showBlip = true,
            blipSprite = 357,
            blipColor  = 26,
        },
    },

    vehicleRenderDistance = 200,
}
