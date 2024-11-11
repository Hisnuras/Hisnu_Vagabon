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

-- Appliquer directement la densité des PNJ dans la zone au démarrage
local function increasePnjDensity()
    -- Augmenter la densité des PNJ
    SetPedDensityMultiplierThisFrame(100.0)
    SetScenarioPedDensityMultiplierThisFrame(100.0, 100.0)

    --print("Densité des PNJ augmentée dans la zone.")
end

-- Appliquer la densité des PNJ dès que le serveur démarre
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)  -- On vérifie chaque demi-seconde

        -- Appliquer la densité des PNJ sans attendre un joueur dans la zone
        increasePnjDensity()
    end
end)
