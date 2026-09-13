# mach1ne_kidnapping

Kidnapping-mission til FiveM (ESX). Find et offer, forhør dem med tre tortur-metoder, optag videoen og sælg den til bossen for kontanter.

## Funktioner

- **Tre tortur-scener**: Skruenøgle, vandtortur (waterboarding) og tandtræk
- **Videooptagelse**: Optag forhøret og sælg videoen til bossen
- **Cooldown**: Ventetid mellem missioner (konfigurerbar, gemmes i database)
- **Politi-alarm**: Politiet får en GPS-markering når torturen starter
- **ox_inventory**: Fuldt integrationeret med ox_inventory til items og penge
- **st_libs**: Notifikationer, 3D interaction og textUI
- **oxmysql**: Cooldown persistens (overlever server-restart)
- **Dansk UI**: Alle tekster er på dansk

## Krav

|---|---|
| [es_extended](https://github.com/esx-framework/esx_core) | Framework (ESX Legacy) |
| [ox_lib](https://github.com/overextended/ox_lib) | Callbacks |
| [oxmysql](https://github.com/overextended/oxmysql) | Database (cooldown persistens) |
| [ox_inventory](https://github.com/overextended/ox_inventory) | Inventar-system |
| [st_libs](https://github.com/Stausi/st_libs) | Notifikationer, 3D interaction, textUI |

## Opsætning

### 1. Items (ox_inventory)


```lua
['videorecord'] = {
    label = 'Videooptagelse',
    weight = 50,
    stack = true,
    close = true,
    description = 'En videooptagelse fra et forhør. Sælg den til Kidnapping-bossen for kontanter.',
},
```

### 2. Database

Tabellen `mach1ne_kidnapping_cooldown` oprettes **automatisk** ved resource-start. Ingen manuel SQL nødvendig.

