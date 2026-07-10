Config = {}

-- Alap megjelenési idő ms-ben, ha egy script nem ad meg időt.
Config.DefaultDuration = 4500

-- Fent középen jelenjen meg.
Config.Position = 'top-center'

-- Maximum egyszerre látható értesítés.
Config.MaxVisible = 3

-- Ha egyszerre sok notify érkezik, a többi várakozik, nem takarja tele a képernyőt.
Config.Queue = true

-- Értesítési hangok.
Config.Sound = true
Config.SoundVolume = 0.34

-- soft / premium / minimal
Config.SoundPack = 'premium'

-- Halvány RR vízjel jobb oldalon.
Config.ShowWatermark = true

-- Címek típusonként.
Config.Titles = {
    success = 'SIKERES',
    error = 'HIBA',
    warning = 'FIGYELMEZTETÉS',
    info = 'INFORMÁCIÓ',
    inform = 'INFORMÁCIÓ',
    money = 'PÉNZÜGY',
    bank = 'BANK',
    police = 'RENDŐRSÉG',
    ems = 'MENTŐSZOLGÁLAT',
    mechanic = 'SZERELŐ',
    vip = 'VIP',
    premium = 'PRÉMIUM',
    server = 'REALRPG',
    announce = 'KÖZLEMÉNY',
    illegal = 'FIGYELEM'
}

-- Típus aliasok, hogy minél több scripthez kompatibilis legyen.
Config.TypeAliases = {
    ['primary'] = 'info',
    ['inform'] = 'info',
    ['notification'] = 'info',
    ['normal'] = 'info',
    ['warn'] = 'warning',
    ['danger'] = 'error',
    ['cash'] = 'money',
    ['pay'] = 'money',
    ['lspd'] = 'police',
    ['policejob'] = 'police',
    ['ambulance'] = 'ems',
    ['doctor'] = 'ems',
    ['emsjob'] = 'ems',
    ['mech'] = 'mechanic',
    ['mechanicjob'] = 'mechanic',
    ['premium'] = 'vip',
    ['admin'] = 'server',
    ['system'] = 'server',
    ['announcement'] = 'announce'
}
