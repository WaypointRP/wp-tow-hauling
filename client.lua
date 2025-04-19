if Config.EnableTowCommands then
    CreateThread(function()
        TriggerEvent("chat:addSuggestion", "/tow", "Start the process to tow/attach a vehicle.")
        TriggerEvent("chat:addSuggestion", "/untow", "Start the process to untow a specific attached vehicle.")
    end)
end

-- Requests network control of an entity
local function RequestNetworkControlOfObject(netId, itemEntity)
    if NetworkDoesNetworkIdExist(netId) then
        NetworkRequestControlOfNetworkId(netId)
        while not NetworkHasControlOfNetworkId(netId) do
            Wait(100)
            NetworkRequestControlOfNetworkId(netId)
        end
    end

    if DoesEntityExist(itemEntity) then
        NetworkRequestControlOfEntity(itemEntity)
        while not NetworkHasControlOfEntity(itemEntity) do
            Wait(100)
            NetworkRequestControlOfEntity(itemEntity)
        end
    end
end

-- Checks if the vehicle is allowed to be used to tow
--- @param vehicle - The vehicle entity to check
--- @return boolean - True/false if the vehicle is allowed to be used to tow
local function isAllowedTowVehicle(vehicle)
    if Config.AllowAllVehiclesToTow then return true end

    local isAllowed = false
    for _, veh in pairs(Config.AllowedTowVehicles) do
        if GetEntityModel(vehicle) == GetHashKey(veh) then
            isAllowed = true
            break
        end
    end

    return isAllowed
end

-- Draws a marker above the target object that the player is looking at
-- If the object is hovered, it will draw a yellow marker, once selected it will draw a red marker
-- This needs to be called every frame to render correctly
--- @param targetVehicle - The vehicle entity to draw the marker on
--- @param isSelected boolean - Whether the vehicle had already been selected or is just hovered over
--- @param markerType number - The type of marker to draw
local function DrawMarkerOnTarget(targetVehicle, isSelected, markerType)
    -- local markerType = 0
    local scale = 0.3
    local alpha = 255
    local bounce = true
    local faceCam = false
    local iUnk = 0
    local rotate = false
    local textureDict = nil
    local textureName = nil
    local drawOnEnts = false
    local pos = GetEntityCoords(targetVehicle, true)
    local colorYellow = { red = 255, green = 255, blue = 0, }
    local colorRed = { red = 255, green = 50, blue = 0, }
    local color = colorYellow
    -- If isSelected then use color red, else use color yellow
    if isSelected then color = colorRed end

    DrawMarker(markerType, pos.x, pos.y, pos.z + 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, scale - 0.1, color.red, color.green, color.blue, alpha, bounce, faceCam, iUnk, rotate, textureDict, textureName, drawOnEnts)
end

-- Used by the raycast functions to get the direction the camera is looking
local function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z,
    }

    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x),
    }

    return direction
end

-- Uses a RayCast to get the entity, coords, and whether we "hit" something with the raycast
--- @param distance - The distance to cast the ray
--- @return hit, coords, entity - Whether the raycast hit something, the coords of the hit, and the entity that was hit
local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance,
    }

    local _, hit, coords, _, entity = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return hit, coords, entity
end

-- Draws a line and marker at the end of the raycast where the player is looking
--- @param coords - The coords to draw the line and marker at
local function DrawRayCastLine(coords)
    local color = { r = 37, g = 192, b = 192, a = 200, }
    local position = GetEntityCoords(PlayerPedId())

    if coords.x ~= 0.0 and coords.y ~= 0.0 then
        DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
        DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.05, 0.05, 0.05, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
    end
end

