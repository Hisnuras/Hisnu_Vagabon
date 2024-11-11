-- coord_display.lua

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Obtenir la position du joueur
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Afficher les coordonnées sur l'écran
        DrawTextOnScreen(string.format("X: %.2f, Y: %.2f, Z: %.2f", playerCoords.x, playerCoords.y, playerCoords.z), 0.005, 0.005)
    end
end)

-- Fonction pour afficher le texte à l'écran
function DrawTextOnScreen(text, x, y)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)  -- Couleur blanche
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
