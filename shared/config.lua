Config = {}

------------------------------------
-- FRAMEWORK / SCRIPT CONFIGURATION
-- Adjust these settings to match the framework and scripts you are using
-- Note: If using ox for any option, enable @ox_lib/init.lua in the manifest!
------------------------------------

--- @type "qb" | "qbx" | "esx"
Config.Framework = "qb"

-- The notification script you are using.
--- @type "qb" | "esx" | "ox" | "none"
Config.Notify = "qb"

------------------------------------
--- END FRAMEWORK / SCRIPT CONFIGURATION
------------------------------------

-- The key that the player needs to press to confirm the vehicle selection
-- See https://docs.fivem.net/docs/game-references/controls/#controls for a list of controls
Config.ConfirmVehicleSelectionKey = 38 -- E
Config.ExitVehicleSelectionKey = 214   -- DELETE

-- If you wish to only allow certain vehicles to be used for towing add the vehicle name to Config.AllowedTowVehicles
-- and set Config.AllowAllVehiclesToTow to false. If you want to allow all vehicles to tow, set Config.AllowAllVehiclesToTow to true
Config.AllowAllVehiclesToTow = true
Config.AllowedTowVehicles = {
    "armytrailer",
    "boattrailer",
    "freighttrailer",
    "flatbed",
    "flatbed3",
    "trflat",
    "tr2",
    "trailerlarge",
    "slamtruck",
}

-- If true you can also tow/haul props. If false, you can only tow/haul vehicles
Config.AllowHaulingProps = true

-- This enables the /tow and /untow commands. If you disable this, you can still use the client events to trigger tow/untow
Config.EnableTowCommands = true

-- The distance the player must be within from the vehicle to tow it
Config.TowDistance = 15.0
