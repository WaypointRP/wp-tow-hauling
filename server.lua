if Config.EnableTowCommands then
    RegisterCommand("tow", function(source, args)
        TriggerClientEvent("wp-hauling:client:startTowSelection", source)
    end)

    RegisterCommand("untow", function(source, args)
        TriggerClientEvent("wp-hauling:client:startUntowSelection", source)
    end)
end

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Give the script some time to start
        Wait(100)

        ValidateOxLibUsage()
    end
end)
