# AngusUI Project Documentation

## Overview

AngusUI is a World of Warcraft Interface Modification addon that enhances the user experience through various quality-of-life features and UI customizations. The addon provides tracking for weekly content, interface customization, and convenience features for end-game progression in World of Warcraft.

**Author:** Angusdonals-Frostwhisper  
**Version:** 11.1.0  
**Interface Compatibility:** 110100, 110105 (World of Warcraft 11.1.x)

## Project Purpose

This addon serves two main purposes:
1. **UI Customization** - Automatically adjusts UI layouts based on screen resolution and provides visual improvements to default UI elements
2. **Content Tracking** - Provides easy-to-access information about weekly progression systems including Mythic+, Delves, Reputation quests, and Crests

## Architecture

### File Structure

```
AngusUI/
├── AngusUI.lua          # Main addon entry point, event handling, and slash commands
├── AngusUI.toc          # Addon metadata and load order
├── Crests.lua           # Crest weekly quest and achievement tracking
├── Delves.lua           # Delve speedrun timer functionality
├── MythicPlus.lua       # Mythic+ reward table display
├── Reputations.lua      # Reputation quest tracking
├── TeleportBack.lua     # Cloak teleportation convenience feature
├── UI.lua               # UI layout auto-switcher based on screen resolution
├── Inconsolata.ttf      # Custom font for UI elements
├── README.md            # Basic project description
└── .gitignore          # Git ignore file
```

### Module Descriptions

#### AngusUI.lua (Core Module)
**Purpose:** Main addon initialization and event handling

**Key Features:**
- Event registration and handling (ADDON_LOADED, PLAYER_ENTERING_WORLD, PLAYER_SPECIALIZATION_CHANGED, MYTHIC_PLUS_CURRENT_AFFIX_UPDATE)
- Slash command system (`/angusui` or `/aui`)
- UI element color customization (darker action bars, frames)
- Friends frame expansion
- Global utility functions (`Set`, `SlashCommand`)

**Events:**
- `ADDON_LOADED` - Applies UI customizations when Blizzard_TimeManager loads
- `PLAYER_ENTERING_WORLD` - Triggers UI layout check
- `PLAYER_SPECIALIZATION_CHANGED` - Triggers UI layout check
- `MYTHIC_PLUS_CURRENT_AFFIX_UPDATE` - Initializes Mythic+ reward display

**Slash Commands:**
- `/aui back` - Teleport back functionality
- `/aui rep` - Show reputation quests
- `/aui crests` - Show crest weekly progress
- `/aui ui` - Manually trigger UI layout check
- `/aui delves` - Open delve speedrun timer

#### UI.lua
**Purpose:** Automatic UI layout switching based on screen resolution

**Logic:**
- Detects current screen resolution using `GetPhysicalScreenSize()`
- Switches between different AngusUI layouts:
  - "angusui 4k" - For 3840x2160 or 2560x1440 resolutions
  - "angusui wide" - For ultrawide monitors (aspect ratio > 2:1)
  - "angusui" - Default layout
- Only operates on layouts named with "angusui" prefix
- Uses `C_EditMode` API for layout management

**Technical Note:** Layouts must be pre-configured in-game with specific names.

#### Crests.lua
**Purpose:** Track weekly crest quest completion and item level achievement progress

**Features:**
- Displays completion status of weekly crest quests across multiple zones:
  - Nerub-ar Palace (raid)
  - Hallowfall
  - Isle of Dorn
  - The Ringing Deeps
  - Azj-Kahet
  - Undermine
  - Liberation of Undermine
- Tracks item level achievements (631, 644, 657, 674)
- Shows which gear slots need upgrading using high watermark system
- Color-coded output (green for completed, red for incomplete)

**Technical Details:**
- Uses `C_QuestLog.IsQuestFlaggedCompleted()` API
- Uses `C_ItemUpgrade.GetHighWatermarkForSlot()` for gear tracking
- Tracks achievements: 40942, 40943, 40944, 40945

#### MythicPlus.lua
**Purpose:** Display Mythic+ reward tables in the Challenges UI

**Features:**
- Creates a custom frame overlay on the Challenges Frame
- Displays three reward tables:
  1. End of Dungeon item levels (2-12)
  2. Great Vault item levels (2-12)
  3. Crest rewards (2-12)
