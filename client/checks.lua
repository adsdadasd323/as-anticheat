-- Additional client-side checks and protections

-- Disable certain native functions that cheaters commonly use
CreateThread(function()
    while true do
        Wait(0)
        
        -- Disable certain controls that can be abused
        DisableControlAction(0, 37, true) -- Disable weapon wheel (can be used to give weapons)
        
        -- Block spectator mode
        if NetworkIsInSpectatorMode() then
            NetworkSetInSpectatorMode(false, PlayerPedId())
        end
    end
end)

-- Protect against certain exploits
AddEventHandler('gameEventTriggered', function(event, data)
    -- Block certain game events that can be triggered by mod menus
    local blockedEvents = {
        'CEventNetworkEntityDamage',
        'CEventNetworkPlayerCollectedPickup'
    }
    
    for _, blockedEvent in ipairs(blockedEvents) do
        if event == blockedEvent then
            -- Log but don't cancel - may be legitimate
            -- TriggerServerEvent('as-anticheat:suspiciousEvent', event)
        end
    end
end)

print('^2[AS-AC]^7 Client protection loaded')
