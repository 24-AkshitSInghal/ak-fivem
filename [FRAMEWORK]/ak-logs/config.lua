Config = {
    ServerName = "Simple RP Logs",                                                                                                                                                                                          -- Server Name
    ServerLogo =
    "https://media.discordapp.net/attachments/1253281068132470795/1258962816422117426/icon.png?ex=6689f3fd&is=6688a27d&hm=53f0f350626f4c03dcb71ca01c4bf6f780dc8da0771b928931beca40f3573f29&=&format=webp&quality=lossless", -- Server Logo
    MainIdentifier = "license",                                                                                                                                                                                             -- Identifier Type (steam, license, xbl, discord, ip)

    Webhooks = {
        -- Screenshot Storage Webhook
        ["screenshots"] =
        "https://discord.com/api/webhooks/1258962241437569075/n3KXytxklAJXISnJu8DWKI7Fb9QOCFxOxqY6yyLsiwTqTl73L1t0e5HkOB2k9xaN4x5E",

        -- Category Webhooks
        ["join/leave"] =
        "https://discord.com/api/webhooks/1258975005090516993/sFdn5sDhLhbMCU1AhKKSx037i-tDSFIVydQiBsrPcW94d-RQCwa97P5Pm9NTU4OLMzc5",
        ["resources"] =
        "https://discord.com/api/webhooks/1258975358171086888/pb6TOSA9DV0CGFxzYq2xbHCaYuRfDsAYXE7lKhWHJuLE6NS30Qber-7vBeoCywGpn_6H",
        ["aim"] =
        "https://discord.com/api/webhooks/1259586075194687599/g0UgIiZfddC2aUwC7jIOdec1WEGQNSBzoIgCZIor_i5BAx72CIJf28eHKERoadLqHS1v",
        ["explosions"] =
        "https://discord.com/api/webhooks/1258961344216956940/1Uxd4mLKDO5LnDL_vBI9Y1cfe5VXvQhG0BDHTNtWoZKzgDR2YgiDB3KQrogSOwi8C0E4",
        ["chat"] =
        "https://discord.com/api/webhooks/1258985219231322172/GKSpJAqaFnT0MFe1cE_mI_mX0aRzjrPFmZhlYEFSE5n2y_Zg8pdwZlVuHSWhEdMYMB-k",
        ["player_deaths"] =
        "https://discord.com/api/webhooks/1259005860143697930/Jvskr0kAJ_F8puEka8WgpnH7gyHXqXkfIEn0dqz7wuDi7Df-5Azc1behAI7fr-20PgbJ",
    },

    WeaponLabels = {
        -- Melee Weapons
        ['WEAPON_UNARMED'] = 'Unarmed',
        ['GADGET_PARACHUTE'] = 'Parachute',
        ['WEAPON_KNIFE'] = 'Knife',
        ['WEAPON_NIGHTSTICK'] = 'Nightstick',
        ['WEAPON_HAMMER'] = 'Hammer',
        ['WEAPON_BAT'] = 'Baseball Bat',
        ['WEAPON_CROWBAR'] = 'Crowbar',
        ['WEAPON_GOLFCLUB'] = 'Golf Club',
        ['WEAPON_BOTTLE'] = 'Bottle',
        ['WEAPON_DAGGER'] = 'Antique Cavalry Dagger',
        ['WEAPON_HATCHET'] = 'Hatchet',
        ['WEAPON_KNUCKLE'] = 'Knuckle Duster',
        ['WEAPON_MACHETE'] = 'Machete',
        ['WEAPON_FLASHLIGHT'] = 'Flashlight',
        ['WEAPON_SWITCHBLADE'] = 'Switchblade',
        ['WEAPON_BATTLEAXE'] = 'Battleaxe',
        ['WEAPON_POOLCUE'] = 'Poolcue',
        ['WEAPON_PIPEWRENCH'] = 'Wrench',
        ['WEAPON_STONE_HATCHET'] = 'Stone Hatchet',

        -- Handguns
        ['WEAPON_PISTOL'] = 'Pistol',
        ['WEAPON_PISTOL_MK2'] = 'Pistol Mk2',
        ['WEAPON_COMBATPISTOL'] = 'Combat Pistol',
        ['WEAPON_PISTOL50'] = 'Pistol .50',
        ['WEAPON_SNSPISTOL'] = 'SNS Pistol',
        ['WEAPON_SNSPISTOL_MK2'] = 'SNS Pistol Mk2',
        ['WEAPON_HEAVYPISTOL'] = 'Heavy Pistol',
        ['WEAPON_VINTAGEPISTOL'] = 'Vintage Pistol',
        ['WEAPON_MARKSMANPISTOL'] = 'Marksman Pistol',
        ['WEAPON_REVOLVER'] = 'Heavy Revolver',
        ['WEAPON_REVOLVER_MK2'] = 'Heavy Revolver Mk2',
        ['WEAPON_DOUBLEACTION'] = 'Double-Action Revolver',
        ['WEAPON_APPISTOL'] = 'AP Pistol',
        ['WEAPON_STUNGUN'] = 'Stun Gun',
        ['WEAPON_FLAREGUN'] = 'Flare Gun',
        ['WEAPON_RAYPISTOL'] = 'Up-n-Atomizer',

        -- Submachine Guns
        ['WEAPON_MICROSMG'] = 'Micro SMG',
        ['WEAPON_MACHINEPISTOL'] = 'Machine Pistol',
        ['WEAPON_MINISMG'] = 'Mini SMG',
        ['WEAPON_SMG'] = 'SMG',
        ['WEAPON_SMG_MK2'] = 'SMG Mk2',
        ['WEAPON_ASSAULTSMG'] = 'Assault SMG',
        ['WEAPON_COMBATPDW'] = 'Combat PDW',
        ['WEAPON_MG'] = 'MG',
        ['WEAPON_COMBATMG'] = 'Combat MG',
        ['WEAPON_COMBATMG_MK2'] = 'Combat MG Mk2',
        ['WEAPON_GUSENBERG'] = 'Gusenberg Sweeper',
        ['WEAPON_RAYCARBINE'] = 'Unholy Deathbringer',

        -- Rifles
        ['WEAPON_ASSAULTRIFLE'] = 'Assault Rifle',
        ['WEAPON_ASSAULTRIFLE_MK2'] = 'Assault Rifle Mk2',
        ['WEAPON_CARBINERIFLE'] = 'Carbine Rifle',
        ['WEAPON_CARBINERIFLE_MK2'] = 'Carbine Rifle Mk2',
        ['WEAPON_ADVANCEDRIFLE'] = 'Advanced Rifle',
        ['WEAPON_SPECIALCARBINE'] = 'Special Carbine',
        ['WEAPON_SPECIALCARBINE_MK2'] = 'Special Carbine Mk2',
        ['WEAPON_BULLPUPRIFLE'] = 'Bullpup Rifle',
        ['WEAPON_BULLPUPRIFLE_MK2'] = 'Bullpup Rifle Mk2',
        ['WEAPON_COMPACTRIFLE'] = 'Compact Rifle',

        -- Sniper Rifles
        ['WEAPON_SNIPERRIFLE'] = 'Sniper Rifle',
        ['WEAPON_HEAVYSNIPER'] = 'Heavy Sniper',
        ['WEAPON_HEAVYSNIPER_MK2'] = 'Heavy Sniper Mk2',
        ['WEAPON_MARKSMANRIFLE'] = 'Marksman Rifle',
        ['WEAPON_MARKSMANRIFLE_MK2'] = 'Marksman Rifle Mk2',

        -- Explosive Melees
        ['WEAPON_GRENADE'] = 'Grenade',
        ['WEAPON_STICKYBOMB'] = 'Sticky Bomb',
        ['WEAPON_PROXMINE'] = 'Proximity Mine',
        ['WEAPON_PIPEBOMB'] = 'Pipe Bomb',
        ['WEAPON_SMOKEGRENADE'] = 'Tear Gas',
        ['WEAPON_BZGAS'] = 'BZ Gas',
        ['WEAPON_MOLOTOV'] = 'Molotov',
        ['WEAPON_FIREEXTINGUISHER'] = 'Fire Extinguisher',
        ['WEAPON_PETROLCAN'] = 'Jerry Can',
        ['WEAPON_BALL'] = 'Ball',
        ['WEAPON_SNOWBALL'] = 'Snowball',
        ['WEAPON_FLARE'] = 'Flare',

        -- Explosive Guns
        ['WEAPON_GRENADELAUNCHER'] = 'Grenade Launcher',
        ['WEAPON_RPG'] = 'RPG',
        ['WEAPON_MINIGUN'] = 'Minigun',
        ['WEAPON_FIREWORK'] = 'Firework Launcher',
        ['WEAPON_RAILGUN'] = 'Railgun',
        ['WEAPON_HOMINGLAUNCHER'] = 'Homing Launcher',
        ['WEAPON_COMPACTLAUNCHER'] = 'Compact Grenade Launcher',
        ['WEAPON_RAYMINIGUN'] = 'Widowmaker',

        -- Shotguns
        ['WEAPON_PUMPSHOTGUN'] = 'Pump Shotgun',
        ['WEAPON_PUMPSHOTGUN_MK2'] = 'Pump Shotgun Mk2',
        ['WEAPON_SAWNOFFSHOTGUN'] = 'Sawed-off Shotgun',
        ['WEAPON_BULLPUPSHOTGUN'] = 'Bullpup Shotgun',
        ['WEAPON_ASSAULTSHOTGUN'] = 'Assault Shotgun',
        ['WEAPON_MUSKET'] = 'Musket',
        ['WEAPON_HEAVYSHOTGUN'] = 'Heavy Shotgun',
        ['WEAPON_DBSHOTGUN'] = 'Double Barrel Shotgun',
        ['WEAPON_AUTOSHOTGUN'] = 'Sweeper Shotgun',

        -- Extra Weapons
        ['WEAPON_REMOTESNIPER'] = 'Remote Sniper',
        ['WEAPON_GRENADELAUNCHER_SMOKE'] = 'Smoke Grenade Launcher',
        ['WEAPON_PASSENGER_ROCKET'] = 'Passenger Rocket',
        ['WEAPON_AIRSTRIKE_ROCKET'] = 'Airstrike Rocket',
        ['VEHICLE_WEAPON_SPACE_ROCKET'] = 'Orbital Canon',
        ['VEHICLE_WEAPON_PLANE_ROCKET'] = 'Plane Rocket',
        ['WEAPON_STINGER'] = 'Stinger [Vehicle]',
        ['VEHICLE_WEAPON_TANK'] = 'Tank Cannon',
        ['VEHICLE_WEAPON_SPACE_ROCKET'] = 'Rockets',
        ['VEHICLE_WEAPON_PLAYER_LASER'] = 'Laser',
        ['VEHICLE_WEAPON_PLAYER_LAZER'] = 'Lazer',
        ['VEHICLE_WEAPON_PLAYER_BUZZARD'] = 'Buzzard',
        ['VEHICLE_WEAPON_PLAYER_HUNTER'] = 'Hunter',
        ['VEHICLE_WEAPON_WATER_CANNON'] = 'Water Cannon',

        -- Others
        ['AMMO_RPG'] = 'Rocket',
        ['AMMO_TANK'] = 'Tank',
        ['AMMO_SPACE_ROCKET'] = 'Rocket',
        ['AMMO_PLAYER_LASER'] = 'Laser',
        ['AMMO_ENEMY_LASER'] = 'Laser',
        ['WEAPON_RAMMED_BY_CAR'] = 'Rammed by Car',
        ['WEAPON_FIRE'] = 'Fire',
        ['WEAPON_HELI_CRASH'] = 'Heli Crash',
        ['WEAPON_RUN_OVER_BY_CAR'] = 'Run over by Car',
        ['WEAPON_HIT_BY_WATER_CANNON'] = 'Hit by Water Cannon',
        ['WEAPON_EXHAUSTION'] = 'Exhaustion',
        ['WEAPON_EXPLOSION'] = 'Explosion',
        ['WEAPON_ELECTRIC_FENCE'] = 'Electric Fence',
        ['WEAPON_BLEEDING'] = 'Bleeding',
        ['WEAPON_DROWNING_IN_VEHICLE'] = 'Drowning in Vehicle',
        ['WEAPON_DROWNING'] = 'Drowning',
        ['WEAPON_BARBED_WIRE'] = 'Barbed Wire',
        ['WEAPON_VEHICLE_ROCKET'] = 'Vehicle Rocket',
        ['VEHICLE_WEAPON_ROTORS'] = 'Rotors',
        ['WEAPON_AIR_DEFENCE_GUN'] = 'Air Defence Gun',
        ['WEAPON_ANIMAL'] = 'Animal',
        ['WEAPON_COUGAR'] = 'Cougar',
    }
}
