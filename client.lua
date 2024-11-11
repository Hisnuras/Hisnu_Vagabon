local rectangle
local blip
local isInsideZone = false  -- Variable pour suivre si le joueur est dans la zone

-- Fonction pour recharger les coordonnées et la couleur du rectangle depuis `config.lua`
local function loadConfig()
    rectangle = Config.RectangleCoords
    local color = Config.RectangleColor  -- On s'assure que la couleur est un entier

    if blip then
        RemoveBlip(blip)  -- Supprimer l'ancien blip si existant
    end

    if #rectangle == 4 then
        -- Calcul du centre du rectangle (moyenne des coordonnées des 4 points)
        local centerX = (rectangle[1].x + rectangle[2].x + rectangle[3].x + rectangle[4].x) / 4
        local centerY = (rectangle[1].y + rectangle[2].y + rectangle[3].y + rectangle[4].y) / 4
        local centerZ = (rectangle[1].z + rectangle[2].z + rectangle[3].z + rectangle[4].z) / 4

        -- Calcul du rayon en fonction de la distance maximale entre les points
        local maxDistance = 0
        for i = 1, 4 do
            for j = i + 1, 4 do
                local dist = #(vector2(rectangle[i].x, rectangle[i].y) - vector2(rectangle[j].x, rectangle[j].y))
                if dist > maxDistance then
                    maxDistance = dist
                end
            end
        end
        local radius = maxDistance / 2  -- Rayon correspondant à la moitié de la distance maximale

        -- Créer un `blip` pour la zone
        blip = AddBlipForRadius(centerX, centerY, centerZ, radius)
        
        -- Configurer le `blip` pour afficher la couleur depuis `Config`
        SetBlipColour(blip, color)  -- Utilise la couleur de `Config.RectangleColor` sans ligne supplémentaire
        SetBlipAlpha(blip, 128)      -- Transparence
        SetBlipAsShortRange(blip, true)

        -- Débogage
        print("Rectangle chargé avec succès. Centre :", centerX, centerY, centerZ, "Rayon :", radius)
    else
        print("Erreur : Veuillez définir exactement 4 coordonnées dans config.lua pour dessiner la zone.")
    end
end

-- Appeler `loadConfig` au démarrage pour initialiser les valeurs
loadConfig()

-- Vérifier si un point est dans le rectangle
local function isPointInRectangle(x, y, rect)
    local function crossProduct(x1, y1, x2, y2)
        return x1 * y2 - y1 * x2
    end

    local AB = vector2(rect[2].x - rect[1].x, rect[2].y - rect[1].y)
    local AM = vector2(x - rect[1].x, y - rect[1].y)
    local BC = vector2(rect[3].x - rect[2].x, rect[3].y - rect[2].y)
    local BM = vector2(x - rect[2].x, y - rect[2].y)
    local CD = vector2(rect[4].x - rect[3].x, rect[4].y - rect[3].y)
    local CM = vector2(x - rect[3].x, y - rect[3].y)
    local DA = vector2(rect[1].x - rect[4].x, rect[1].y - rect[4].y)
    local DM = vector2(x - rect[4].x, y - rect[4].y)

    local inside = crossProduct(AB.x, AB.y, AM.x, AM.y) >= 0 and
                   crossProduct(BC.x, BC.y, BM.x, BM.y) >= 0 and
                   crossProduct(CD.x, CD.y, CM.x, CM.y) >= 0 and
                   crossProduct(DA.x, DA.y, DM.x, DM.y) >= 0

    return inside
end

-- Fonction pour supprimer les animaux de la zone
local function removeAnimalsInZone()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Recherche des entités proches dans un rayon de 50 unités
    local entities = GetNearbyEntities(playerCoords, 50.0)
    for _, entity in pairs(entities) do
        if IsEntityAnAnimal(entity) then
            local entityModel = GetEntityModel(entity)
            for _, animalModel in pairs(Config.AnimalModelsToRemove) do
                if entityModel == GetHashKey(animalModel) then
                    DeleteEntity(entity)  -- Supprime l'animal
                    print("Animal supprimé : " .. animalModel)
                end
            end
        end
    end
end

-- Fonction pour obtenir les entités proches dans un rayon donné
function GetNearbyEntities(center, radius)
    local entities = {}
    local handle, entity = FindFirstObject()
    local success
    repeat
        local coords = GetEntityCoords(entity)
        local distance = #(coords - center)
        if distance < radius then
            table.insert(entities, entity)
        end
        success, entity = FindNextObject(handle)
    until not success
    EndFindObject(handle)
    return entities
end

-- Vérifier si le joueur entre ou sort de la zone
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)  -- Vérifier toutes les 500 ms pour rendre le processus plus réactif

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local inside = isPointInRectangle(playerCoords.x, playerCoords.y, rectangle)
        
        if inside and not isInsideZone then
            -- Le joueur est entré dans la zone
            isInsideZone = true

            -- Augmenter la densité des PNJ dans la zone
            SetPedDensityMultiplierThisFrame(10.0)  -- Augmenter la densité des PNJ
            SetScenarioPedDensityMultiplierThisFrame(10.0, 10.0)  -- Densité des scénarios de PNJ

            -- Supprimer les animaux
            removeAnimalsInZone()
            
            -- Débogage
            print("Densité des PNJ augmentée dans la zone et suppression des animaux.")
        elseif not inside and isInsideZone then
            -- Le joueur est sorti de la zone
            isInsideZone = false

            -- Réduire la densité des PNJ en dehors de la zone
            SetPedDensityMultiplierThisFrame(1.0)  -- Densité normale en dehors de la zone
            SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)  -- Densité normale des scénarios de PNJ

            -- Débogage
            print("Densité des PNJ rétablie à la normale en dehors de la zone.")
        end
    end
end)

-- Réagir au redémarrage pour recharger les nouvelles valeurs du `config.lua`
RegisterNetEvent('reloadZoneConfig')
AddEventHandler('reloadZoneConfig', function()
    loadConfig()
end)
