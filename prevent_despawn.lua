
-- Main thread to prevent vehicle despawn
Citizen.CreateThread(function()
    while true do
        -- Wait 10 seconds between each check to reduce performance impact
        Citizen.Wait(10000)

        -- Get all vehicles in the world
        local vehicles = GetAllVehicles()

        for _, vehicle in ipairs(vehicles) do
            -- Check if the vehicle exists
            if DoesEntityExist(vehicle) then
                -- Prevent the vehicle from despawning
                SetEntityAsMissionEntity(vehicle, true, true)
            end
        end
    end
end)

-- Check if the player is using no-clip or spectating and prevent vehicle despawn
Citizen.CreateThread(function()
    while true do
        -- Wait 1 second between each check to reduce performance impact
        Citizen.Wait(1000)

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if DoesEntityExist(vehicle) then
                -- Prevent the vehicle from despawning
                SetEntityAsMissionEntity(vehicle, true, true)
            end
        else
            local specTarget = NetworkIsInSpectatorMode()
            if specTarget then
                local vehicle = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(specTarget)), false)
                if DoesEntityExist(vehicle) then
                    -- Prevent the vehicle from despawning
                    SetEntityAsMissionEntity(vehicle, true, true)
                end
            end
        end
    end
end)

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