-- Activates the ray cast mode to get the target object the player is looking at
-- Listens for keypress to detect when the player has selected the target
-- Checks if the vehicle is allowed to be used to tow and that the vehicle is not the same as the already selected vehicle
--- @param shouldCheckAllowedVehicles - boolean - Whether to check if the vehicle is allowed to be used to tow
--- @param otherSelectedVehicle - The vehicle entity that has already been selected
--- @param shouldDrawOutline - boolean - Whether to draw an outline on the selected vehicle/object
--- @return vehicle - The vehicle entity that the player has selected
local function rayCastGetSelectedVehicle(shouldCheckAllowedVehicles, otherSelectedVehicle, shouldDrawOutline)
    local hit, coords, targetObj = RayCastGamePlayCamera(Config.TowDistance)

    -- Draw the line to the coords where the player is looking
    DrawRayCastLine(coords)

    if hit and DoesEntityExist(targetObj) and targetObj ~= otherSelectedVehicle and (Config.AllowHaulingProps or IsEntityAVehicle(targetObj)) then
        DrawMarkerOnTarget(targetObj, false, 0)

        -- Listen for keypress of ConfirmVehicleSelectionKey key
        if (IsControlJustPressed(0, Config.ConfirmVehicleSelectionKey)) then
            if not shouldCheckAllowedVehicles or isAllowedTowVehicle(targetObj) then
                if shouldDrawOutline then
                    SetEntityDrawOutline(targetObj, true)
                    SetEntityDrawOutlineColor(0, 255, 255, 255)
                    SetEntityDrawOutlineShader(0)
                end

                return targetObj
            end
        end
    end
end

-- Attaches the targetObject onto the towVehicle in its current position,
-- respecting both the targetObjects rotation and offset from the towVehicle
-- If the vehicle + object are not touching, it will not attach them
--- @param towVehicle - The vehicle entity that will be doing the towing
--- @param targetObject - The vehicle entity that will be towed
local function attachTargetObjectToTowVehicle(towVehicle, targetObject)
    local towNetId = NetworkGetNetworkIdFromEntity(towVehicle)
    local targetNetId = NetworkGetNetworkIdFromEntity(targetObject)

    -- Get control of the entities. This makes it so you dont need to sit in the vehicle first
    RequestNetworkControlOfObject(targetNetId, targetObject)
    RequestNetworkControlOfObject(towNetId, towVehicle)

    -- Necessary to make sure the player has control of both entities
    Wait(500)

    local isTargetTouchingTowVehicle = IsEntityTouchingEntity(towVehicle, targetObject)

    if isTargetTouchingTowVehicle then
        -- Calculate target object rotation relative to the tow vehicle
        -- This ensures that the object maintains its current rotation when attached to the tow vehicle
        local targetObjectRotation = GetEntityRotation(targetObject, 2)
        local towVehicleRotation = GetEntityRotation(towVehicle, 2)
        local newRotX = targetObjectRotation.x - towVehicleRotation.x
        local newRotY = targetObjectRotation.y - towVehicleRotation.y
        local newRotZ = targetObjectRotation.z - towVehicleRotation.z

        -- This ensures the target vehicle is attached to the tow vehicle at its current position
        local offsetCoords = GetOffsetFromEntityGivenWorldCoords(towVehicle, GetEntityCoords(targetObject))

        AttachEntityToEntity(targetObject, towVehicle, 0, offsetCoords.x, offsetCoords.y, offsetCoords.z, newRotX, newRotY, newRotZ, 0, true, true, false, 2, true)

        Notify("Object has been strapped down.", "success", 5000)
    else
        Notify("Target object must be touching the tow vehicle in order to be towed", "error", 7500)
    end
end