- Color-coded by quality:
  - Blue (Champion): 639-655
  - Purple (Hero): 649-658
  - Orange (Mythic): 662
- Uses custom Inconsolata font for consistent display

**Technical Note:** Only initializes when ChallengesFrame is loaded.

#### Reputations.lua
**Purpose:** Track incomplete reputation quests

**Features:**
- Tracks specific reputation quest IDs (faction 2902)
- Displays only incomplete quests
- Shows quest titles or IDs if title unavailable
- Currently tracks 24 quests for one reputation faction

**Use Case:** Helps players quickly see which daily/weekly reputation activities remain.

#### Delves.lua
**Purpose:** Delve speedrun timer

**Features:**
- Draggable UI frame with Start/Stop buttons
- Tracks time spent in delve
- Prints elapsed time when stopped
- Prevents multiple timer instances
- Event listener for Brann Bronzebeard dialogue (commented out functionality)

**Technical Details:**
- Uses `time()` function for timing
- Creates movable frame with `BasicFrameTemplateWithInset`
- Registers for `CHAT_MSG_MONSTER_SAY` event (future feature)

#### TeleportBack.lua
**Purpose:** Automate cloak teleportation item usage

**Features:**
- Automatically equips teleportation cloaks from inventory
- Swaps back to original cloak after cooldown
- Tracks multiple teleportation cloak item IDs
- Checks item cooldowns before equipping

**Supported Cloak IDs:**
- 65274, 63207, 63353, 65360, 63206, 63352

**Technical Details:**
- Uses `ItemLocation` API for slot tracking
- Stores original cloak GUID for re-equipping
- Checks cooldowns with `C_Item.GetItemCooldown()`

## Development Workflow

### Language & Environment
- **Language:** Lua (World of Warcraft API)
- **Testing:** Must be tested in-game in World of Warcraft
- **No Build Process:** Direct file editing, reload with `/reload` in-game

### Adding New Features

1. **Create New Module:** Add a new `.lua` file for the feature
2. **Update TOC:** Add the file to `AngusUI.toc` in appropriate load order
3. **Register Function:** Add function to `AngusUI` namespace
4. **Add Command:** Update `SlashCommand` function in `AngusUI.lua` if needed
5. **Test In-Game:** Load addon in WoW and test with `/reload`

### Code Conventions

- **Namespace:** All functions use the `AngusUI` table: `function AngusUI:FunctionName()`
- **Local Variables:** Use `local _, AngusUI = ...` pattern for addon namespace
- **Event Handling:** Register events on frame objects, handle in OnEvent scripts
- **Color Codes:** Use WoW color pipe codes (e.g., `\124cffFF0000` for red)
- **API Usage:** Prefer C_* API functions over deprecated global functions

### Common WoW APIs Used

- **Quest System:** `C_QuestLog.IsQuestFlaggedCompleted()`, `C_QuestLog.GetTitleForQuestID()`
- **Item System:** `C_Item.GetItemCount()`, `C_Item.EquipItemByName()`, `C_Container.GetItemCooldown()`
- **UI System:** `CreateFrame()`, `C_EditMode.GetLayouts()`, `C_EditMode.SetActiveLayout()`
- **Achievement System:** `GetAchievementInfo()`
- **Item Upgrade:** `C_ItemUpgrade.GetHighWatermarkForSlot()`

## User Commands

All commands use the `/aui` or `/angusui` prefix:

```
/aui back      - Equip and use teleportation cloak
/aui rep       - Show incomplete reputation quests
/aui crests    - Show weekly crest quest and achievement progress
/aui ui        - Manually trigger UI layout adjustment
/aui delves    - Open delve speedrun timer interface
/aui           - Show list of all available commands
```

## Data Sources

### Hard-Coded Data
The addon contains several hard-coded data tables that may need periodic updates:

1. **Crest Quests** (Crests.lua)
   - Quest IDs for weekly crest activities
   - Zone names
   - **Update When:** New zones or seasons added

2. **Achievement IDs** (Crests.lua)
   - Item level achievements: 40942, 40943, 40944, 40945
   - Associated item levels: 631, 644, 657, 674
   - **Update When:** New item level tiers added

