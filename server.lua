-- Charger la configuration et envoyer une notification au client
RegisterCommand("reloadconfig", function(source, args, rawCommand)
    TriggerClientEvent('reloadZoneConfig', -1)
    print("Configuration de la zone rechargée.")
end)
