# AngusUI

World of Warcraft Interface Modification addon focused on weekly tracking and
quality-of-life UI improvements.

## Overview

- **Author:** Angusdonals-Frostwhisper
- **Version:** 12.0.0
- **Interface:** 120007 (WoW 12.0.7)

AngusUI combines UI layout automation with endgame tracking for Mythic+,
weekly chores, and crests.

## Features

- Automatic UI layout switching based on resolution and aspect ratio
- Mythic+ reward tables overlay in the Challenges UI
- Weekly crest quest and item level achievement tracking
- Cloak teleportation swap-and-return convenience
- Automatic screenshots on tracked events
- World quest reward icons on the map and in the objective tracker

## Commands

All commands use the `/aui` or `/angusui` prefix:

```
/aui back      - Equip and use teleportation cloak
/aui crests    - Show weekly crest and achievement progress
/aui toast     - Show weekly chores status
/aui ui        - Manually trigger UI layout adjustment
/aui           - Show list of all available commands
```

## Module Map

```
AngusUI.lua      - Addon entry point, events, slash commands, UI tweaks
Screenshots.lua  - Automatic screenshots for tracked events such as level ups, achievements, mounts, and pets
UI.lua           - Edit Mode layout switching based on screen resolution
MythicPlus.lua   - Mythic+ reward table overlay
Crests.lua       - Crest quests and item level achievement tracking
TeleportBack.lua - Cloak teleportation swap-and-return helper
WorldQuestIcons.lua - World quest reward icons and gear-upgrade indicators
Inconsolata.ttf  - Custom font for reward tables
```

## Development Notes

- **Language:** Lua (WoW API)
- **No build step:** edit files directly and `/reload` in-game
- **Layout names:** pre-configure Edit Mode layouts named `angusui`,
  `angusui wide`, and `angusui 4k`
- **Git setup:** run `git config --local core.fileMode false` in each clone to
  ignore cross-platform executable-bit noise
- **Seasonal updates:** reward tables, quest IDs, and item IDs are hard-coded
  and should be reviewed each patch/season

## Data Updates

Hard-coded data that typically changes per season:

- Crest quest IDs and achievement item levels
- Mythic+ reward tables and crest rewards
- Teleportation cloak item IDs

## Resources

- FrameXML docs: https://www.townlong-yak.com/framexml/live
- Blizzard API docs (Townlong Yak):
  https://www.townlong-yak.com/framexml/live/Blizzard_APIDocumentation
