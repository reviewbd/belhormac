
local heartbeatInterval = 10000          
local noclipSpeedThreshold = 15.0        
local freecamDistanceThreshold = 25.0   
local teleportThreshold = 50.0           
local lastPos = nil
local lastHeartbeat = GetGameTimer()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(heartbeatInterval)
        TriggerServerEvent("anti:heartbeat")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local currentPos = GetEntityCoords(ped)
            if lastPos then
                local distance = #(currentPos - lastPos)
                local speed = distance / 0.5  
                if speed > noclipSpeedThreshold then
                    TriggerServerEvent("anti:playerNoclip", speed)
                end
            end
            lastPos = currentPos
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local pedPos = GetEntityCoords(ped)
            local camPos = GetGameplayCamCoord()
            local distance = #(camPos - pedPos)
            if distance > freecamDistanceThreshold then
                TriggerServerEvent("anti:freecamDetected", distance)
            end
        end
    end
end)

RegisterNetEvent("anti:propSpawned")
AddEventHandler("anti:propSpawned", function(propModel)
    TriggerServerEvent("anti:propSpawned", propModel)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        if IsPedDeadOrDying(ped, true) then
            TriggerServerEvent("anti:reviveDetected", true)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if GetGameTimer() - lastHeartbeat > 15000 then  
            TriggerServerEvent("anti:heartbeat", "missing")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local alpha = GetEntityAlpha(ped)
            if alpha < 255 then
                TriggerServerEvent("anti:invisibleDetected", alpha)
            end
            if IsPedInvincible(ped) then
                TriggerServerEvent("anti:invincibleDetected")
            end
        end
    end
end)

-- Détection de la téléportation
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local currentPos = GetEntityCoords(ped)
            if lastPos then
                local distance = #(currentPos - lastPos)
                if distance > teleportThreshold then
                    TriggerServerEvent("anti:teleportDetected", distance)
                end
            end
            lastPos = currentPos
        end
    end
end)

-- Détection de l'arrêt de la ressource anti-cheat
AddEventHandler("onClientResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent("anti:resourceStopped", resource)
    end
end)

AddEventHandler("onClientResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        Citizen.CreateThread(function()
            while true do end
        end)
    end
end)
