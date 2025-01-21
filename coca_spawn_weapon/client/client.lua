AllWeapons = {
    ["antiquecavalrydagger"] = "weapon_dagger",
    ["baseballbat"] = "weapon_bat",
    ["brokenbottle"] = "weapon_bottle",
    ["crowbar"] = "weapon_crowbar",
    ["fist"] = "weapon_unarmed",
    ["flashlight"] = "weapon_flashlight",
    ["golfclub"] = "weapon_golfclub",
    ["her"] = "weapon_hammer",
    ["hatchammet"] = "weapon_hatchet",
    ["brassknuckles"] = "weapon_knuckle",
    ["knife"] = "weapon_knife",
    ["machete"] = "weapon_machete",
    ["switchblade"] = "weapon_switchblade",
    ["nightstick"] = "weapon_nightstick",
    ["pipewrench"] = "weapon_wrench",
    ["battleaxe"] = "weapon_battleaxe",
    ["poolcue"] = "weapon_poolcue",
    ["stonehatchet"] = "weapon_stone_hatchet",
    ["candycane"] = "weapon_candycane",
    ["pistol"] = "weapon_pistol",
    ["pistolmkii"] = "weapon_pistol_mk2",
    ["combatpistol"] = "weapon_combatpistol",
    ["appistol"] = "weapon_appistol",
    ["stungun"] = "weapon_stungun",
    ["pistol50"] = "weapon_pistol50",
    ["snspistol"] = "weapon_snspistol",
    ["snspistolmkii"] = "weapon_snspistol_mk2",
    ["heavypistol"] = "weapon_heavypistol",
    ["vintagepistol"] = "weapon_vintagepistol",
    ["flaregun"] = "weapon_flaregun",
    ["marksmanpistol"] = "weapon_marksmanpistol",
    ["heavyrevolver"] = "weapon_revolver",
    ["heavyrevolvermkii"] = "weapon_revolver_mk2",
    ["doubleactionrevolver"] = "weapon_doubleaction",
    ["up-n-atomizer"] = "weapon_raypistol",
    ["ceramicpistol"] = "weapon_ceramicpistol",
    ["navyrevolver"] = "weapon_navyrevolver",
    ["pericopistol"] = "weapon_gadgetpistol",
    ["wm29pistol"] = "weapon_pistolxm3",
    ["microsmg"] = "weapon_microsmg",
    ["smg"] = "weapon_smg",
    ["smgmkii"] = "weapon_smg_mk2",
    ["assaultsmg"] = "weapon_assaultsmg",
    ["combatpdw"] = "weapon_combatpdw",
    ["machinepistol"] = "weapon_machinepistol",
    ["minismg"] = "weapon_minismg",
    ["unholyhellbringer"] = "weapon_raycarbine",
    ["tec9"] = "weapon_tecpistol",
    ["pumpshotgun"] = "weapon_pumpshotgun",
    ["pumpshotgunmkii"] = "weapon_pumpshotgun_mk2",
    ["sawed-offshotgun"] = "weapon_sawnoffshotgun",
    ["assaultshotgun"] = "weapon_assaultshotgun",
    ["bullpupshotgun"] = "weapon_bullpupshotgun",
    ["musket"] = "weapon_musket",
    ["heavyshotgun"] = "weapon_heavyshotgun",
    ["doublebarrelshotgun"] = "weapon_dbshotgun",
    ["sweepershotgun"] = "weapon_autoshotgun",
    ["combatshotgun"] = "weapon_combatshotgun",
    ["assaultrifle"] = "weapon_assaultrifle",
    ["assaultriflemkii"] = "weapon_assaultrifle_mk2",
    ["carbinerifle"] = "weapon_carbinerifle",
    ["carbineriflemkii"] = "weapon_carbinerifle_mk2",
    ["advancedrifle"] = "weapon_advancedrifle",
    ["specialcarbine"] = "weapon_specialcarbine",
    ["specialcarbinemkii"] = "weapon_specialcarbine_mk2",
    ["bullpuprifle"] = "weapon_bullpuprifle",
    ["bullpupriflemkii"] = "weapon_bullpuprifle_mk2",
    ["compactrifle"] = "weapon_compactrifle",
    ["militaryrifle"] = "weapon_militaryrifle",
    ["heavyrifle"] = "weapon_heavyrifle",
    ["tacticalrifle"] = "weapon_tacticalrifle",
    ["mg"] = "weapon_mg",
    ["combatmg"] = "weapon_combatmg",
    ["combatmgmkii"] = "weapon_combatmg_mk2",
    ["gusenbergsweeper"] = "weapon_gusenberg",
    ["sniperrifle"] = "weapon_sniperrifle",
    ["heavysniper"] = "weapon_heavysniper",
    ["heavysnipermkii"] = "weapon_heavysniper_mk2",
    ["marksmanrifle"] = "weapon_marksmanrifle",
    ["marksmanriflemkii"] = "weapon_marksmanrifle_mk2",
    ["precisionrifle"] = "weapon_precisionrifle",
    ["rpg"] = "weapon_rpg",
    ["grenadelauncher"] = "weapon_grenadelauncher",
    ["grenadelaunchersmoke"] = "weapon_grenadelauncher_smoke",
    ["minigun"] = "weapon_minigun",
    ["fireworklauncher"] = "weapon_firework",
    ["railgun"] = "weapon_railgun",
    ["hominglauncher"] = "weapon_hominglauncher",
    ["compactgrenadelauncher"] = "weapon_compactlauncher",
    ["widowmaker"] = "weapon_rayminigun",
    ["compactemplauncher"] = "weapon_emplauncher",
    ["grenade"] = "weapon_grenade",
    ["bzgas"] = "weapon_bzgas",
    ["molotovcocktail"] = "weapon_molotov",
    ["stickybomb"] = "weapon_stickybomb",
    ["proximitymines"] = "weapon_proxmine",
    ["snowballs"] = "weapon_snowball",
    ["pipebombs"] = "weapon_pipebomb",
    ["baseball"] = "weapon_ball",
    ["teargas"] = "weapon_smokegrenade",
    ["flare"] = "weapon_flare",
    ["acidpackage"] = "weapon_acidpackage",
    ["jerrycan"] = "weapon_petrolcan",
    ["parachute"] = "gadget_parachute",
    ["fireextinguisher"] = "weapon_fireextinguisher",
    ["hazardousjerrycan"] = "weapon_hazardcan",
    ["fertilizercan"] = "weapon_fertilizercan"
}

exports('getAllWeapons', function()
    return AllWeapons
end)


-- Define the command to register
RegisterCommand("weapon", function(source, args)
    -- Check if the player has provided the correct arguments
    if args[1] ~= nil then
        -- Get the weapon name from the command arguments
        local weaponName = args[1]

        -- Check if the weapon exists
        if IsWeaponValid(weaponName) then
            local playerPed = PlayerPedId()
            GiveWeaponToPed(playerPed, GetHashKey(AllWeapons[string.lower(weaponName)]), 999, false, true)
           
            TriggerEvent("chat:addMessage", {
                args = {
                    "You have been given a " .. weaponName .. "."
                }
            });
        else
            TriggerEvent("chat:addMessage", {
                args = {
                    "Invalid weapon name."
                }
            });
        end
    else
        TriggerEvent("chat:addMessage", {
            args = {
                "Usage: /weapon [weapon_name]"
            }
        });
    end
end, false)

function IsWeaponValid(weaponName)
    return AllWeapons[string.lower(weaponName)] or false
end


