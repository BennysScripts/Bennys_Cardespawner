
-- Table to store vehicles that shouldn't despawn
local savedVehicles = {}

-- Function to get all vehicles in the world
function GetAllVehicles()
    local vehicles = {}
    local handle, vehicle = FindFirstVehicle()
    local success
    repeat
        if DoesEntityExist(vehicle) then
            table.insert(vehicles, vehicle)
        end
        success, vehicle = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)
    return vehicles
end

-- Function to prevent vehicle from despawning
function PreventVehicleDespawn(vehicle)
    if DoesEntityExist(vehicle) and not savedVehicles[vehicle] then
        SetEntityAsMissionEntity(vehicle, true, true)
        savedVehicles[vehicle] = true
    end
end

-- Main thread to prevent all vehicles from despawning
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Wait 10 seconds between each check to reduce performance impact

        local vehicles = GetAllVehicles()
        for _, vehicle in ipairs(vehicles) do
            PreventVehicleDespawn(vehicle)
        end
    end
end)

-- Check if the player is using no-clip or spectating and prevent vehicle despawn
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Wait 1 second between each check to reduce performance impact

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            PreventVehicleDespawn(vehicle)
        else
            local specTarget = NetworkIsInSpectatorMode()
            if specTarget then
                local targetPed = GetPlayerPed(GetPlayerFromServerId(specTarget))
                if IsPedInAnyVehicle(targetPed, false) then
                    local vehicle = GetVehiclePedIsIn(targetPed, false)
                    PreventVehicleDespawn(vehicle)
                end
            end
        end
    end
end)

-- Remove from savedVehicles table if vehicle is deleted
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Check every 10 seconds

        for vehicle in pairs(savedVehicles) do
            if not DoesEntityExist(vehicle) then
                savedVehicles[vehicle] = nil
            end
        end
    end
end)