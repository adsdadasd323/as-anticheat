Config = Config or {}

Config.AntiCheat = {}

-- Convars (Set these in server.cfg)
Config.AntiCheat.EnableWeaponCheck = GetConvarInt('as_ac_weapon_check', 1) == 1
Config.AntiCheat.EnableSpeedCheck = GetConvarInt('as_ac_speed_check', 1) == 1
Config.AntiCheat.EnableGodmodeCheck = GetConvarInt('as_ac_godmode_check', 1) == 1
Config.AntiCheat.EnableNoclipCheck = GetConvarInt('as_ac_noclip_check', 1) == 1
Config.AntiCheat.EnableInvisibleCheck = GetConvarInt('as_ac_invisible_check', 1) == 1
Config.AntiCheat.EnableTeleportCheck = GetConvarInt('as_ac_teleport_check', 1) == 1
Config.AntiCheat.EnableResourceCheck = GetConvarInt('as_ac_resource_check', 1) == 1
Config.AntiCheat.EnableExplosionCheck = GetConvarInt('as_ac_explosion_check', 1) == 1
Config.AntiCheat.AutoBan = GetConvarInt('as_ac_autoban', 1) == 1
Config.AntiCheat.BanDuration = GetConvarInt('as_ac_ban_duration', 0) -- 0 = permanent

-- Check intervals (milliseconds)
Config.AntiCheat.CheckIntervals = {
    weapon = 5000,
    speed = 1000,
    godmode = 3000,
    noclip = 2000,
    invisible = 3000,
    position = 500
}

-- Speed limits
Config.AntiCheat.MaxSpeed = {
    onFoot = 10.0, -- m/s (running speed ~7 m/s)
    vehicle = 240.0 -- m/s (reasonable max for supercars)
}

-- Teleport detection
Config.AntiCheat.MaxTeleportDistance = 100.0 -- meters

-- Blacklisted weapons
Config.AntiCheat.BlacklistedWeapons = {
    `WEAPON_RAILGUN`,
    `WEAPON_STUNGUN`,
    `WEAPON_DIGISCANNER`,
    `WEAPON_RAYPISTOL`,
    `WEAPON_RAYCARBINE`,
    `WEAPON_RAYGUN`,
    `WEAPON_FIREWORK`
}

-- Blacklisted resources (typical mod menu names)
Config.AntiCheat.BlacklistedResources = {
    'lynx',
    'eulen',
    'redengine',
    'modest',
    'brutan',
    'kiddions',
    'mezzo',
    'hypnotic'
}

-- Whitelisted explosions (for scripts)
Config.AntiCheat.WhitelistedExplosions = {
    0, -- GRENADE
    1, -- GRENADELAUNCHER
    2, -- STICKYBOMB
    3, -- MOLOTOV
    4, -- ROCKET
    5, -- TANKSHELL
    13, -- CAR
    25, -- PIPEBOMB
}

-- Punishment actions
Config.AntiCheat.Actions = {
    warn = true, -- Log warning
    kick = true, -- Kick player
    ban = true -- Ban player (if AutoBan enabled)
}

-- Discord webhook (optional)
Config.AntiCheat.Webhook = GetConvar('as_ac_webhook', '')
Config.AntiCheat.WebhookColor = 15158332 -- Red color
