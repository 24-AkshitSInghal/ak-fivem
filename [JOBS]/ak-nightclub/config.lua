Config = {}

Config.location = {
      name = 'Vanilla Unicorn Horny Girls',
      type = "Strip Club",
      blipColour = 8,
      blipSprite = 121,
      x = 128.85,
      y = -1298.75,
      z = 29.3,
      l = 10.8,
      w = 16.2,
      h = 37,
}

Config.Locations1 = { -- Unicorn Girl (2 Girls in Middle back)
      { x = 105.027, y = -1292.301, z = 28.85, heading = 0.0 }

}

Config.Locations2 = { -- Unicorn Girl tubo (1 Girl right floor back)
      { x = 102.324, y = -1289.728, z = 28.85, heading = 348.102 }

}

Config.Locations3 = { -- Unicorn Girl tubo (1 girl left standing back)
      { x = 105.513, y = -1294.609, z = 29.259, heading = 100.264 }

}

Config.Locations4 = { -- Unicorn Girl tubo (1 girl left standing front)
      { x = 113.400, y = -1288.60, z = 28.49, heading = 306.5 }

}

Config.Locations5 = { -- Unicorn Girl tubo (1 girl right standing front)
      { x = 112.336, y = -1286.110, z = 28.159, heading = 28.807 }

}

Config.Locations6 = { -- Unicorn Girl tubo (1 girl mid standing front) pole dancer
      { x = 112.674, y = -1286.739, z = 28.49, heading = 308.5 }
}

Config.Locations7 = { -- Unicorn Girls (2 Girls in mid )
      { x = 109.732, y = -1289.5, z = 28.38, heading = 306.5 }
}

Config.Locations8 = { -- Unicorn Girls ( Audition Girl)
      { x = 98.299, y = -1290.1, z = 29.40, heading = 115.8305 }
}

Config.Locations8_1 = { -- Unicorn Girls ( Audition Girl white door side)
      { x = 97.84, y = -1288.95, z = 29.269, heading = 177.03 }
}

Config.Locations8_2 = { -- Unicorn Girls ( Audition Girl red door side)
      { x = 99.29, y = -1291.99, z = 28.769, heading = 102.03 }
}

Config.Locations9 = { -- Unicorn Girls ( moving Girl locker room)
      { x = 107.503, y = -1305.688, z = 28.769, heading = 13.3605 }
}

Config.Locations9_mid = {
      { x = 108.670, y = -1288.778, z = 28.859, heading = 295.817 }
}

Config.Locations9_right = {
      { x = 101.446, y = -1290.902, z = 29.259, heading = 12.0 }
}

Config.Locations9_left = {
      { x = 103.818, y = -1295.153, z = 29.259, heading = 173.099 }
}

Config.Locations10 = { -- Unicorn Girls ( bartender )
      { x = 129.852, y = -1284.887, z = 28.380, heading = 116.750 }
}

Config.Locations11 = { -- office secratery
      { x = 95.21, y = -1294.53, z = 28.26, heading = 1.4 }
}

Config.Locations12 = { -- LapDance Hostess
      { x = 126.052, y = -1282.47, z = 28.27, heading = 185.11 }
}



-- Hooker Script

-- The peds that are considered hookers. (be carefull what you add here.)
Config.HookerPedModels = {
      [`s_f_y_hooker_01`] = true,
      [`s_f_y_hooker_02`] = true,
      [`s_f_y_hooker_03`] = true
}

-- The vehicle classes that can't be used to pick up hookers
Config.BlackListedVehicleClasses = {
      [8] = true, -- Motorcycles
      [13] = true, -- Cycles
      [14] = true, -- Boats
      [15] = true, -- Helicopters
      [16] = true, -- Planes
      [18] = true, -- Emergency
      [19] = true, -- Military
      [21] = true, -- Trains
      [22] = true, -- Open Wheel
}

-- Vehicles that can't be used to pick up hookers
-- These were taken from pb_prostitute.c
Config.BlackListedVehicles = {
      [`infernus`] = true,
      [`voltic`] = true,
      [`stingergt`] = true,
      [`stinger`] = true,
      [`bullet`] = true,
      [`entityxf`] = true,
      [`feltzer3`] = true,
      [`granger`] = true,
      [`panto`] = true,
      [`phoenix`] = true,
      [`fmj`] = true,
      [`reaper`] = true,
      [`le7b`] = true,
      [`tyrus`] = true,
      [`infernus2`] = true
}

Config.LeanLoc = {
      {x = 114.715, y = -1285.813, z = 28.263, h = 119.358},
      {x = 114.330, y = -1289.86, z = 28.261, h = 27.012},
      {x = 110.52, y = -1291.01, z = 28.261, h = 51.15},
      {x = 106.942, y = -1293.10, z = 28.261, h = 96.16},
      {x = 111.342, y = -1284.13, z = 28.261, h = 215.106},
      {x = 108.77, y = -1286.675, z = 28.261, h = 206.977},
      {x = 106.51, y = -1288.05, z = 28.261, h = 209.977},
      {x = 103.97, y = -1288.57, z = 28.261, h = 164.777},
}
