AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local license = "Unknown"

    -- Trouve l'identifiant "license:"
    for _, id in pairs(identifiers) do
        if string.sub(id, 1, 7) == "license" then
            license = id
            break
        end
    end

    deferrals.defer() -- Pause la connexion
    Citizen.Wait(100) -- Délai pour éviter les bugs

    -- Vérifie si le joueur est banni
    exports.oxmysql:execute('SELECT reason, ban_id, banned_at FROM bans WHERE license = ?', {license}, function(result)
        if result and #result > 0 then
            local reason = result[1].reason
            local banId = result[1].ban_id
            local bannedAt = result[1].banned_at or "Inconnu"

            -- Message moderne avec TITRE EN GROS
            local message = string.format([[
            
━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴🔴🔴 **𝗩𝗢𝗨𝗦 𝗘̂𝗧𝗘𝗦 𝗕𝗔𝗡𝗡𝗜** 🔴🔴🔴
━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 **Pseudo** : %s  
🆔 **ID du Ban** : %s  
📅 **Date du Ban** : %s  
🚨 **Raison** : %s  

🛡️ **Sécurité Belhorm Anti-Cheat**
]], playerName, banId, bannedAt, reason)

            print(string.format("[Belhorm A-C] ❌ %s a tenté de se connecter mais est banni ! (ID Ban: %s)", playerName, banId))

            deferrals.done(message) -- Affiche le message de ban stylisé
        else
            deferrals.done() -- Autorise la connexion
        end
    end)
end)

-- Liste des événements interdits
local forbiddenEvents = {
    "esx:giveWeapon",
    "AdminMenu:GiveWeapon",
    "esx:revive",
    "esx_ambulancejob:revive",
    "ems:revive"
}

-- Fonction de ban avec message moderne
local function BanPlayer(source, reason)
    local playerName = GetPlayerName(source)
    local license = "Unknown"
    local identifiers = GetPlayerIdentifiers(source)

    for _, id in pairs(identifiers) do
        if string.sub(id, 1, 7) == "license" then
            license = id
            break
        end
    end

    local banId = math.random(100000, 999999) -- ID unique pour le ban

    -- Log du ban dans la console
    print(string.format("[Belhorm A-C] ❌ %s (%d) a été banni pour: %s", playerName, source, reason))

    -- Insérer le ban dans la base de données
    exports.oxmysql:execute('INSERT INTO bans (license, reason, ban_id, banned_at) VALUES (?, ?, ?, NOW())', {
        license,
        reason,
        banId
    }, function()
        -- Message moderne avec TITRE EN GROS
        local message = string.format([[
        
━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴🔴🔴 **𝗩𝗢𝗨𝗦 𝗘̂𝗧𝗘𝗦 𝗕𝗔𝗡𝗡𝗜** 🔴🔴🔴
━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 **Pseudo** : %s  
🆔 **ID du Ban** : %s  
🚨 **Raison** : %s  

🛡️ **Sécurité Belhorm Anti-Cheat**
]], playerName, banId, reason)

        DropPlayer(source, message) -- Expulse le joueur avec le message stylisé
    end)
end

-- Détection des événements interdits
for _, eventName in ipairs(forbiddenEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        local src = source
        print(string.format("[Belhorm A-C] ❌ Tentative d'appel de l'événement interdit '%s' par %s (%d)", eventName, GetPlayerName(src), src))
        BanPlayer(src, "Tentative d'utilisation d'un événement interdit: " .. eventName)
    end)
end

forbiddenEvents = {
    "esx:giveWeapon",
    "AdminMenu:GiveWeapon",
    "esx:revive",
    "esx_ambulancejob:revive",
    "ems:revive"
}

local function BanPlayer(source, reason)
    local playerName = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source) -- Récupère tous les identifiants du joueur
    local license = "Unknown"

    -- Trouve l'identifiant de type "license:"
    for _, id in pairs(identifiers) do
        if string.sub(id, 1, 7) == "license" then
            license = id
            break
        end
    end

    local banId = math.random(100000, 999999) -- ID unique pour le ban

    print(string.format("[Belhorm A-C] 🚨 BANNI: %s (%d) - Raison: %s", playerName, source, reason))

    -- Insérer le ban dans la base de données (colonne `license` au lieu de `identifier`)
    exports.oxmysql:execute('INSERT INTO bans (license, reason, ban_id, banned_at) VALUES (?, ?, ?, NOW())', {
        license,
        reason,
        banId
    }, function()
        -- Expulse le joueur après l'insertion en base
        DropPlayer(source, "[Belhorm A-C] Vous avez été banni pour: " .. reason)
    end)
