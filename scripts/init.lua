-- entry point for all lua code of the pack
-- more info on the lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
ENABLE_DEBUG_LOG = true
-- get current variant
local variant = Tracker.ActiveVariantUID
-- check variant info
IS_ITEMS_ONLY = variant:find("itemsonly")

print("-- Example Tracker --")
print("Loaded variant: ", variant)
if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

-- Logic
ScriptHost:LoadScript("scripts/logic.lua")

-- Items
Tracker:AddItems("items/frequencies.json")
Tracker:AddItems("items/misc.json")
Tracker:AddItems("items/navigation.json")
Tracker:AddItems("items/settings.json")

if not IS_ITEMS_ONLY then -- <--- use variant info to optimize loading
    -- Maps
    Tracker:AddMaps("maps/maps.json")    
    -- Locations
    Tracker:AddLocations("locations/research_table.json")
    Tracker:AddLocations("locations/radio_tower.json")
    Tracker:AddLocations("locations/vasagatan.json")
    Tracker:AddLocations("locations/balboa.json")
    Tracker:AddLocations("locations/caravan_town.json")
    Tracker:AddLocations("locations/tangaroa.json")
    Tracker:AddLocations("locations/varuna_point.json")
    Tracker:AddLocations("locations/temperance.json")
    Tracker:AddLocations("locations/utopia.json")
end

-- Layout
Tracker:AddLayouts("layouts/misc_items.json")
Tracker:AddLayouts("layouts/navigation_items.json")
Tracker:AddLayouts("layouts/frequencies.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
