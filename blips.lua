--[[
Citizen.CreateThread(function()
    -- Récupère les 4 coordonnées depuis le config.lua
    local coords = Config.RectangleCoords
    local color = Config.RectangleColor

    -- Affiche les 4 coordonnées dans la console
    print("Coordonnées du rectangle:")
    for i, coord in ipairs(coords) do
        print(string.format("Coordonnée %d: x = %.2f, y = %.2f, z = %.2f", i, coord.x, coord.y, coord.z))

        -- Crée un blip pour chaque coordonnée
        local blip = AddBlipForCoord(coord.x, coord.y, coord.z)
        
        -- Configuration du blip
        SetBlipSprite(blip, 1)  -- Icône du blip (1 = point standard)
        SetBlipDisplay(blip, 4) -- Affichage sur la minimap et dans le menu pause
        SetBlipColour(blip, color)  -- Couleur du blip (1 = rouge)
        SetBlipAlpha(blip, 255) -- Opacité du blip
        
        -- Définir le nom du blip (optionnel)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Coordonnée " .. i)
        EndTextCommandSetBlipName(blip)
    end
end)
]]

Citizen.CreateThread(function()
    -- Récupère les 4 coordonnées depuis le config.lua
    local coords = Config.RectangleCoords
    local color = Config.RectangleColor

    -- Affiche les 4 coordonnées dans la console
    print("Coordonnées du rectangle:")
    for i, coord in ipairs(coords) do
        print(string.format("Coordonnée %d: x = %.2f, y = %.2f, z = %.2f", i, coord.x, coord.y, coord.z))
    end

    -- Calcul du centre de la zone (moyenne des coordonnées)
    local centerX = 0.0
    local centerY = 0.0
    local centerZ = 0.0

    for _, coord in ipairs(coords) do
        centerX = centerX + coord.x
        centerY = centerY + coord.y
        centerZ = centerZ + coord.z
    end

    centerX = centerX / #coords
    centerY = centerY / #coords
    centerZ = centerZ / #coords

    -- Calcul du rayon approximatif (distance entre le centre et un coin)
    local radius = math.sqrt((coords[1].x - centerX)^2 + (coords[1].y - centerY)^2)

    -- Créer un blip pour afficher une zone circulaire
    local blip = AddBlipForRadius(centerX, centerY, centerZ, radius)

    -- Configuration du blip (zone circulaire)
    SetBlipSprite(blip, 9)  -- Sprite du blip (9 = cercle)
    SetBlipDisplay(blip, 4) -- Affichage sur la minimap et dans le menu pause
    SetBlipColour(blip, color)  -- Couleur du blip (1 = rouge)
    SetBlipAlpha(blip, 64) -- Opacité (128 = 50% de transparence)

    -- Définir le nom du blip (optionnel)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Zone définie")
    EndTextCommandSetBlipName(blip)
end)