3. **Mythic+ Rewards** (MythicPlus.lua)
   - End of dungeon loot table
   - Great Vault loot table
   - Crest reward amounts
   - **Update When:** New season with different reward structure

4. **Reputation Quests** (Reputations.lua)
   - Faction ID: 2902
   - List of 24 quest IDs
   - **Update When:** New reputation or quest changes

5. **Teleportation Cloaks** (TeleportBack.lua)
   - Item IDs: 65274, 63207, 63353, 65360, 63206, 63352
   - **Update When:** New teleportation items added

## Technical Details for GitHub Agents

### Addon Loading Sequence
1. TOC file parsed by WoW client
2. Lua files loaded in order specified in TOC
3. `ADDON_LOADED` event fires
4. `PLAYER_ENTERING_WORLD` event fires on login/reload
5. Addon-specific events registered and handled

### State Management
- **Global State:** Stored in `AngusUI` table (addon namespace)
- **Persistent State:** None (no SavedVariables used)
- **Session State:** Some modules track runtime state (e.g., `delveIsActive` in Delves.lua)

### UI Modifications
The addon modifies several default UI elements:
- MainMenuBar colors (darker theme)
- Minimap compass colors
- Player and Target frame colors
- Action button colors
- Friends frame size (widened by 50px, heightened by 300px)

### Dependencies
- **Required:** None (uses only standard WoW API)
- **Optional:** Loads after Blizzard_TimeManager for UI modifications
- **Assets:** Inconsolata.ttf font file

### Testing Considerations
- **Resolution Testing:** UI.lua requires testing on multiple monitor configurations
- **Quest Testing:** Crest and reputation tracking requires access to specific quests
- **Event Testing:** Some features only trigger on specific game events
- **In-Game Only:** Cannot unit test without WoW client running

### Known Limitations
1. **UI Layouts:** Requires pre-configured layouts in-game with specific naming
2. **Hard-Coded Data:** Many quest/item IDs require manual updates each season
3. **No Saved Variables:** Settings don't persist between sessions
4. **English Only:** No localization support
5. **No Error Handling:** Limited error checking in most functions

## Future Enhancement Opportunities

1. **SavedVariables:** Implement persistent storage for user preferences
2. **Localization:** Add multi-language support
3. **Dynamic Data:** Fetch quest/item IDs from game data instead of hard-coding
4. **Settings UI:** Create configuration panel for user customization
5. **Error Handling:** Add validation and error messages
6. **Delve Integration:** Complete Brann Bronzebeard event handler
7. **Profile Support:** Allow different settings per character
8. **Update Notifications:** Alert when hard-coded data may be outdated

## Maintenance Guide

### Seasonal Updates Required
Each WoW season/patch may require updates to:
- Interface version in TOC file
- Crest quest IDs and zone names
- Achievement IDs and item levels
- Mythic+ reward tables
- Reputation faction and quest IDs

### Version Numbering
Follow WoW patch versioning: `MAJOR.MINOR.PATCH`
- Example: 11.1.0 for WoW patch 11.1.0

### Testing Checklist
- [ ] Load addon without errors
- [ ] All slash commands functional
- [ ] UI modifications apply correctly
- [ ] Quest tracking shows accurate data
- [ ] Mythic+ table displays on Challenges Frame
- [ ] Teleportation cloak swap works
- [ ] Delve timer starts/stops correctly
- [ ] UI layout switches on resolution change

## Contributing Guidelines

When making changes to this addon:
1. **Test in-game** - All changes must be verified in World of Warcraft
2. **Maintain style** - Follow existing code conventions
3. **Update TOC** - Increment version for each release
4. **Document changes** - Update this file for significant features
5. **Minimal scope** - Keep changes focused and small
6. **No dependencies** - Avoid requiring other addons unless necessary

## Resources

### WoW API Documentation
- [WoWpedia - World of Warcraft API](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
- [Townlong Yak - WoW API Documentation](https://www.townlong-yak.com/framexml/live)

### Community Resources
- [WoW Interface](https://www.wowinterface.com/) - Addon hosting and forums
- [CurseForge](https://www.curseforge.com/wow/addons) - Addon distribution platform

## License

No explicit license specified in repository.
