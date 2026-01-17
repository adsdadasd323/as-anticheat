local AS = exports['as-core']:GetCoreObject()

-- Weapon detection
RegisterServerEvent('as-anticheat:weaponCheck')
AddEventHandler('as-anticheat:weaponCheck', function(weapon)
    local source = source
    
    if not Config.AntiCheat.EnableWeaponCheck then return end
    
    for _, blacklisted in ipairs(Config.AntiCheat.BlacklistedWeapons) do
        if weapon == blacklisted then
            exports['as-anticheat']:AddViolation(source, 'Blacklisted Weapon', string.format('Weapon Hash: %s', weapon))
            RemoveWeaponFromPed(GetPlayerPed(source), weapon)
            break
        end
    end
end)

-- Speed detection
RegisterServerEvent('as-anticheat:speedCheck')
AddEventHandler('as-anticheat:speedCheck', function(speed, inVehicle)
    local source = source
    
    if not Config.AntiCheat.EnableSpeedCheck then return end
    
    local maxSpeed = inVehicle and Config.AntiCheat.MaxSpeed.vehicle or Config.AntiCheat.MaxSpeed.onFoot
    
    if speed > maxSpeed then
        exports['as-anticheat']:AddViolation(source, 'Speed Hack', string.format('Speed: %.2f m/s (Max: %.2f)', speed, maxSpeed))
    end
end)

-- Godmode detection
RegisterServerEvent('as-anticheat:godmodeCheck')
AddEventHandler('as-anticheat:godmodeCheck', function(health, maxHealth)
    local source = source
    
    if not Config.AntiCheat.EnableGodmodeCheck then return end
    
    -- Check if health exceeds max health (impossible without god mode)
    if health > maxHealth then
        exports['as-anticheat']:AddViolation(source, 'God Mode', string.format('Health: %d (Max: %d)', health, maxHealth))
    end
end)

-- Noclip detection
RegisterServerEvent('as-anticheat:noclipCheck')
AddEventHandler('as-anticheat:noclipCheck', function(isFlying, vehicle)
    local source = source
    
    if not Config.AntiCheat.EnableNoclipCheck then return end
    
    if isFlying and not vehicle then
        exports['as-anticheat']:AddViolation(source, 'Noclip/Fly Hack', 'Player flying without vehicle')
    end
end)

-- Invisible detection
RegisterServerEvent('as-anticheat:invisibleCheck')
AddEventHandler('as-anticheat:invisibleCheck', function(isInvisible)
    local source = source
    
    if not Config.AntiCheat.EnableInvisibleCheck then return end
    
    if isInvisible then
        exports['as-anticheat']:AddViolation(source, 'Invisibility Hack', 'Player is invisible')
    end
end)

-- Teleport detection
RegisterServerEvent('as-anticheat:teleportCheck')
AddEventHandler('as-anticheat:teleportCheck', function(distance)
    local source = source
    
    if not Config.AntiCheat.EnableTeleportCheck then return end
    
    if distance > Config.AntiCheat.MaxTeleportDistance then
        exports['as-anticheat']:AddViolation(source, 'Teleport Hack', string.format('Distance: %.2f meters', distance))
    end
end)

-- Resource injection detection
if Config.AntiCheat.EnableResourceCheck then
    CreateThread(function()
        while true do
            Wait(30000) -- Check every 30 seconds
            
            local players = GetPlayers()
            for _, playerId in ipairs(players) do
                local source = tonumber(playerId)
                
                -- Check for blacklisted resources
                for _, resource in ipairs(Config.AntiCheat.BlacklistedResources) do
                    -- This is a basic check - more advanced methods would be needed for real detection
                    local resourceState = GetResourceState(resource)
                    if resourceState == 'started' or resourceState == 'starting' then
                        print(string.format('^1[AS-AC]^7 Warning: Blacklisted resource detected: %s', resource))
                    end
                end
            end
        end
    end)
end

-- Explosion detection
AddEventHandler('explosionEvent', function(source, ev)
    if not Config.AntiCheat.EnableExplosionCheck then return end
    
    local isWhitelisted = false
    for _, explosionType in ipairs(Config.AntiCheat.WhitelistedExplosions) do
        if ev.explosionType == explosionType then
            isWhitelisted = true
            break
        end
    end
    
    if not isWhitelisted then
        exports['as-anticheat']:AddViolation(source, 'Suspicious Explosion', string.format('Type: %d', ev.explosionType))
        CancelEvent()
    end
end)

-- Entity creation detection (vehicles, peds, objects)
AddEventHandler('entityCreating', function(entity)
    local source = NetworkGetEntityOwner(entity)
    
    if source == 0 or source == -1 then return end
    if exports['as-anticheat']:IsPlayerAdmin(source) then return end
    
    local entityType = GetEntityType(entity)
    local model = GetEntityModel(entity)
    
    -- Log suspicious entity spawns
    -- This is basic - you'd want to whitelist allowed vehicles/objects per script
    print(string.format('^3[AS-AC]^7 Entity spawned by %s | Type: %d | Model: %s', 
        GetPlayerName(source), entityType, model))
end)

-- Give weapon event blocker
AddEventHandler('weaponDamageEvent', function(source, data)
    if not Config.AntiCheat.EnableWeaponCheck then return end
    
    -- Check if weapon is blacklisted
    for _, blacklisted in ipairs(Config.AntiCheat.BlacklistedWeapons) do
        if data.weaponType == blacklisted then
            CancelEvent()
            exports['as-anticheat']:AddViolation(source, 'Blacklisted Weapon Damage', string.format('Weapon: %s', data.weaponType))
            return
        end
    end
end)

print('^2[AS-AC]^7 Detection handlers loaded')
