if Config.EnableTowCommands then
    RegisterCommand("tow", function(source, args)
        TriggerClientEvent('wp-hauling:client:startTowSelection', source)
    end)

    RegisterCommand("untow", function(source, args)
        TriggerClientEvent('wp-hauling:client:startUntowSelection', source)
    end)
end