-- Run a thread to handle selecting the tow vehicle and target vehicle
local function startTowingSelectMode()
    local towVehicle = nil
    local targetObject = nil

    local hasNotifiedSelectTowTruck = false
    local hasNotifiedSelectTarget = false
    local hasNotifiedConfirm = false

    local isTowingSelectModeEnabled = true

    CreateThread(function()
        local instructionalButtons = nil

        while isTowingSelectModeEnabled do
            -- STEP 1: Runs a raycast to get the vehicle the player wants to tow to
            if not towVehicle then
                if not hasNotifiedSelectTowTruck then
                    hasNotifiedSelectTowTruck = true
                    instructionalButtons = DrawInstructionalButtons(Config.ConfirmVehicleSelectionKey, "Select tow vehicle", Config.ExitVehicleSelectionKey, "Cancel")
                end

                towVehicle = rayCastGetSelectedVehicle(true, nil, true)
                -- STEP 2: Runs a raycast to get the vehicle/object the player wants to be towed
            elseif not targetObject then
                if not hasNotifiedSelectTarget then
                    hasNotifiedSelectTarget = true
                    instructionalButtons = DrawInstructionalButtons(Config.ConfirmVehicleSelectionKey, "Select target to tow", Config.ExitVehicleSelectionKey, "Cancel")
                end

                targetObject = rayCastGetSelectedVehicle(false, towVehicle, true)
                -- STEP 3: Notify the player to press ConfirmVehicleSelectionKey to confirm the selections and complete the tow
            else
                if not hasNotifiedConfirm then
                    hasNotifiedConfirm = true
                    instructionalButtons = DrawInstructionalButtons(Config.ConfirmVehicleSelectionKey, "Confirm selection", Config.ExitVehicleSelectionKey, "Cancel")
                end

                -- Listen for keypress of the selection key to attach the vehicles together
                if (IsControlJustPressed(0, Config.ConfirmVehicleSelectionKey)) then
                    isTowingSelectModeEnabled = false

                    -- Remove outlines on confirm
                    SetEntityDrawOutline(towVehicle, false)
                    SetEntityDrawOutline(targetObject, false)

                    attachTargetObjectToTowVehicle(towVehicle, targetObject)
                end
            end

            -- Draw markers on selected tow vehicle
            if towVehicle and isTowingSelectModeEnabled then
                DrawMarkerOnTarget(towVehicle, true, 39)
            end

            -- Listen for keypress of exit vehicle selection key to break out of the thread and cancel select mode
            if (IsControlJustPressed(0, Config.ExitVehicleSelectionKey)) then
                SetEntityDrawOutline(towVehicle, false)
                SetEntityDrawOutline(targetObject, false)
                isTowingSelectModeEnabled = false
            end

            DrawScaleformMovieFullscreen(instructionalButtons, 255, 255, 255, 255, 0)

            Wait(1)
        end
    end)
end

-- Run a thread to handle selecting the target vehicle that you want to untow
local function startUnTowSelectMode()
    local targetObject = nil

    local isUnTowingSelectModeEnabled = true

    local instructionalButtons = DrawInstructionalButtons(Config.ConfirmVehicleSelectionKey, "Select target to untow", Config.ExitVehicleSelectionKey, "Cancel")

    CreateThread(function()
        while isUnTowingSelectModeEnabled do
            -- targetObject will be undefined until the player selects it from the raycast selection mode
            targetObject = rayCastGetSelectedVehicle(false, nil, false)

            if targetObject and IsEntityAttachedToAnyVehicle(targetObject) then
                -- Get control of the entities. This makes it so you dont need to sit in the vehicle first
                local netId = NetworkGetNetworkIdFromEntity(targetObject)
                RequestNetworkControlOfObject(netId, targetObject)
                Wait(500)

                DetachEntity(targetObject, true, false)
                isUnTowingSelectModeEnabled = false

                Notify("Vehicle detached", "success", 3000)
            elseif targetObject then
                Notify("Vehicle is not attached to anything", "error", 3000)
            end

            -- Listen for keypress of exit vehicle selection key to exit out of the loop
            if (IsControlJustPressed(0, Config.ExitVehicleSelectionKey)) then
                -- Exit out of the thread and reset any variables
                isUnTowingSelectModeEnabled = false
            end

            DrawScaleformMovieFullscreen(instructionalButtons, 255, 255, 255, 255, 0)

            Wait(1)
        end
    end)
end

RegisterNetEvent("wp-hauling:client:startTowSelection", function()
    startTowingSelectMode()
end)

RegisterNetEvent("wp-hauling:client:startUntowSelection", function()
    startUnTowSelectMode()
end)
