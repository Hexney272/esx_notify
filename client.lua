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

    -- DEBUG: Log minden bejövő adatot
    print('[ESX_NOTIFY DEBUG] ===== BEJÖVŐ NOTIFY =====')
    print('[ESX_NOTIFY DEBUG] Original data.type:', data.type)
    print('[ESX_NOTIFY DEBUG] Original data.notifyType:', data.notifyType)
    print('[ESX_NOTIFY DEBUG] Original data.title:', data.title)
    print('[ESX_NOTIFY DEBUG] Original data.message:', data.message)

    local notifyType = normalizeType(data.type or data.notifyType or 'info')
    local duration = normalizeDuration(data.duration or data.length or data.time)
    local title = cleanText(data.title)
    local message = cleanText(data.message or data.text or data.msg)

    print('[ESX_NOTIFY DEBUG] Normalized type:', notifyType)
    print('[ESX_NOTIFY DEBUG] Cleaned title:', title)
    print('[ESX_NOTIFY DEBUG] Config.Titles[notifyType]:', Config.Titles[notifyType])

    if message == '' and title ~= '' then
        message = title
        title = ''
    end

    if message == '' then return end

    if title == '' then
        title = Config.Titles[notifyType] or Config.Titles['info'] or 'INFORMÁCIÓ'
        print('[ESX_NOTIFY DEBUG] Title was empty, set to:', title)
    else
        print('[ESX_NOTIFY DEBUG] Title already set:', title)
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
-- exports['esx_notify']:Notify({type='success', message='Üzenet'}) -- TABLE
-- exports['esx_notify']:Notify('Üzenet') -- csak üzenet
-- exports['esx_notify']:Notify('Üzenet', 'success') -- üzenet, típus
-- exports['esx_notify']:Notify('Üzenet', 'success', 5000) -- üzenet, típus, idő
exports('Notify', function(arg1, arg2, arg3, arg4)
    -- Ha TABLE, akkor az az adat
    if type(arg1) == 'table' then
        SendNotify(arg1)
        return
    end

    -- Ha csak egy string, akkor az az üzenet (info típussal)
    if arg2 == nil and arg3 == nil and arg4 == nil then
        SendNotify({ type = 'info', message = arg1 })
        return
    end

    -- Megpróbáljuk detektálni a hívási formátumot
    -- Ha arg2 string és ismert típus, akkor: Notify(message, type, duration, title)
    local knownTypes = {
        'success', 'error', 'warning', 'info', 'inform', 'money', 'bank', 
        'police', 'ems', 'mechanic', 'vip', 'premium', 'server', 'announce', 'illegal',
        'primary', 'notification', 'normal', 'warn', 'danger', 'cash', 'pay',
        'lspd', 'policejob', 'ambulance', 'doctor', 'emsjob', 'mech', 'mechanicjob', 'admin', 'system', 'announcement'
    }
    
    local isArg2Type = false
    if type(arg2) == 'string' then
        local arg2Lower = arg2:lower()
        for _, t in ipairs(knownTypes) do
            if t == arg2Lower then
                isArg2Type = true
                break
            end
        end
    end

    -- Ha arg2 típus, akkor: Notify(message, type, duration, title)
    if isArg2Type then
        SendNotify({ 
            type = arg2, 
            message = arg1, 
            duration = arg3, 
            title = arg4 
        })
        return
    end

    -- Egyébként régi formátum: Notify(type, duration, message, title)
    SendNotify({ 
        type = arg1, 
        duration = arg2, 
        message = arg3, 
        title = arg4 
    })
end)

-- ShowNotification általában így hívják: ShowNotification(message) vagy ShowNotification(message, type, duration)
exports('ShowNotification', function(arg1, arg2, arg3, arg4)
    if type(arg1) == 'table' then
        SendNotify(arg1)
        return
    end
    
    -- Leggyakoribb: ShowNotification(message) vagy ShowNotification(message, type, duration, title)
    SendNotify({ 
        type = arg2 or 'info', 
        message = arg1, 
        duration = arg3, 
        title = arg4 
    })
end)

exports('Notification', function(arg1, arg2, arg3, arg4)
    if type(arg1) == 'table' then
        SendNotify(arg1)
        return
    end
    
    SendNotify({ 
        type = arg2 or 'info', 
        message = arg1, 
        duration = arg3, 
        title = arg4 
    })
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

RegisterNetEvent('esx:showNotification', function(arg1, arg2, arg3, arg4)
    if type(arg1) == 'table' then
        SendNotify(arg1)
        return
    end

    -- Leggyakoribb: message, type, duration
    SendNotify({ 
        type = arg2 or 'info', 
        message = arg1, 
        duration = arg3, 
        title = arg4 
    })
end)

RegisterNetEvent('esx_notify:Notify', function(arg1, arg2, arg3, arg4)
    if type(arg1) == 'table' then
        SendNotify(arg1)
        return
    end

    -- Detektáljuk a formátumot
    local knownTypes = {
        'success', 'error', 'warning', 'info', 'inform', 'money', 'bank', 
        'police', 'ems', 'mechanic', 'vip', 'premium', 'server', 'announce', 'illegal'
    }
    
    local isArg2Type = false
    if type(arg2) == 'string' then
        local arg2Lower = arg2:lower()
        for _, t in ipairs(knownTypes) do
            if t == arg2Lower then
                isArg2Type = true
                break
            end
        end
    end

    if isArg2Type then
        -- message, type, duration, title
        SendNotify({ 
            type = arg2, 
            message = arg1, 
            duration = arg3, 
            title = arg4 
        })
    else
        -- type, duration, message, title
        SendNotify({ 
            type = arg1, 
            duration = arg2, 
            message = arg3, 
            title = arg4 
        })
    end
end)

RegisterNetEvent('esx_notify:showNotification', function(arg1, arg2, arg3, arg4)
    if type(arg1) == 'table' then
        SendNotify(arg1)
        return
    end
    
    SendNotify({ 
        type = arg2 or 'info', 
        message = arg1, 
        duration = arg3, 
        title = arg4 
    })
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
