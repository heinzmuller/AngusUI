# AngusUI

World of Warcraft Interface Modification addon focused on weekly tracking and
quality-of-life UI improvements.

## Overview

- **Author:** Angusdonals-Frostwhisper
- **Version:** 12.0.0
- **Interface:** 110207, 120000, 120001 (WoW 11.2.x, 12.0.x)

AngusUI combines UI layout automation with endgame tracking for Mythic+, Delves,
reputations, and crests.

## Features

- Automatic UI layout switching based on resolution and aspect ratio
- Mythic+ reward tables overlay in the Challenges UI
- Weekly crest quest and item level achievement tracking
- Reputation quest status for a specific faction
- Delve speedrun timer window
- Cloak teleportation swap-and-return convenience

## Commands

All commands use the `/aui` or `/angusui` prefix:

```
/aui back      - Equip and use teleportation cloak
/aui rep       - Show incomplete reputation quests
/aui crests    - Show weekly crest and achievement progress
/aui ui        - Manually trigger UI layout adjustment
/aui delves    - Open delve speedrun timer interface
/aui           - Show list of all available commands
```

## Module Map

```
AngusUI.lua      - Addon entry point, events, slash commands, UI tweaks
UI.lua           - Edit Mode layout switching based on screen resolution
MythicPlus.lua   - Mythic+ reward table overlay
Crests.lua       - Crest quests and item level achievement tracking
Reputations.lua  - Reputation quest tracking
Delves.lua       - Delve speedrun timer window
TeleportBack.lua - Cloak teleportation swap-and-return helper
Inconsolata.ttf  - Custom font for reward tables
```

## Development Notes

- **Language:** Lua (WoW API)
- **No build step:** edit files directly and `/reload` in-game
- **Layout names:** pre-configure Edit Mode layouts named `angusui`,
  `angusui wide`, and `angusui 4k`
- **Seasonal updates:** reward tables, quest IDs, and item IDs are hard-coded
  and should be reviewed each patch/season

## Data Updates

Hard-coded data that typically changes per season:

- Crest quest IDs and achievement item levels
- Mythic+ reward tables and crest rewards
- Reputation quest IDs for the tracked faction
- Teleportation cloak item IDs

## Resources

- FrameXML docs: https://www.townlong-yak.com/framexml/live
- Blizzard API docs (Townlong Yak):
  https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentation
