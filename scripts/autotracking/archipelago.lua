-- this is an example/ default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via thier ids
-- it will also load the AP slot data in the global SLOT_DATA, keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    -- manually run snes interface functions after onClear in case we are already ingame

    
    
    if SLOT_DATA == nil then
        return
    end

    print(string.format("slot data big islands = ",slot_data["big_island_early_crafting"]))
    
    if slot_data["big_island_early_crafting"] then
        local big_islands = Tracker:FindObjectForCode("big_islands_mode")
        big_islands.Active = slot_data["big_island_early_crafting"]
    end

    if slot_data["paddleboard_mode"] then
        local paddleboard = Tracker:FindObjectForCode("paddleboard_mode")
        paddleboard.Active = slot_data["paddleboard_mode"]
    end

end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
        else
            LOCAL_ITEMS[v[1]] = 1
        end
    else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
        else
            GLOBAL_ITEMS[v[1]] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end

    local progressive_spear = Tracker:FindObjectForCode("progressive_spear")
    local metal_spear = Tracker:FindObjectForCode("metal_spear")
    local machete = Tracker:FindObjectForCode("machete")
    local titanium_sword = Tracker:FindObjectForCode("titanium_sword")
    if titanium_sword.Active == true then
        progressive_spear.CurrentStage = 3
    elseif machete.Active == true then
        progressive_spear.CurrentStage = 2
    elseif metal_spear.Active == true then
        progressive_spear.CurrentStage = 1
    end
    
    if item_id == 47110 then   
        local progressive_smelter = Tracker:FindObjectForCode("progressive_smelter")
        local progressive_metal_detector = Tracker:FindObjectForCode("progressive_metal_detector")
        local progressive_metals = Tracker:FindObjectForCode("progressive_metals")
        if progressive_metals.CurrentStage >= 1 then
            progressive_smelter.Active = true
        end
        if progressive_metals.CurrentStage >= 2 then
            progressive_metal_detector.Active = true
        end
    end

    if item_id == 47099 then   
        local progressive_empty_bottle = Tracker:FindObjectForCode("progressive_empty_bottle")
        local progressive_bottle = Tracker:FindObjectForCode("progressive_bottle")
        if progressive_bottle.CurrentStage >= 1 then
           progressive_empty_bottle.Active = true
        end
    end

    if item_id == 47103 then   
        local progressive_battery = Tracker:FindObjectForCode("progressive_battery")
        local progressive_batteries = Tracker:FindObjectForCode("progressive_batteries")
        if progressive_batteries.CurrentStage >= 1 then
           progressive_battery.Active = true
        end
    end

    if item_id == 47105 then   
        local progressive_engine = Tracker:FindObjectForCode("progressive_engine")
        local progressive_steering_wheel = Tracker:FindObjectForCode("progressive_steering_wheel")
        local progressive_engines = Tracker:FindObjectForCode("progressive_engines")
        if progressive_engines.CurrentStage >= 1 then
            progressive_engine.Active = true
        end
        if progressive_engines.CurrentStage >= 2 then
            progressive_steering_wheel.Active = true
        end
    end

    if item_id == 47109 then   
        local progressive_zipline_tool = Tracker:FindObjectForCode("progressive_zipline_tool")
        local progressive_ziplines = Tracker:FindObjectForCode("progressive_ziplines")
        if progressive_ziplines.CurrentStage >= 1 then
           progressive_zipline_tool.Active = true
        end
    end

    if item_id == 47082 or item_id == 47083 or item_id == 47084 then
        local progressive_spear = Tracker:FindObjectForCode("progressive_spear")
        if progressive_spear.CurrentStage < 3 and item_id == 47084 then
            progressive_spear.CurrentStage = 3
        elseif progressive_spear.CurrentStage < 2 and item_id == 47083 then
            progressive_spear.CurrentStage = 2
        elseif progressive_spear.CurrentStage < 1 and item_id == 47082 then
            progressive_spear.CurrentStage = 1
        end
    end

    if item_id == 47115 then   
        local progressive_vasagatan_frequency = Tracker:FindObjectForCode("progressive_vasagatan_frequency")
        local progressive_balboa_frequency = Tracker:FindObjectForCode("progressive_balboa_frequency")
        local progressive_caravan_town_frequency = Tracker:FindObjectForCode("progressive_caravan_town_frequency")
        local progressive_tangaroa_frequency = Tracker:FindObjectForCode("progressive_tangaroa_frequency")
        local progressive_varuna_point_frequency = Tracker:FindObjectForCode("progressive_varuna_point_frequency")
        local progressive_temperance_frequency = Tracker:FindObjectForCode("progressive_temperance_frequency")
        local progressive_utopia_frequency = Tracker:FindObjectForCode("progressive_utopia_frequency")
        local progressive_frequency = Tracker:FindObjectForCode("progressive_frequency")
        if progressive_frequency.CurrentStage >= 1 then
           progressive_vasagatan_frequency.Active = true
        end
        if progressive_frequency.CurrentStage >= 2 then
           progressive_balboa_frequency.Active = true
        end
        if progressive_frequency.CurrentStage >= 3 then
           progressive_caravan_town_frequency.Active = true
        end
        if progressive_frequency.CurrentStage >= 4 then
           progressive_tangaroa_frequency.Active = true
        end
        if progressive_frequency.CurrentStage >= 5 then
           progressive_varuna_point_frequency.Active = true
        end
        if progressive_frequency.CurrentStage >= 6 then
           progressive_temperance_frequency.Active = true
        end
        if progressive_frequency.CurrentStage >= 7 then
           progressive_utopia_frequency.Active = true
        end
    end
    
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
    end
end


-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
