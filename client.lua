local activeId = 0

local function normalizeType(notifyType)
    notifyType = tostring(notifyType or 'info'):lower()
    return Config.TypeAliases[notifyType] or notifyType
end

local function normalizeDuration(duration)
    duration = tonumber(duration)
    if not duration or duration <= 0 then
        return Config.DefaultDuration
    end

    -- Egyes scriptek másodpercben adnak meg értéket, ezt ms-re alakítjuk.
    if duration < 100 then
        duration = duration * 1000
    end

    return math.floor(duration)
end

local function cleanText(value)
    if value == nil then return '' end
    return tostring(value)
end

local function SendNotify(data)
    activeId = activeId + 1

    local notifyType = normalizeType(data.type or data.notifyType or 'info')
    local duration = normalizeDuration(data.duration or data.length or data.time)
    local title = cleanText(data.title)
    local message = cleanText(data.message or data.text or data.msg)

    if message == '' and title ~= '' then
        message = title
        title = ''
    end

    if message == '' then return end

    if title == '' then
        title = Config.Titles[notifyType] or Config.Titles['info'] or 'INFORMÁCIÓ'
    end

    SendNUIMessage({
        action = 'notify',
        id = activeId,
        type = notifyType,
        title = title,
        message = message,
        duration = duration,
        maxVisible = Config.MaxVisible,
        queue = Config.Queue,
        sound = Config.Sound,
        soundPack = Config.SoundPack,
        soundVolume = Config.SoundVolume,
        position = Config.Position,
        showWatermark = Config.ShowWatermark
    })
end

-- Modern export:
-- exports['esx_notify']:Notify('success', 5000, 'Üzenet', 'Cím')
exports('Notify', function(notifyType, duration, message, title)
    if type(notifyType) == 'table' then
        SendNotify(notifyType)
        return
    end

    -- Notify('Üzenet')
    if message == nil and duration == nil then
        SendNotify({ type = 'info', message = notifyType })
        return
    end

    -- Notify('Üzenet', 'success', 5000)
    if type(duration) == 'string' and type(message) == 'number' then
        SendNotify({ type = duration, duration = message, message = notifyType, title = title })
        return
    end

    SendNotify({ type = notifyType, duration = duration, message = message, title = title })
end)

exports('ShowNotification', function(message, notifyType, duration, title)
    SendNotify({ type = notifyType, duration = duration, message = message, title = title })
end)

exports('Notification', function(message, notifyType, duration, title)
    SendNotify({ type = notifyType, duration = duration, message = message, title = title })
end)

-- Helper exportok RealRPG integrációkhoz.
exports('Success', function(message, duration, title) SendNotify({ type = 'success', message = message, duration = duration, title = title }) end)
exports('Error', function(message, duration, title) SendNotify({ type = 'error', message = message, duration = duration, title = title }) end)
exports('Warning', function(message, duration, title) SendNotify({ type = 'warning', message = message, duration = duration, title = title }) end)
exports('Info', function(message, duration, title) SendNotify({ type = 'info', message = message, duration = duration, title = title }) end)
exports('Bank', function(message, duration, title) SendNotify({ type = 'bank', message = message, duration = duration, title = title }) end)
exports('Police', function(message, duration, title) SendNotify({ type = 'police', message = message, duration = duration, title = title }) end)
exports('EMS', function(message, duration, title) SendNotify({ type = 'ems', message = message, duration = duration, title = title }) end)
exports('Mechanic', function(message, duration, title) SendNotify({ type = 'mechanic', message = message, duration = duration, title = title }) end)
exports('VIP', function(message, duration, title) SendNotify({ type = 'vip', message = message, duration = duration, title = title }) end)
exports('Server', function(message, duration, title) SendNotify({ type = 'server', message = message, duration = duration, title = title }) end)
exports('Announce', function(message, duration, title) SendNotify({ type = 'announce', message = message, duration = duration or 8000, title = title }) end)

RegisterNetEvent('esx:showNotification', function(message, notifyType, duration, title)
    if type(message) == 'table' then
        SendNotify(message)
        return
    end

    SendNotify({ type = notifyType, duration = duration, message = message, title = title })
end)

RegisterNetEvent('esx_notify:Notify', function(notifyType, duration, message, title)
    if type(notifyType) == 'table' then
        SendNotify(notifyType)
        return
    end

    SendNotify({ type = notifyType, duration = duration, message = message, title = title })
end)

RegisterNetEvent('esx_notify:showNotification', function(message, notifyType, duration, title)
    SendNotify({ type = notifyType, duration = duration, message = message, title = title })
end)

RegisterNetEvent('realrpg_notify:notify', function(data)
    if type(data) == 'table' then SendNotify(data) end
end)

RegisterNetEvent('realrpg_notify:announce', function(message, duration, title)
    SendNotify({ type = 'announce', message = message, duration = duration or 8000, title = title })
end)

-- Teszt parancs, productionben kikapcsolhatod vagy törölheted.
RegisterCommand('rnotifytest', function()
    local tests = {
        { type = 'success', message = 'Személyi igazolvány sikeresen kiállítva.', duration = 4500 },
        { type = 'info', message = 'A jármű kulcsa hozzáadva az inventoryhoz.', duration = 5000 },
        { type = 'warning', message = 'Nincs nálad elegendő készpénz.', duration = 5000 },
        { type = 'error', message = 'A művelet jelenleg nem hajtható végre.', duration = 5000 },
        { type = 'bank', message = '+25 000 Ft érkezett a számládra.', duration = 5000 },
        { type = 'police', message = 'Új körözés került kiadásra.', duration = 5000 },
        { type = 'ems', message = 'Sürgősségi riasztás érkezett.', duration = 5000 },
        { type = 'mechanic', message = 'A jármű állapota javítva lett.', duration = 5000 },
        { type = 'vip', message = 'VIP jutalom jóváírva.', duration = 5500 },
        { type = 'server', message = 'RealRPG rendszerüzenet teszt.', duration = 5500 },
        { type = 'announce', message = 'Szerver restart 10 perc múlva.', duration = 8000 }
    }

    CreateThread(function()
        for _, data in ipairs(tests) do
            SendNotify(data)
            Wait(260)
        end
    end)
end, false)
