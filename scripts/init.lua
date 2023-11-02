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

if not IS_ITEMS_ONLY then -- <--- use variant info to optimize loading
    -- Maps
    Tracker:AddMaps("maps/maps.json")    
    -- Locations
    Tracker:AddLocations("locations/research_table.json")
    Tracker:AddLocations("locations/radio_tower.json")
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
