# mach1ne_kidnapping

## Krav

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

