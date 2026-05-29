# AutoHarvest for Subnautica 2

AutoHarvest is a UE4SS Lua mod for Subnautica 2 that automatically collects nearby resources and breaks nearby resource nodes.

It is intended to reduce repetitive harvesting while keeping behaviour conservative and configurable.

## Features

- Automatically picks up nearby loose resources.
- Automatically picks up selected loose items such as salt, med kits, salvage, food, and similar items.
- Automatically breaks nearby resource nodes.
- Optional fauna pickup.
- Optional tool pickup.
- Lightweight scanning designed to avoid noticeable stutter.

## Requirements

- Subnautica 2
- UE4SS with Lua support enabled

## Installation

Extract the mod to your UE4SS mods folder:

```text
<Game>/Binaries/Win64/ue4ss/Mods/AutoHarvest/
```

The final structure should look like:

```text
AutoHarvest/
  Scripts/
    main.lua
    config.lua
    logger.lua
    ue.lua
    statics.lua
    player.lua
    spatial.lua
    candidate_lists.lua
    ownership.lua
    pickup.lua
    fauna.lua
    tools.lua
    breakables.lua
    harvest.lua
```

Restart the game or reload UE4SS Lua mods.

## Basic configuration

Edit:

```text
AutoHarvest/Scripts/config.lua
```

Main settings:

```lua
Config.TickIntervalMilliseconds = 3000
Config.Radius = 1000.0

Config.Log = true
Config.Debug = false
```

`TickIntervalMilliseconds` controls how often the mod checks nearby actors.

`Radius` controls the scan range. Unreal uses centimetres, so `1000.0` is roughly 10 metres.

`Log` prints successful pickup/break events.

`Debug` prints extra diagnostic information. Leave it off for normal play.

## Pickup

Normal item/resource pickup is enabled by default:

```lua
Config.Pickup = {
    Enabled = true,
    MaxPerSweep = 1,
}
```

`MaxPerSweep` limits how many items can be picked up per scan.

The default pickup list includes known loose resources and common loose pickup items.

## Breaking resource nodes

Resource-node breaking is enabled by default:

```lua
Config.Break = {
    Enabled = true,
    MaxPerSweep = 1,
}
```

This currently supports resource nodes such as quartz and copper nodes.

Resource deposits are intentionally not enabled yet.

## Fauna pickup

Fauna pickup is disabled by default:

```lua
Config.Fauna = {
    Enabled = false,
}
```

Enable it if you want AutoHarvest to collect known small fauna:

```lua
Config.Fauna.Enabled = true
```

The fauna list is intentionally explicit. It does not use broad matching like `"Fish"` because that can catch larger or unintended fauna.

## Tool pickup

Tool pickup is disabled by default:

```lua
Config.Pickup.Tools = {
    Enabled = false,
}
```

Enable it if you want AutoHarvest to try collecting supported tool actors, such as flares:

```lua
Config.Pickup.Tools.Enabled = true
```

## Adding new pickups

To add a new item, add part of its actor class name to the relevant list in `config.lua`.

For normal loose items/resources:

```lua
Config.Pickup.ActorNames = {
    "BP_MedKit",
    "BP_Salt",
    "BP_MetalSalvage",
}
```

For fauna:

```lua
Config.Fauna.ActorNames = {
    "BP_WaterSlug",
    "BP_Halfmoon",
}
```

For tools:

```lua
Config.Pickup.Tools.ActorNames = {
    "BP_Flares",
}
```

Prefer exact class fragments over broad names.

Good:

```lua
"BP_Halfmoon"
"BP_WaterSlug"
```

Avoid:

```lua
"Fish"
"AI"
"Resource"
```

## Finding actor names

If you need to identify an unknown item or creature, use a discovery/debug mod or search the generated UE4SS headers.

Useful searches:

```bash
grep -Ri "BasePickupItem" .
grep -Ri "WorldPopSpawned" .
grep -Ri "ResourceNode" .
grep -Ri "SN2AISmallFish" .
```

If the visible in-game name does not appear in headers, it may be a display name rather than the actor class name.

## Performance tips

For normal play:

```lua
Config.Debug = false
Config.X.MaxPerSweep = 1
Config.Radius = 1000.0
```

If you notice stutter:

- Increase `Config.TickIntervalMilliseconds`.
- Lower `Config.Radius`.
- Keep `Debug` disabled.
- Avoid broad actor-name fragments.

## Known limitations

- Resource deposits are not supported.
- Fauna support depends on known actor class names.
- Some Early Access updates may rename or change actor classes.
- Tool pickup is experimental and disabled by default.
- The mod is conservative by design; it will not collect actors unless they are explicitly listed.

## Compatibility

Subnautica 2 is in Early Access, so updates may break actor names or behaviour.
