local AS = exports['as-core']:GetCoreObject()

-- Player flags (violation tracking)
local playerFlags = {}

-- Check if player is admin
local function IsPlayerAdmin(source)
    local player = AS.Server.GetPlayer(source)
    if not player then return false end
    
    -- Check if player has admin job or ace permission
    local job = player.getJob()
    if job and (job.name == 'admin' or job.name == 'superadmin') then
        return true
    end
    
    -- Check ace permissions
    return IsPlayerAceAllowed(source, 'as.admin')
end

-- Get or create player flags
local function GetPlayerFlags(source)
    if not playerFlags[source] then
        playerFlags[source] = {
            violations = 0,
            lastViolation = 0,
            detections = {}
        }
    end
    return playerFlags[source]
end

-- Add violation
local function AddViolation(source, reason, details)
    if IsPlayerAdmin(source) then
        print(string.format('^3[AS-AC]^7 Admin %s triggered: %s (ignored)', GetPlayerName(source), reason))
        return
    end
    
    local flags = GetPlayerFlags(source)
    flags.violations = flags.violations + 1
    flags.lastViolation = os.time()
    
    if not flags.detections[reason] then
        flags.detections[reason] = 0
    end
    flags.detections[reason] = flags.detections[reason] + 1
    
    local playerName = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    print(string.format('^1[AS-AC]^7 Detection: %s | Player: %s | Details: %s | Violations: %d', 
        reason, playerName, details or 'N/A', flags.violations))
    
    -- Send to webhook
    if Config.AntiCheat.Webhook ~= '' then
        SendWebhook(reason, playerName, details, identifiers, flags.violations)
    end
    
    -- Take action based on violation count
    if flags.violations >= 3 and Config.AntiCheat.AutoBan and Config.AntiCheat.Actions.ban then
        BanPlayer(source, reason, details)
    elseif flags.violations >= 2 and Config.AntiCheat.Actions.kick then
        DropPlayer(source, string.format('[AS Anti-Cheat] Kicked: %s', reason))
    end
end

-- Send Discord webhook
function SendWebhook(reason, playerName, details, identifiers, violations)
    local embed = {
        {
            ['title'] = '🛡️ Anti-Cheat Detection',
            ['color'] = Config.AntiCheat.WebhookColor,
            ['fields'] = {
                {
                    ['name'] = 'Player',
                    ['value'] = playerName,
                    ['inline'] = true
                },
                {
                    ['name'] = 'Reason',
                    ['value'] = reason,
                    ['inline'] = true
                },
                {
                    ['name'] = 'Violations',
                    ['value'] = tostring(violations),
                    ['inline'] = true
                },
                {
                    ['name'] = 'Details',
                    ['value'] = details or 'N/A',
                    ['inline'] = false
                },
                {
                    ['name'] = 'Identifiers',
                    ['value'] = table.concat(identifiers, '\n'),
                    ['inline'] = false
                }
            },
            ['footer'] = {
                ['text'] = 'AS Anti-Cheat System'
            },
            ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%S')
        }
    }
    
    PerformHttpRequest(Config.AntiCheat.Webhook, function(err, text, headers) end, 'POST', json.encode({
        username = 'AS Anti-Cheat',
        embeds = embed
    }), {['Content-Type'] = 'application/json'})
end

-- Export functions
exports('AddViolation', AddViolation)
exports('IsPlayerAdmin', IsPlayerAdmin)

-- Clean up flags on player drop
AddEventHandler('playerDropped', function()
    local source = source
    if playerFlags[source] then
        playerFlags[source] = nil
    end
end)

print('^2[AS-AC]^7 Main server script loaded')
