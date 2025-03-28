local function NotifyCheat(type, value)
    TriggerServerEvent("anti:cheatDetection", type, value)
end

-- Vérification du Noclip (vitesse anormale)
Citizen.CreateThread(function()
    local lastPos = GetEntityCoords(PlayerPedId())
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        local newPos = GetEntityCoords(ped)
        local distance = #(newPos - lastPos)

        if not IsPedInAnyVehicle(ped, false) and distance > 10.0 then -- Distance anormale (noclip ou TP)
            NotifyCheat("noclip", distance)
        end

        lastPos = newPos
    end
end)

-- Vérification de l'Invincibilité
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000) -- Vérifie toutes les 3 secondes
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)

        if health > 200 then
            NotifyCheat("invincibility", health)
        end
    end
end)

-- Vérification de l'Invisibilité
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        local ped = PlayerPedId()
        local alpha = GetEntityAlpha(ped)

        if alpha < 150 then -- Si l'opacité est inférieure à 150, suspect
            NotifyCheat("invisibility", alpha)
        end
    end
end)

-- Détection de téléportation (déplacement rapide anormal)
Citizen.CreateThread(function()
    local lastPos = GetEntityCoords(PlayerPedId())
    while true do
        Citizen.Wait(1000)
        local newPos = GetEntityCoords(PlayerPedId())
        local distance = #(newPos - lastPos)

        if distance > 50.0 then -- Se téléporter sur une grande distance
            NotifyCheat("teleport", distance)
        end

        lastPos = newPos
    end
end)

-- Détection du spawn de props (Objets non autorisés)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        for _, entity in ipairs(GetGamePool("CObject")) do
            local model = GetEntityModel(entity)
            local owner = NetworkGetEntityOwner(entity)

            if owner == PlayerId() then
                NotifyCheat("prop_spawn", model)
            end
        end
    end
end)