end


-- Détection d'événements interdits (triches connues)
for _, eventName in ipairs(forbiddenEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        local src = source
        print(string.format("[Belhorm A-C] ⚠️ Tentative d'utilisation de '%s' par %s (%d)", eventName, GetPlayerName(src), src))
        BanPlayer(src, "Tentative d'utilisation d'un événement interdit: " .. eventName)
    end)
end

-- Détection et bannissement des tricheurs envoyés par le client
RegisterNetEvent("anti:cheatDetection")
AddEventHandler("anti:cheatDetection", function(type, value)
    local src = source
    local playerName = GetPlayerName(src)

    if type == "noclip" then
        print(string.format("[Belhorm A-C] 🚨 Noclip détecté chez %s (%d) - Distance: %.2f m", playerName, src, value))
        BanPlayer(src, "Noclip détecté (déplacement anormal de " .. value .. "m)")

    elseif type == "invincibility" then
        print(string.format("[Belhorm A-C] 🚨 Invincibilité détectée chez %s (%d) - Santé: %d", playerName, src, value))
        BanPlayer(src, "Invincibilité détectée (santé: " .. value .. ")")

    elseif type == "invisibility" then
        print(string.format("[Belhorm A-C] 🚨 Invisibilité détectée chez %s (%d) - Alpha: %d", playerName, src, value))
        BanPlayer(src, "Invisibilité détectée (alpha: " .. value .. ")")

    elseif type == "teleport" then
        print(string.format("[Belhorm A-C] 🚨 Téléportation détectée chez %s (%d) - Distance: %.2f m", playerName, src, value))
        BanPlayer(src, "Téléportation détectée (distance: " .. value .. "m)")

    elseif type == "prop_spawn" then
        print(string.format("[Belhorm A-C] 🚨 Spawn de prop suspect chez %s (%d) - Modèle: %s", playerName, src, tostring(value)))
        BanPlayer(src, "Spawn de prop interdit détecté (modèle: " .. tostring(value) .. ")")

    end
end)

-- Détection d'arrêt de ressource (tentative de désactiver l'anti-cheat)
RegisterNetEvent("anti:resourceStopped")
AddEventHandler("anti:resourceStopped", function(resourceName)
    local src = source
    print(string.format("[Belhorm A-C] 🚨 Tentative d'arrêt de la ressource anti-cheat détectée chez %s (%d) - Ressource: %s", GetPlayerName(src), src, resourceName))
    BanPlayer(src, "Tentative d'arrêt de l'anti-cheat")
end)

-- Affichage du logo Belhorm A-C au démarrage
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- Petit délai pour éviter les bugs d'affichage

    -- Vérifie si la console supporte les couleurs ANSI
    local isWindows = os.getenv("OS") and string.find(os.getenv("OS"), "Windows")
    local orange = isWindows and "" or "\27[38;5;208m"  -- Désactive les couleurs si Windows ne supporte pas
    local reset = isWindows and "" or "\27[0m"

    local asciiArt = [[
     ██████╗ ███████╗██╗      ██╗  ██╗ ██████╗ ██████╗ ███╗   ███╗
     ██╔══██╗██╔════╝██║      ██║  ██║██╔═══██╗██╔══██╗████╗ ████║
     ███████║█████╗  ██║      ███████║██║   ██║██████╔╝██╔████╔██║
     ██║  ██║██╔══╝  ██║      ██╔══██║██║   ██║██╔══██╗██║╚██╔╝██║
     ██████╔╝███████╗███████╗ ██║  ██║╚██████╔╝██║  ██║██║ ╚═╝ ██║
     ╚═════╝ ╚══════╝╚══════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
                       🛡️ BELHORM-AC BY REVIEWB 🛡️  
    ]]    

    print(orange .. asciiArt .. reset)  -- Affiche en couleur si possible
end)
