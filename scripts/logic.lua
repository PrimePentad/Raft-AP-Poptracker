function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

function has_smelter()
    return has("smelter")
end

function has_bolt()
    return has("bolt")
end

function has_hinge()
    return has("hinge")
end

function has_circuit_board()
    return has("circuit_board")
end

function has_empty_bottle()
    return has("circuit_board")
end

function has_sweep_net()
    return has("sweep_net")
end

function has_shears()
    return has("shears")
end

function has_machete()
    return has("machete")
end

function can_navigate()
    return (has("battery") and has("receiver") and has("antenna") and 
        has("smelter") and has("bolt") and has("hinge") and
        has("circuit_board"))
end

function can_drive()
    return (can_navigate() and has("engine") and has("steering_wheel"))
end

function can_access_big_islands()
    return can_navigate()
end
    
function has_feather()
    return (can_access_big_islands() or has("birds_nest"))
end

function has_explosive_powder()
    return (can_access_big_islands() and has_smelter())
end
    
function can_shovel()
    return (has("shovel") and has_smelter() and has_bolt())
end
    
function has_dirt()
    return (can_access_big_islands() and can_shovel())
end

function can_treasure_hunt()
    return (can_shovel() and has("battery") and has("metal_detector"))
end
            
function can_capture_animals()
    return (can_access_big_islands() and has("grass_plot") and 
        has("net_launcher") and has("net_canister") and has_smelter())
end

function can_access_vasagatan()
    return (can_navigate() and has("vasagatan_frequency"))
end

function can_access_balboa()
    return (can_drive() and has("balboa_frequency"))
end

function can_access_caravan_town()
    return (can_drive() and has("caravan_town_frequency"))
end

function can_access_tangaroa()
    return (can_drive() and has("tangaroa_frequency"))
end

function can_access_varuna_point()
    return (can_drive() and has("varuna_point_frequency"))
end

function can_access_temperance()
    return (can_drive() and has("temperance_frequency"))
end

function can_access_utopia()
    return (can_drive() and has("utopia_frequency"))
end
