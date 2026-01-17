# AS Anti-Cheat

Advanced anti-cheat system for the AS Framework with comprehensive detection and protection.

## Features

### Detection Systems
- ✅ **Weapon Detection** - Blacklisted weapons (railgun, raygun, etc.)
- ✅ **Speed Detection** - Detects speed hacks (on foot and in vehicles)
- ✅ **God Mode Detection** - Detects invincibility hacks
- ✅ **Noclip Detection** - Detects flying/noclip
- ✅ **Invisibility Detection** - Detects invisible players
- ✅ **Teleport Detection** - Detects large position jumps
- ✅ **Explosion Detection** - Blocks suspicious explosions
- ✅ **Resource Injection** - Monitors for known mod menu resources
- ✅ **Entity Spawning** - Logs suspicious entity creation

### Protection Features
- 🛡️ **Admin Bypass** - Admins are exempt from all checks
- 🛡️ **Violation Tracking** - Tracks violations per player
- 🛡️ **Progressive Punishment** - Warn → Kick → Ban based on violations
- 🛡️ **Ban System** - Permanent or temporary bans with database storage
- 🛡️ **Discord Logging** - Optional webhook notifications
- 🛡️ **Configurable** - All checks can be enabled/disabled via convars

## Installation

1. Ensure `as-core` and `oxmysql` are installed and started
2. Add `as-anticheat` to your server resources
3. Add to your `server.cfg`:
```cfg
ensure as-core
ensure oxmysql
ensure as-anticheat
```

## Configuration

All settings can be configured in `@as-core/convars.cfg` or directly in `server.cfg`:

```cfg
# Enable/Disable individual checks
setr as_ac_weapon_check 1
setr as_ac_speed_check 1
setr as_ac_godmode_check 1
setr as_ac_noclip_check 1
setr as_ac_invisible_check 1
setr as_ac_teleport_check 1
setr as_ac_resource_check 1
setr as_ac_explosion_check 1

# Auto-ban settings
setr as_ac_autoban 1              # 0 = warn/kick only, 1 = enable bans
setr as_ac_ban_duration 0         # Days (0 = permanent)

# Discord webhook (optional)
setr as_ac_webhook "YOUR_WEBHOOK_URL"
```

## Admin Setup

Grant admin permissions to bypass anti-cheat:

```cfg
# Add to server.cfg
add_ace group.admin as.admin allow

# Add admins
add_principal identifier.license:YOUR_LICENSE group.admin
```

Or use in-game jobs:
- Job name: `admin` or `superadmin`

## Commands

### Unban Player
```
unban <license:identifier>
```
Only available to server console or admins with `as.admin` permission.

## Violation System

Violations are tracked per player:
- **1st Violation**: Warning (logged)
- **2nd Violation**: Kick
- **3rd Violation**: Ban (if autoban enabled)

All violations are logged to console and optionally sent to Discord webhook.

## Customization

### Blacklisted Weapons
Edit `shared/config.lua`:
```lua
Config.AntiCheat.BlacklistedWeapons = {
    `WEAPON_RAILGUN`,
    `WEAPON_STUNGUN`,
    -- Add more...
}
```

### Speed Limits
```lua
Config.AntiCheat.MaxSpeed = {
    onFoot = 10.0,    -- m/s
    vehicle = 150.0   -- m/s
}
```

### Check Intervals
```lua
Config.AntiCheat.CheckIntervals = {
    weapon = 5000,     -- ms
    speed = 1000,      -- ms
    godmode = 3000,    -- ms
    -- etc...
}
```

## Database

Anti-cheat automatically creates the `as_bans` table:
- Stores ban information
- Tracks permanent and temporary bans
- Checks on player connect

## Exports

### Server Exports
```lua
-- Add violation manually
exports['as-anticheat']:AddViolation(source, 'Reason', 'Details')

-- Check if player is admin
local isAdmin = exports['as-anticheat']:IsPlayerAdmin(source)

-- Ban player
exports['as-anticheat']:BanPlayer(source, 'Reason', 'Details')
```

## Performance

- Lightweight detection loops
- Configurable check intervals
- Minimal server impact
- Client-side checks reduce server load

## Notes

- False positives can occur with laggy connections
- Adjust speed limits based on your server's vehicle handling
- Monitor logs regularly for patterns
- Whitelist trusted resources if needed

## Support

For issues or questions, join the AS Framework Discord or open an issue on GitHub.
