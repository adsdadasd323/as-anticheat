local AS = exports['as-core']:GetCoreObject()

-- Ban database table
MySQL.ready(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS as_bans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(100) NOT NULL,
            playerName VARCHAR(100) NOT NULL,
            reason VARCHAR(255) NOT NULL,
            details TEXT,
            bannedBy VARCHAR(100) DEFAULT 'Anti-Cheat',
            banDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            expiresAt TIMESTAMP NULL,
            permanent BOOLEAN DEFAULT FALSE,
            INDEX idx_identifier (identifier),
            INDEX idx_expires (expiresAt)
        )
    ]])
end)

-- Ban player
function BanPlayer(source, reason, details)
    local identifiers = GetPlayerIdentifiers(source)
    local playerName = GetPlayerName(source)
    local license = nil
    
    -- Get license identifier
    for _, id in ipairs(identifiers) do
        if string.match(id, 'license:') then
            license = id
            break
        end
    end
    
    if not license then
        print('^1[AS-AC]^7 Could not ban player - no license found')
        return
    end
    
    local permanent = Config.AntiCheat.BanDuration == 0
    local expiresAt = nil
    
    if not permanent then
        -- Calculate expiration time
        expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.AntiCheat.BanDuration * 86400))
    end
    
    -- Insert ban into database
    MySQL.Async.execute('INSERT INTO as_bans (identifier, playerName, reason, details, permanent, expiresAt) VALUES (@identifier, @playerName, @reason, @details, @permanent, @expiresAt)', {
        ['@identifier'] = license,
        ['@playerName'] = playerName,
        ['@reason'] = reason,
        ['@details'] = details or '',
        ['@permanent'] = permanent,
        ['@expiresAt'] = expiresAt
    }, function(affectedRows)
        if affectedRows > 0 then
            local banMsg = permanent and 'permanently banned' or string.format('banned for %d days', Config.AntiCheat.BanDuration)
            print(string.format('^1[AS-AC]^7 Player %s has been %s. Reason: %s', playerName, banMsg, reason))
            
            DropPlayer(source, string.format('[AS Anti-Cheat]\nYou have been %s\nReason: %s\n\nIf you believe this is an error, contact server administration.', banMsg, reason))
        end
    end)
end

-- Check if player is banned on join
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local license = nil
    
    deferrals.defer()
    Wait(0)
    deferrals.update('Checking ban status...')
    
    -- Get license
    for _, id in ipairs(identifiers) do
        if string.match(id, 'license:') then
            license = id
            break
        end
    end
    
    if not license then
        deferrals.done('No license identifier found')
        return
    end
    
    -- Check for active ban
    MySQL.Async.fetchAll('SELECT * FROM as_bans WHERE identifier = @identifier AND (permanent = TRUE OR expiresAt > NOW()) ORDER BY banDate DESC LIMIT 1', {
        ['@identifier'] = license
    }, function(result)
        if result and #result > 0 then
            local ban = result[1]
            local banMsg = ban.permanent and 'permanently banned' or string.format('banned until %s', ban.expiresAt)
            
            deferrals.done(string.format('[AS Anti-Cheat]\nYou are %s\nReason: %s\n\nIf you believe this is an error, contact server administration.', banMsg, ban.reason))
        else
            deferrals.done()
        end
    end)
end)

-- Command to unban player (admin only)
AS.Server.RegisterCommand('unban', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'as.admin') then
        return
    end
    
    if not args[1] then
        print('Usage: unban <identifier>')
        return
    end
    
    local identifier = args[1]
    
    MySQL.Async.execute('DELETE FROM as_bans WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(affectedRows)
        if affectedRows > 0 then
            print(string.format('^2[AS-AC]^7 Unbanned identifier: %s', identifier))
        else
            print('^1[AS-AC]^7 No ban found for that identifier')
        end
    end)
end)

-- Export ban function
exports('BanPlayer', BanPlayer)

print('^2[AS-AC]^7 Ban system loaded')
