local AS = exports['as-core']:GetCoreObject()
local lastPosition = vector3(0, 0, 0)

-- Wait for framework to load
CreateThread(function()
    while not AS.Client.IsPlayerLoaded() do
        Wait(100)
    end
    
    print('^2[AS-AC]^7 Client initialized')
end)

-- Weapon check
if Config.AntiCheat.EnableWeaponCheck then
    CreateThread(function()
        while true do
            Wait(Config.AntiCheat.CheckIntervals.weapon)
            
            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)
            
            if weapon ~= `WEAPON_UNARMED` then
                TriggerServerEvent('as-anticheat:weaponCheck', weapon)
            end
        end
    end)
end

-- Speed check
if Config.AntiCheat.EnableSpeedCheck then
    CreateThread(function()
        while true do
            Wait(Config.AntiCheat.CheckIntervals.speed)
            
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            local speed = GetEntitySpeed(ped)
            
            TriggerServerEvent('as-anticheat:speedCheck', speed, vehicle ~= 0)
        end
    end)
end

-- Godmode check
if Config.AntiCheat.EnableGodmodeCheck then
    CreateThread(function()
        while true do
            Wait(Config.AntiCheat.CheckIntervals.godmode)
            
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            
            TriggerServerEvent('as-anticheat:godmodeCheck', health, maxHealth)
        end
    end)
end

-- Noclip check
if Config.AntiCheat.EnableNoclipCheck then
    CreateThread(function()
        while true do
            Wait(Config.AntiCheat.CheckIntervals.noclip)
            
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            -- Check if player is flying without vehicle
            if IsPedInAnyVehicle(ped, false) == false then
                if IsPedInParachuteFreeFall(ped) == false and IsPedFalling(ped) == false then
                    local coords = GetEntityCoords(ped)
                    local isFlying = not IsPedOnFoot(ped) and coords.z > 0
                    
                    if isFlying then
                        TriggerServerEvent('as-anticheat:noclipCheck', true, false)
                    end
                end
            end
        end
    end)
end

-- Invisible check
if Config.AntiCheat.EnableInvisibleCheck then
    CreateThread(function()
        while true do
            Wait(Config.AntiCheat.CheckIntervals.invisible)
            
            local ped = PlayerPedId()
            local isInvisible = not IsEntityVisible(ped) or GetEntityAlpha(ped) < 255
            
            if isInvisible then
                TriggerServerEvent('as-anticheat:invisibleCheck', true)
            end
        end
    end)
end

-- Teleport check
if Config.AntiCheat.EnableTeleportCheck then
    CreateThread(function()
        while true do
            Wait(Config.AntiCheat.CheckIntervals.position)
            
            local ped = PlayerPedId()
            local currentPos = GetEntityCoords(ped)
            
            if lastPosition.x ~= 0 then
                local distance = #(currentPos - lastPosition)
                
                -- Only check if not in vehicle (vehicles can move fast legitimately)
                if not IsPedInAnyVehicle(ped, false) then
                    if distance > Config.AntiCheat.MaxTeleportDistance then
                        TriggerServerEvent('as-anticheat:teleportCheck', distance)
                    end
                end
            end
            
            lastPosition = currentPos
        end
    end)
end

print('^2[AS-AC]^7 Client checks loaded')
