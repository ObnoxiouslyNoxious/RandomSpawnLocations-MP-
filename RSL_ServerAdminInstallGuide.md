# Random Spawn Locations — Server Admin Install Guide
**[B42] Random Spawn Locations [SP/MP] | Build 42.00+**

---

## Overview

This is a **Server Side Mod**. It replaces all Vanilla spawn choices with a single **Random Spawn, KY** option. Players are placed at a random location drawn from a curated pool of thousands of verified spawn points across Knox Country.

Clients must also subscribe to the mod — it includes a small UI hook that collapses the spawn screen to a single clean entry. The spawn coordinate pool is never sent to clients.

---

## Requirements

- Project Zomboid **Build 42.0.0** or later - Clients require matching version to Server (Builds prior to B42.15 will have broken Translations in Sandbox Settings)
- All players (server and clients) subscribed to the mod on Steam Workshop

---

## Step 1 — Subscribe to the Mod

Subscribe to **[B42] Random Spawn Locations [MP]** on the Steam Workshop.

If you are using any supported modded maps, also subscribe to those:
- Maplewood [B42] - Workshop ID: 3644794945
- Raven Creek (B42) - Workshop ID: 3484263516
- AnruisiTown (Military Bastion) - Workshop ID: 3659676359

All players connecting to the server must also be subscribed to the applicable Map Mod that the Server is subscribed to.

---

## Step 2 — Edit Your Server .ini

Open your server `.ini` file located at:

**Windows:**
```
C:\Users\[YourName]\Zomboid\Server\[ServerName].ini
```

**Linux:**
```
/home/[user]/Zomboid/Server/[ServerName].ini
```

### Mods= line
Add `RandomSpawnLocations` to your Mods line:
```ini
Mods=RandomSpawnLocations
```

If using modded maps, add those too. Ensure 'RandomSpawnLocations' is first in the list.
```ini
Mods=RandomSpawnLocations;RavenCreekB42;AnruisiTown;Maplewood
```

### Map= line
Add `Random Spawn, KY` as the **first** entry. Modded maps go **before** Muldraugh, KY. Muldraugh, KY must be **last**:
```ini
Map=Random Spawn, KY;Muldraugh, KY
```

With modded maps:
```ini
Map=Random Spawn, KY;RavenCreekB42;AnruisiTown;Maplewood;Muldraugh, KY
```

### SpawnPoint= line
```ini
SpawnPoint=0,0,0
```

> **Note:** The server settings UI may overwrite your .ini when you save changes. To avoid typing these changes multiple times, copy your .ini file to a secondary location on your PC.

---

## Step 3 — Place the Spawnregions File

A file named `[ServerName]_spawnregions.lua` must exist in your `Zomboid/Server/` folder. This file tells the server which spawn regions are available.

Create or edit `[ServerName]_spawnregions.lua` with the following contents:

```lua
function SpawnRegions()
    return {
        { name = "Random Spawn, KY", file = "media/maps/Random Spawn, KY/spawnpoints.lua" },
        { name = "Muldraugh, KY",    file = "media/maps/Muldraugh, KY/spawnpoints.lua" },
    }
end
```

Replace `[ServerName]` with your actual server name — it must match your `.ini` filename exactly.

> **Important:** Both entries are required. Muldraugh, KY must be present or the spawn selection screen will be skipped entirely.

---

## Step 4 — Configure Sandbox Options

Start your server and open the **Custom Sandbox** settings. The mod adds three new tabs:

### Random Spawn - Presets
**Balanced** - Restricts the spawn pool to a hand picked set of spawn points with equal amounts of spawn locations in each Town (Brandenburg, Echo Creek, Ekron, Fallas Lake, Irvington, Louisville, March Ridge, Muldraugh, Riverside, Rosewood, Valley Station & West Point). This ensures players spawn evenly spread across the Map. Recommended for most Multiplayer servers. Disabling any of the above mentioned Towns in 'Random Spawn - Locations' will remove them from the Balanced Pool. Enabling Towns not listed above will have no effect while Balanced is selected. Enabling any of the 'Random Spawn - Types' will have no effect if Balanced is selected. Unselect Balanced to fully customize your experience, but be aware that some locations and types have much more spawn options than others. Balanced Preset is enabled by default.

### Random Spawn - Locations
Toggle individual vanilla towns on or off. Towns included in the 'Balanced' pool are enabled by default.

### Random Spawn - Types
| Option | Default | Description |
|---|---|---|
| Residential | OFF | Houses, apartments, farmhouses |
| Non-Residential | OFF | Businesses, offices, warehouses |
| Hardcore Spawns | OFF | Dangerous or challenging locations |
| Isolated Areas | OFF | Remote and isolated locations such as cabins, camps and rural hideaways |

> **Recommended settings for most servers:** Default Settings

### Random Spawn - Map Mods
Enable spawn points in supported modded map regions. All are **disabled by default** — only enable maps that are active in your server's Map= line and are listed as supported by this Mod.
---

## Step 5 — Start the Server

Start your server. Players will see only **Random Spawn, KY** on the character creation screen.

---

## Adding Modded Maps Mid-Save

> **Warning:** Adding a new map mod to an existing save may require a **full save wipe**. If players have already explored areas near the new map region, the world may not load correctly. A save wipe is strongly recommended to avoid issues. Back up your save first.

Full Save Wipe Files:
- C:\Users\[YourName]\Zomboid\Saves\Multiplayer\[ServerName]\
- C:\Users\[YourName]\Zomboid\Server\[ServerName]_player.db

---

## Troubleshooting

**Spawn screen is skipped entirely**
— Check that `[ServerName]_spawnregions.lua` has both entries (Random Spawn, KY and Muldraugh, KY).

**Both "Random Spawn, KY" and "Muldraugh, KY" appear on the spawn screen**
— The client UI hook is not loading. Ensure all players are subscribed to the mod and that `RandomSpawnLocations` is in the `Mods=` line.

**Map doesn't load in Spawn Select / No Spawn description or video**
— The `map.info` file is not being read. Ensure `Random Spawn, KY` is the first entry in your `Map=` line and that the mod is loading correctly.

**Players spawn outside of buildings / in the ground**
— Check the server console for "spawn not in building" errors. Note the IDs and report them on the Workshop page.

**Sandbox options not updating mid-session**
— Sandbox filter changes made via the Admin menu require returning to the main menu to take effect. This is a known non-issue for live servers where settings are configured before startup. Changing sandbox settings mid-session via the Admin menu is generally not recommended on live servers.

---

## Uninstalling

1. Remove `RandomSpawnLocations` from `Mods=` in your `.ini`
2. Remove `Random Spawn, KY` from `Map=` in your `.ini`
3. Delete `[ServerName]_spawnregions.lua` from `Zomboid/Server/` or restore the vanilla version
4. The save itself is unaffected — existing characters keep their current positions


## Notes

- Consider allowing the Player to spawn with a Flashlight in Inventory, especially if using Non-Residential, Hardcore or Isolated Areas spawn types.

- You can view all Spawn Locations on a Map here: [RSL Spawn Map](https://obnoxiouslynoxious.github.io/RSLMapProject/)

- An index of all Spawn Locations is found here: [RSL Spawn Index](https://docs.google.com/spreadsheets/d/1ZaW1JDPTXN_U8sBjgZKKLwKkwf4NZwS23TsA0I3B_64/edit?gid=0#gid=0)