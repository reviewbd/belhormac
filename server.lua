local forbiddenEvents = {
    "esx:giveWeapon",             
    "AdminMenu:GiveWeapon",       
    "esx:revive",                
    "esx_ambulancejob:revive",   
    "ems:revive"                 
}

local function BanPlayer(source, reason)
    local playerName = GetPlayerName(source)
    print(string.format("[Belhorm A-C] BANNI: %s (%d) pour: %s", playerName, source, reason))
    DropPlayer(source, "[Belhorm A-C] Vous avez été banni pour: " .. reason)
end

for _, eventName in ipairs(forbiddenEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        local src = source
        print(string.format("[Belhorm A-C] Tentative d'appel de l'événement interdit '%s' par %s (%d)", eventName, GetPlayerName(src), src))
        BanPlayer(src, "[Belhorm A-C] Tentative d'exécution d'un événement interdit: " .. eventName)
    end)
end

RegisterNetEvent("anti:invisibleDetected")
AddEventHandler("anti:invisibleDetected", function(alpha)
    local src = source
    print(string.format("[Belhorm A-C] Invisibilité détectée chez %s (%d), alpha: %d", GetPlayerName(src), src, alpha))
    BanPlayer(src, "[Belhorm A-C] Invisibilité détectée (alpha: " .. alpha .. ")")
end)

RegisterNetEvent("anti:invincibleDetected")
AddEventHandler("anti:invincibleDetected", function()
    local src = source
    print(string.format("[Belhorm A-C] Invincibilité détectée chez %s (%d)", GetPlayerName(src), src))
    BanPlayer(src, "[Belhorm A-C] Invincibilité détectée")
end)

RegisterNetEvent("anti:teleportDetected")
AddEventHandler("anti:teleportDetected", function(distance)
    local src = source
    print(string.format("[Belhorm A-C] Téléportation détectée chez %s (%d), distance: %.2f m", GetPlayerName(src), src, distance))
    BanPlayer(src, "[Belhorm A-C] Téléportation détectée (distance: " .. distance .. " m)")
end)

RegisterNetEvent("anti:propSpawned")
AddEventHandler("anti:propSpawned", function(propModel)
    local src = source
    print(string.format("[Belhorm A-C] Spawn de prop détecté chez %s (%d), modèle: %s", GetPlayerName(src), src, tostring(propModel)))
    BanPlayer(src, "[Belhorm A-C] Spawn de prop non autorisé détecté (modèle: " .. tostring(propModel) .. ")")
end)

RegisterNetEvent("anti:playerNoclip")
AddEventHandler("anti:playerNoclip", function(speed)
    local src = source
    print(string.format("[Belhorm A-C] Noclip détecté chez %s (%d), vitesse: %.2f m/s", GetPlayerName(src), src, speed))
    BanPlayer(src, "[Belhorm A-C] Noclip détecté (vitesse anormale: " .. speed .. " m/s)")
end)

RegisterNetEvent("anti:heartbeat")
AddEventHandler("anti:heartbeat", function()
    local src = source
    print(string.format("[Belhorm A-C] Heartbeat reçu de %s (%d)", GetPlayerName(src), src))
end)

RegisterNetEvent("anti:resourceStopped")
AddEventHandler("anti:resourceStopped", function(resourceName)
    local src = source
    print(string.format("[Belhorm A-C] Tentative d'arrêt de la ressource anti-cheat détectée chez %s (%d), ressource: %s", GetPlayerName(src), src, resourceName))
    BanPlayer(src, "[Belhorm A-C] Tentative d'arrêt de la ressource anti-cheat")
end)
RegisterNetEvent("anti:resourceStopped")
AddEventHandler("anti:resourceStopped", function(resourceName)
    local src = source
    print(string.format("[Belhorm A-C] Tentative d'arrêt de l'anti-cheat par %s (%d) !", GetPlayerName(src), src))
    DropPlayer(src, "[Belhorm A-C] Vous avez été banni pour tentative d'arrêt de l'anti-cheat.")
end)

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

