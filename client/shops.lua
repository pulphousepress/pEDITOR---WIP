-- la_peditor/client/shops.lua
-- Simple world markers for clothing shops and barber shops
-- that open the la_peditor wrapper or Illenium, depending on backend.

local clothingShops = Config.ClothingShops or {
    { coords = vector3(72.3, -1399.1, 29.4), label = 'Clothing shop' },
    { coords = vector3(-712.2, -155.4, 37.4), label = 'Clothing shop' },
}

local barberShops = Config.BarberShops or {
    { coords = vector3(-814.3, -183.8, 37.6), label = 'Barber shop' },
    { coords = vector3(136.8, -1708.4, 29.3), label = 'Barber shop' },
}

local interactKey = 38 -- E

local function draw3DText(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(true)

    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function drawMarkerAt(coords)
    DrawMarker(
        1,
        coords.x, coords.y, coords.z - 1.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 1.0, 1.0,
        255, 255, 255, 120,
        false, false, 2, false, nil, nil, false
    )
end

local function canUsePeditor()
    if type(canOpenSkinMenu) == 'function' then
        return canOpenSkinMenu()
    end

    return true
end

local function openClothing()
    local bridge = exports['la_peditor']:AppearanceBridge()
    if bridge and bridge.openClothingShop then
        bridge.openClothingShop()
        return
    end

    -- Fallback
    exports['la_peditor']:openSkinEditor('clothing')
end

local function openBarber()
    local bridge = exports['la_peditor']:AppearanceBridge()
    if bridge and bridge.openBarberShop then
        bridge.openBarberShop()
        return
    end

    -- Fallback
    exports['la_peditor']:openSkinEditor('barber')
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)

        -- Clothing shops
        for _, shop in ipairs(clothingShops) do
            local coords = shop.coords
            local dist = #(pCoords - coords)

            if dist < 20.0 then
                sleep = 0
                drawMarkerAt(coords)
            end

            if dist < 2.0 then
                draw3DText(coords.x, coords.y, coords.z + 0.2, '[E] ' .. (shop.label or 'Open wardrobe'))

                if IsControlJustReleased(0, interactKey) and canUsePeditor() then
                    openClothing()
                end
            end
        end

        -- Barber shops
        for _, shop in ipairs(barberShops) do
            local coords = shop.coords
            local dist = #(pCoords - coords)

            if dist < 20.0 then
                sleep = 0
                drawMarkerAt(coords)
            end

            if dist < 2.0 then
                draw3DText(coords.x, coords.y, coords.z + 0.2, '[E] ' .. (shop.label or 'Barber services'))

                if IsControlJustReleased(0, interactKey) and canUsePeditor() then
                    openBarber()
                end
            end
        end

        Wait(sleep)
    end
end)
