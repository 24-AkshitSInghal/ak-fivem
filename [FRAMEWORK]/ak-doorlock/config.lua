Config = {}

Config.Doors = {

    -- POLICE DOORS

    ['police_1'] = {
        DoorHash = `police_1`,
        LabelCoords = vector3(450.118,-986.447,31.200),
        ModelHash = `v_ilev_ph_gendoor004`,
        Coordinates = vector3(450.1041,-985.7384,30.8393),
        Locked = 1,
        SpecialAccess = nil,
        Hidden = false,
        type = "police"
    },
    ['police_2'] = {
        DoorHash = `police_2`,
        LabelCoords = vector3(443.9999, -989.4454, 31.200),
        ModelHash = `v_ilev_ph_gendoor005`,
        Coordinates = vector3(443.4078, -989.4454, 30.8393),
        Locked = 1,
        SpecialAccess = nil,
        Hidden = false,
        type = "police"
    },
    ['police_3'] = {
        DoorHash = `police_3`,
        LabelCoords = vector3(445.4078, -989.4454, 31.200),
        ModelHash = `v_ilev_ph_gendoor005`,
        Coordinates = vector3(446.0078, -989.4454, 30.8393),
        Locked = 1,
        SpecialAccess = nil,
        Hidden = false,
        type="police"
    },
    ['police_4'] = {                                                 -- Weapon Locker Room
        DoorHash = `police_4`,
        LabelCoords = vector3(453.0793, -982.5895, 31.200),
        ModelHash = `v_ilev_arm_secdoor`,
        Coordinates = vector3(453.0793, -983.1895, 30.8392),
        Locked = 1,
        SpecialAccess = 'policelockercard',
        Hidden = false,
        type = "police"
    },

    -- VU DOORS

    ['vanilla_1'] = {                                                 
        DoorHash = `vanilla_1`,
        LabelCoords =vector3(95.39197, -1285.0, 29.63878),
        ModelHash = `prop_magenta_door`,
        Coordinates = vector3(96.09197, -1284.854, 29.43878),
        Locked = 1,
        SpecialAccess = 'vanillacard',
        Hidden = false,
        type = nil
    },['vanilla_2'] = {                                               
        DoorHash = `vanilla_2`,
        LabelCoords =vector3(99.8321, -1293.401, 29.61868),
        ModelHash = `v_ilev_roc_door2`,
        Coordinates = vector3(99.08321, -1293.701, 29.41868),
        Locked = 1,
        SpecialAccess = 'vanillacard',
        Hidden = false,
        type = nil
    },['vanilla_3'] = {                                                
        DoorHash = `vanilla_3`,
        LabelCoords =vector3(113.9822, -1296.75, 29.61868),
        ModelHash = `v_ilev_door_orangesolid`,
        Coordinates = vector3(113.9822, -1297.43, 29.41868),
        Locked = 1,
        SpecialAccess = 'vanillacard',
        Hidden = false,
        type = nil
    },['vanilla_4'] = {                                                
        DoorHash = `vanilla_4`,
        LabelCoords = vector3(128.6552, -1298.503, 29.61962),
        ModelHash = `prop_strip_door_01`,
        Coordinates = vector3(127.9552, -1298.503, 29.41962),
        Locked = 0,
        SpecialAccess = 'vanillacard',
        Hidden = false,
        type = nil
    },

    -- Hidden

    ['black_bunker_left'] = {
        DoorHash = `black_bunker_left`,
        LabelCoords = vector3(3141.477,5375.13,26.84),
        ModelHash = -328548271,
        Coordinates = vector3(3139.77, 5374.63, 25.13),
        Locked = 1,
        SpecialAccess = 'accesscard',
        Hidden = true, 
        type = "admin"
    },
    ['black_bunker_right'] = {
        DoorHash = `black_bunker_right`,
        LabelCoords = vector3(3143.14, 5376.16, 26.83),
        ModelHash = 243434624,
        Coordinates = vector3(3144.26, 5377.229, 25.13),
        Locked = 1,
        SpecialAccess = 'accesscard',
        Hidden = true, 
        type = "admin"
    },
    ['gang_gunstore_1'] = {
        DoorHash = `gang_gunstore_1`,
        LabelCoords = vector3(-596.6, 210.058, 74.70254),
        ModelHash = `v_ilev_losttoiletdoor`,
        Coordinates = vector3(-597.2216, 210.058, 74.30254),
        Locked = 1,
        SpecialAccess = 'weaponstorekey',
        Hidden = true, 
        type = nil
    },
    ['meth_lab_1'] = {
        DoorHash = `meth_lab_1`,
        LabelCoords = vector3(-323.81, -1356.2, 31.95),
        ModelHash = 1427451548,
        Coordinates = vector3(-323.81, -1356.84, 31.65),
        Locked = 1,
        SpecialAccess = 'methlabkey',
        Hidden = true,
        type = nil
    },
    ['weed_factory_1'] = {
        DoorHash = `weed_factory_1`,
        LabelCoords = vector3(-495.11,-1425.47,15.15),
        ModelHash = `xm_prop_base_door_04`,
        Coordinates = vector3(-495.51, -1426.17, 14.81),
        Locked = 1,
        SpecialAccess = 'weedfactorykey',
        Hidden = true,
        type = nil
    },
    ['cocain_warehouse_1'] = {
        DoorHash = `cocain_warehouse_1`,
        LabelCoords = vector3(1957.057, 5174.505, 48.302),
        ModelHash = `prop_door_01`,
        Coordinates = vector3(1957.77, 5174.505, 47.962),
        Locked = 1,
        SpecialAccess = 'cocainwarehousekey',
        Hidden = true,
        type = nil
    },
    ['weapon_factoy_1'] = {
        DoorHash = `weapon_factoy_1`,
        LabelCoords = vector3(-155.8,6293.2,32.21),
        ModelHash = 1427451548,
        Coordinates = vector3(-155.55, 6292.55, 31.92),
        Locked = 1,
        SpecialAccess = 'weaponfactoykey',
        Hidden = true,
        type = nil
    },
}
