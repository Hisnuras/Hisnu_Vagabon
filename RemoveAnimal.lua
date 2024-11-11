local rectangle = Config.RectangleCoords

-- Fonction pour vérifier si un point est à l'intérieur du rectangle
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

-- Fonction pour rendre les animaux inoffensifs dans la zone
local function makeAnimalsHarmlessInZone()
    local animalsToRemove = Config.AnimalModelsToRemove  -- Liste des animaux à neutraliser

    -- Recherche des entités proches dans un rayon autour du joueur
    local playerPed = PlayerPedId()  -- Obtenez le ped du joueur
    local playerCoords = GetEntityCoords(playerPed)
    local radius = 50.0  -- Rayon de recherche pour les animaux à neutraliser

    -- Recherche des animaux dans la zone
    for _, animalModel in ipairs(animalsToRemove) do
        local animalHash = GetHashKey(animalModel)

        -- Recherche des animaux dans le rayon défini
        local handle, entity = FindFirstObject()
        local success
        repeat
            local entityCoords = GetEntityCoords(entity)
            local distance = #(playerCoords - entityCoords)

            -- Vérifier si l'entité est un animal et si elle est dans le rayon
            if IsEntityAPed(entity) and distance <= radius then
                local entityModel = GetEntityModel(entity)
                if entityModel == animalHash then
                    -- Vérifie si l'animal est dans la zone définie par le rectangle
                    if isPointInRectangle(entityCoords.x, entityCoords.y, rectangle) then
                        -- Rendre l'animal inoffensif
                        SetEntityInvincible(entity, true)  -- L'animal devient invincible
                        SetEntityCanBeDamaged(entity, false)  -- L'animal ne peut pas être endommagé
                        TaskSetBlockingOfNonTemporaryEvents(entity, true)  -- Bloque les événements non temporaires

                        -- Annule les comportements agressifs de l'animal
                        ClearPedTasksImmediately(entity)  -- Annule toutes les tâches
                        TaskWanderStandard(entity, 10.0, 10)  -- L'animal va errer calmement sans réagir au joueur

                        -- Définit l'animal comme ami et l'empêche d'attaquer
                        SetPedAsFriendly(entity, true)  -- L'animal est ami
                        SetPedAsEnemy(entity, false)  -- L'animal n'est pas l'ennemi
                        SetPedRelationshipGroupHash(entity, GetHashKey("PLAYER"))  -- L'animal considère le joueur comme ami
                        SetPedFleeAttributes(entity, 0, false)  -- L'animal ne fuit pas

                        -- Désactive toutes les capacités de combat
                        SetPedCombatAttributes(entity, 0, false)  -- Désactive toutes les capacités de combat
                        SetPedCombatAttributes(entity, 1, false)  -- Désactive l'agressivité de l'animal
                        SetPedCombatAttributes(entity, 5, false)  -- Désactive les attaques sur le joueur

                        -- Empêcher l'animal de suivre des actions agressives
                        SetPedAlertness(entity, 0)  -- L'animal n'est pas alerté
                        SetPedAggressionLevel(entity, 0)  -- L'animal ne devient pas agressif

                        -- Désactive les réactions agressives (combat et fuite)
                        SetPedCombatMovement(entity, 0)  -- L'animal ne se bat pas
                        SetPedCombatRange(entity, 0)  -- L'animal ne réagira pas à la distance

                        -- Gérer l'hostilité envers le joueur
                        SetPedAvoidanceRadius(entity, 0.0)  -- L'animal ne fuira pas le joueur

                        -- Mettre l'animal en mode pacifique
                        TaskWanderStandard(entity, 10.0, 10)  -- L'animal va errer calmement sans réagir au joueur

                        print("Animal rendu inoffensif : " .. animalModel)
                    end
                end
            end
            success, entity = FindNextObject(handle)
        until not success
        EndFindObject(handle)
    end
end

-- Vérifier régulièrement les animaux dans la zone
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)  -- Vérifier toutes les 500 ms

        -- Rendre les animaux inoffensifs dans la zone
        makeAnimalsHarmlessInZone()
    end
end)
