# RealRPG ESX Notify V2

Drop-in `esx_notify` csere RealRPG fekete-arany prémium témával.

## Fő funkciók

- Gyári ESX notify event kompatibilitás
- Fent középen megjelenő RealRPG stílus
- Egyedi típusok: success, info, warning, error, money, bank, police, ems, mechanic, vip, server, announce, illegal
- Minden típushoz külön megjelenési animáció
- Minden típushoz külön PNG ikon
- Minden típushoz külön hangjelzés
- Queue rendszer: alapból max 3 értesítés látszik, a többi várakozik
- Halvány RR vízjel és okmány/security pattern háttér

## Telepítés

1. A régi `esx_notify` resource-t nevezd át vagy töröld.
2. Ezt a mappát tedd be ide: `resources/[esx]/esx_notify`
3. `server.cfg`:

```cfg
ensure esx_notify
```

## Teszt

```txt
/rnotifytest
```

## Használat

```lua
TriggerEvent('esx:showNotification', 'Sikeres művelet', 'success', 5000)
TriggerEvent('esx_notify:Notify', 'warning', 5000, 'Nincs nálad elegendő készpénz')
exports['esx_notify']:Notify('bank', 5000, '+25 000 Ft érkezett a számládra')
exports['esx_notify']:Announce('Szerver restart 10 perc múlva', 8000)
```

## Helper exportok

```lua
exports['esx_notify']:Success('Sikeres vásárlás')
exports['esx_notify']:Error('A művelet nem hajtható végre')
exports['esx_notify']:Warning('Nincs nálad elegendő készpénz')
exports['esx_notify']:Info('Új információ')
exports['esx_notify']:Bank('+25 000 Ft érkezett')
exports['esx_notify']:Police('Új körözés kiadva')
exports['esx_notify']:EMS('Sürgősségi riasztás')
exports['esx_notify']:Mechanic('Jármű megjavítva')
exports['esx_notify']:VIP('VIP jutalom jóváírva')
exports['esx_notify']:Server('RealRPG rendszerüzenet')
```

## Config

```lua
Config.MaxVisible = 3
Config.Queue = true
Config.Sound = true
Config.SoundVolume = 0.34
Config.SoundPack = 'premium'
Config.ShowWatermark = true
```
