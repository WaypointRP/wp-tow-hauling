-- IsDuplicityVersion - is used to determine if the function is called by the server or the client (true == from server)

--------------------- SHARED FUNCTIONS ---------------------
local Core = nil
--- @return table Core The core object of the framework
function GetCoreObject()
    if not Core then
        if Config.Framework == "esx" then
            Core = exports["es_extended"]:getSharedObject()
        elseif Config.Framework == "qb" or Config.Framework == "qbx" then
            Core = exports["qb-core"]:GetCoreObject()
        end
    end
    return Core
end

Core = Config.Framework ~= "none" and GetCoreObject() or nil

--- @param text string The text to show in the notification
--- @param notificationType string The type of notification to show ex: 'success', 'error', 'info'
--- @param src - number|nil The source of the player - only required when called from server side
function Notify(text, notificationType, src)
    if IsDuplicityVersion() then
        if Config.Notify == "esx" then
            TriggerClientEvent("esx:showNotification", src, text)
        elseif Config.Notify == "qb" then
            TriggerClientEvent("QBCore:Notify", src, text, notificationType)
        elseif Config.Notify == "ox" then
            TriggerClientEvent("ox_lib:notify", src, {
                description = text,
                type = notificationType,
            })
        end
    else
        if Config.Notify == "esx" then
            Core.ShowNotification(text)
        elseif Config.Notify == "qb" then
            Core.Functions.Notify(text, notificationType)
        elseif Config.Notify == "ox" then
            lib.notify({
                description = text,
                type = notificationType,
            })
        end
    end
end

--------------------- CLIENT FUNCTIONS ---------------------


--------------------- SERVER FUNCTIONS ---------------------

--- This function checks if any OX scripts are being used in the configuration
--- and throws an error if `ox_lib` is not properly enabled in the `fxmanifest.lua`.
--- 
--- **Usage**: Call this function on the server inside an `onResourceStart` event handler.
--- 
--- **Example**:
--- ```lua
--- AddEventHandler("onResourceStart", function(resourceName)
---     if GetCurrentResourceName() == resourceName then
---         Wait(100) -- Give the script some time to start
---         ValidateOxLibUsage()
---     end
--- end)
--- ```
function ValidateOxLibUsage()
    if not IsDuplicityVersion() then return end

    local isUsingOxScripts = Config.Notify == "ox"

    -- Ensure ox_lib is not commented out in the fxmanifest/shared_script section if any OX scripts are used in the Config.
    -- If ox_lib is commented out, display an error as the script will not function correctly.
    if isUsingOxScripts then
        local filePath = GetResourcePath(GetCurrentResourceName()) .. "/fxmanifest.lua"
        local file, _errorMsg = io.open(filePath, "r")
        if not file then return end

        -- Read through the fxmanifest file
        -- Find the line with "@ox_lib/init.lua" and check if it is commented out
        local isOxLibCommentedOut = false
        for line in file:lines() do
            if line:find("@ox_lib/init.lua") then
                -- Check if the line is commented out
                if line:match("^%s*%-%-") then
                    isOxLibCommentedOut = true
                end
                break
            end
        end

        file:close()

        if isOxLibCommentedOut then
            error(
                "\n=====================================\n\n" ..

                "YOU ARE USING OX SCRIPTS AND DID NOT UNCOMMENT OX_LIB IN THE FXMANIFEST!\n\n" ..

                "The script will not work until you uncomment it from the fxmanifest.\n\n" ..

                "=====================================\n"
            )
        end
    end
end
