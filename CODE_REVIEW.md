# AngusUI Code Review Report

**Date:** 2025-11-10  
**Reviewer:** GitHub Copilot Code Review Agent  
**Repository:** heinzmuller/AngusUI  
**Version:** 11.1.0

---

## Executive Summary

This code review analyzed the AngusUI World of Warcraft addon codebase. The addon is functional and provides valuable quality-of-life features for WoW players. However, several issues were identified ranging from critical bugs that could cause runtime errors to code quality improvements that would enhance maintainability.

**Overall Assessment:** ⚠️ **Requires Attention**
- **Critical Issues:** 2
- **High Priority Issues:** 2
- **Medium Priority Issues:** 3
- **Low Priority Issues:** 3

---

## Critical Issues

### 1. UI.lua - Premature Loop Exit (Line 34)
**Severity:** 🔴 **CRITICAL**

```lua
for i, layout in ipairs(layouts.layouts) do
    local layoutName = layout.layoutName:lower()
    local isAngusUI = layoutName:find("angusui") ~= nil

    if not isAngusUI then
        return  -- ❌ EXITS ENTIRE FUNCTION
    end
    
    if (layoutName == layoutToUse) then
        C_EditMode.SetActiveLayout(i + 2)
        return
    end
end
```

**Problem:**
- The `return` statement on line 34 exits the entire function when a non-AngusUI layout is encountered
- This prevents checking remaining layouts in the list
- If any layout before the target layout is not AngusUI-named, the function will fail

**Impact:**
- Layout switching will fail unpredictably depending on layout order
- Users won't get automatic UI adjustments based on resolution

**Recommended Fix:**
```lua
for i, layout in ipairs(layouts.layouts) do
    local layoutName = layout.layoutName:lower()
    local isAngusUI = layoutName:find("angusui") ~= nil

    if not isAngusUI then
        goto continue  -- Skip to next iteration
    end
    
    if (layoutName == layoutToUse) then
        C_EditMode.SetActiveLayout(i + 2)
        return
    end
    
    ::continue::
end
```

Or better yet, restructure to:
```lua
for i, layout in ipairs(layouts.layouts) do
    local layoutName = layout.layoutName:lower()
    
    if layoutName:find("angusui") and layoutName == layoutToUse then
        C_EditMode.SetActiveLayout(i + 2)
        return
    end
end
```

---

### 2. TeleportBack.lua - Undefined Global Function (Line 12)
**Severity:** 🔴 **CRITICAL**

```lua
local backs = Set(backIds)  -- ❌ Set() is not defined in this file's scope
```

**Problem:**
- `Set()` function is defined in AngusUI.lua (line 11) as a global function
- However, due to WoW addon loading order, there's no guarantee `Set()` will be available when TeleportBack.lua loads
- Even if available, relying on global functions from other files is fragile

**Impact:**
- Will cause a runtime error: "attempt to call global 'Set' (a nil value)"
- The `/aui back` command will fail completely

**Recommended Fix:**
Option 1 - Add to AngusUI namespace:
```lua
-- In AngusUI.lua
function AngusUI:Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

-- In TeleportBack.lua
local backs = AngusUI:Set(backIds)
```

Option 2 - Define locally in TeleportBack.lua:
```lua
local function Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end
local backs = Set(backIds)
```

---

## High Priority Issues

### 3. Delves.lua - Inconsistent State Management (Line 25)
**Severity:** 🟠 **HIGH**

```lua
function AngusUI:StartDelveSpeedrun()
    if (delveIsActive ~= nil) then  -- Checks for nil
        return
    end
    -- ...
end

function AngusUI:StopDelveSpeedrun()
    if (delveIsActive == nil) then
        return
    end
    -- ...
    delveIsActive = false  -- ❌ Sets to false, not nil
end
```

**Problem:**
- `StartDelveSpeedrun()` checks if `delveIsActive ~= nil`
- `StopDelveSpeedrun()` sets `delveIsActive = false`
- This means after stopping once, you can never start again because `false ~= nil` is true

**Impact:**
- Users can only use the delve timer once per session
- Must reload UI to use timer again

**Recommended Fix:**
```lua
function AngusUI:StopDelveSpeedrun()
    if (delveIsActive == nil) then
        return
    end

    print("Stopping the delve speedrun =]")
    local elapsed = time() - delveIsActive
    print("You completed the delve speedrun in " .. elapsed .. " seconds")
    delveIsActive = nil  -- ✅ Reset to nil for consistency
end
```

---

### 4. Crests.lua - Overly Complex Logic (Lines 36-47)
**Severity:** 🟠 **HIGH**

```lua
if wasEarnedByMe == false then
    local x = {}

    for n, i in next, Enum.ItemRedundancySlot do
        local w = C_ItemUpgrade.GetHighWatermarkForSlot(i)
        x[i] = { w > iLvls[achievementId], w, n }
    end

    for i, v in next, x do
        if i < 12 and not v[1] or i > 11 and not (x[12][1] or x[13][1] and x[16][1] or x[14][1] and x[15][1]) then
            print(v[2], v[3])
        end
    end

    return
end
```

**Problem:**
- Single-character variable names (`x`, `w`, `n`, `i`, `v`)
- Complex boolean logic that's very hard to parse
- No comments explaining the slot checking algorithm
- Unclear purpose of the nested conditions

**Impact:**
- Nearly impossible to debug or modify
- High risk of introducing bugs during maintenance
- New contributors will struggle to understand

**Recommended Fix:**
Break into smaller, well-documented functions:
```lua
-- Check which gear slots need upgrading for achievement
local function GetSlotsNeedingUpgrade(achievementId, itemLevel)
    local slotsToUpgrade = {}
    
    for slotName, slotId in next, Enum.ItemRedundancySlot do
        local currentHighWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(slotId)
        local meetsRequirement = currentHighWatermark > itemLevel
        
        slotsToUpgrade[slotId] = {
            meetsRequirement = meetsRequirement,
            currentLevel = currentHighWatermark,
            slotName = slotName
        }
    end
    
    return slotsToUpgrade
end

-- Check if weapon/ring slots meet special conditions
local function CheckSpecialSlotRequirements(slots)
    -- Weapons: Need both main hand (12) and off hand (13), or two-hand (16)
    local hasWeapons = slots[12].meetsRequirement or 
                      (slots[13].meetsRequirement and slots[16].meetsRequirement)
    
    -- Rings: Need both ring slots (14 and 15)
    local hasRings = slots[14].meetsRequirement and slots[15].meetsRequirement
    
    return hasWeapons, hasRings
end

-- Then use these in main function
if wasEarnedByMe == false then
    local slots = GetSlotsNeedingUpgrade(achievementId, iLvls[achievementId])
    
    for slotId, slotInfo in next, slots do
        local needsUpgrade = false
        
        if slotId < 12 then
            -- Regular slots: just check if meets requirement
            needsUpgrade = not slotInfo.meetsRequirement
        else
            -- Special slots: weapons and rings need complex checks
            local hasWeapons, hasRings = CheckSpecialSlotRequirements(slots)
            needsUpgrade = not (hasWeapons or hasRings)
        end
        
        if needsUpgrade then
            print(slotInfo.currentLevel, slotInfo.slotName)
        end
    end
    
    return
end
```

---

## Medium Priority Issues

### 5. Missing Error Handling Throughout
**Severity:** 🟡 **MEDIUM**

**Affected Files:** All files

**Problem:**
- No validation of API return values
- No pcall protection for potentially failing operations
- No user feedback when operations fail

**Examples:**
```lua
-- AngusUI.lua - No check if frames exist
MainMenuBar.BorderArt:SetVertexColor(.25, .25, .25)

-- Crests.lua - No validation of achievement data
local id, name, points, completed, month, day, year, description, flags,
icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementId)

-- TeleportBack.lua - No check if equipment slot has item
local equippedItemId = GetInventoryItemID("player", 15)
```

**Impact:**
- Silent failures that confuse users
- Potential nil reference errors causing addon to break
- Difficult to diagnose issues

**Recommended Fix:**
Add protective checks:
```lua
-- Example for AngusUI.lua
if MainMenuBar and MainMenuBar.BorderArt then
    MainMenuBar.BorderArt:SetVertexColor(.25, .25, .25)
else
    print("AngusUI: Warning - MainMenuBar not available")
end

-- Example for Crests.lua
local id, name, points, completed, month, day, year, description, flags,
icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementId)

if not name then
    print("AngusUI: Warning - Achievement " .. achievementId .. " not found")
    return
end

-- Example for TeleportBack.lua
local equippedItemId = GetInventoryItemID("player", 15)
if not equippedItemId then
    print("AngusUI: No back item equipped")
    return
end
```

---

### 6. Global Namespace Pollution
**Severity:** 🟡 **MEDIUM**

**Location:** AngusUI.lua lines 11 and 19

```lua
function Set(list)  -- ❌ Global function
    -- ...
end

function SlashCommand(command)  -- ❌ Global function
    -- ...
end
```

**Problem:**
- These functions are defined globally, not in the AngusUI namespace
- Could conflict with other addons
- Not following WoW addon best practices

**Impact:**
- Potential conflicts with other addons using same function names
- Harder to track function usage

**Recommended Fix:**
```lua
-- Make them local to the file
local function Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

local function SlashCommand(command)
    -- ... existing code
end

-- Or add to namespace if needed elsewhere
function AngusUI:Set(list)
    -- ...
end
```

---

### 7. Unused/Dead Code
**Severity:** 🟡 **MEDIUM**

**Location:** Delves.lua lines 83-92

```lua
local frame = CreateFrame("FRAME", "AngusUIDelveSpeedrunning");
frame:RegisterEvent("CHAT_MSG_MONSTER_SAY");
local function eventHandler(self, event, text, playerName, ...)
    if (playerName == "Brann Bronzebeard") then
        -- AngusUI:Delve()  -- ❌ Commented out
    end
end
frame:SetScript("OnEvent", eventHandler);
```

**Problem:**
- Event handler is registered but functionality is commented out
- Creates an event listener that does nothing
- Wastes minimal resources

**Impact:**
- Minor performance impact (very small)
- Code clutter and confusion

**Recommended Fix:**
Either implement the feature or remove:
```lua
-- Option 1: Implement the feature
if (playerName == "Brann Bronzebeard") then
    -- Add logic to auto-start timer on Brann interaction
    AngusUI:StartDelveSpeedrun()
end

-- Option 2: Remove entirely until needed
-- (delete lines 83-92)
```

---

## Low Priority Issues

### 8. Inconsistent Variable Naming Conventions
**Severity:** 🟢 **LOW**

**Affected Files:** Multiple

**Problem:**
Mix of naming styles:
- camelCase: `nonTeleportBack`, `delveIsActive`, `crestQuests`
- lowercase: `darkness`, `backs`, `vault`
- snake_case (rare): none found

**Recommendation:**
Standardize on camelCase for local variables:
```lua
local darkness = .6        -- Good
local backIds = {...}      -- Good (already following)
local vault = {...}        -- Change to: vaultRewards
local crests = {...}       -- Change to: crestRewards
```

---

### 9. Magic Numbers Without Constants
**Severity:** 🟢 **LOW**

**Affected Files:** Multiple

**Problem:**
Hardcoded values without explanation:

```lua
-- AngusUI.lua
local darkness = .6  -- What does .6 represent?
FRIENDS_FRAME_FRIEND_HEIGHT = 17  -- Why 17?
local widen = 50  -- Why 50?
local heighten = 300  -- Why 300?

-- UI.lua
if (layouts.activeLayout < 3) then  -- Why 3?
local actualActiveLayout = layouts.activeLayout - 2  -- Why subtract 2?
```

**Recommendation:**
Use named constants:
```lua
-- AngusUI.lua
local UI_DARKNESS_LEVEL = 0.6  -- 60% darkness for action bar theming
local FRIENDS_LIST_ROW_HEIGHT = 17  -- Height per friend row
local FRIENDS_FRAME_WIDTH_INCREASE = 50  -- Extra width in pixels
local FRIENDS_FRAME_HEIGHT_INCREASE = 300  -- Extra height in pixels

-- UI.lua
local BLIZZARD_DEFAULT_LAYOUTS_COUNT = 2  -- WoW has 2 default layouts before custom ones
local CUSTOM_LAYOUT_OFFSET = 2  -- Offset for custom layout indices
```

---

### 10. Missing Function Documentation
**Severity:** 🟢 **LOW**

**Affected Files:** All files

**Problem:**
No function comments explaining:
- Purpose
- Parameters
- Return values
- Side effects

**Example - Current:**
```lua
function AngusUI:TeleportBack()
    -- 42 lines of code with no explanation
end
```

**Example - Improved:**
```lua
---
-- Automatically equips a teleportation cloak from inventory, uses it,
-- and swaps back to the original cloak after cooldown expires.
--
-- This function handles the full flow:
-- 1. Saves currently equipped back item
-- 2. Finds available teleportation cloak from predefined list
-- 3. Equips the teleportation cloak
-- 4. Monitors cooldown and re-equips original cloak when ready
--
-- @return nil
-- @side-effect Modifies equipped gear
-- @side-effect Uses item on cooldown
---
function AngusUI:TeleportBack()
    -- ... implementation
end
```

---

## Additional Observations

### Positive Aspects ✅

1. **Clean Module Structure**: Each feature is in its own file, making it easy to navigate
2. **Consistent Namespace Usage**: Uses `AngusUI` namespace properly for most functions
3. **Efficient Event Handling**: Proper event registration and unregistration
4. **Good TOC File**: Proper metadata and load order specified
5. **Useful Features**: Provides real value to end-game WoW players
6. **Clear Slash Commands**: Intuitive command structure

### Code Smells 👃

1. **Large Functions**: Some functions exceed 30 lines and do multiple things
2. **Deep Nesting**: Crests.lua has 3-4 levels of nesting in places
3. **Repeated Patterns**: Color code strings repeated throughout
4. **No Constants File**: All constants scattered across files

### Security Considerations 🔒

1. **No User Input Validation**: Slash commands don't validate input (low risk for WoW addons)
2. **No Data Sanitization**: Quest/item IDs not validated before API calls
3. **Global State Mutation**: Modifies global `FRIENDS_FRAME_FRIEND_HEIGHT`

---

## Recommendations by Priority

### Immediate Action Required 🔴
1. **Fix UI.lua loop exit bug** - Critical for functionality
2. **Fix TeleportBack.lua Set() function reference** - Causes runtime error
3. **Fix Delves.lua state management** - Breaks feature after first use

### High Priority 🟠
4. Refactor Crests.lua complex logic for maintainability
5. Add error handling to all API calls

### Medium Priority 🟡
6. Move global functions to namespace or make local
7. Remove or implement unused Delves event handler
8. Add input validation to slash commands

### Low Priority 🟢
9. Standardize variable naming conventions
10. Replace magic numbers with named constants
11. Add function documentation
12. Create constants file for shared values

---

## Testing Recommendations

Since this is a WoW addon, testing must be done in-game:

### Test Cases to Verify After Fixes:
1. **UI Layout Switching**:
   - Test on 4K monitor (3840x2160)
   - Test on 1440p monitor (2560x1440)
   - Test on ultrawide monitor (aspect ratio > 2:1)
   - Test with multiple custom layouts

2. **Teleport Back**:
   - Test with no teleport cloak in inventory
   - Test with teleport cloak equipped
   - Test with teleport cloak in bags
   - Test after cooldown completes

3. **Delve Timer**:
   - Start timer, stop immediately
   - Start timer, stop after delay
   - Try starting timer twice
   - Test after stopping once (verify can restart)

4. **Quest Tracking**:
   - Test with all quests complete
   - Test with no quests complete
   - Test with mixed completion state

---

## Metrics

**Total Files Reviewed:** 7 Lua files  
**Total Lines of Code:** ~380 lines  
**Issues Found:** 10  
**Critical/High Priority Issues:** 4  
**Estimated Fix Time:** 2-4 hours  
**Code Quality Score:** 6.5/10

---

## Conclusion

The AngusUI addon provides useful functionality but has several bugs that need immediate attention. The most critical issues involve logic errors that break core functionality. Once these are fixed and error handling is improved, the addon will be more robust and maintainable.

The codebase shows good organization and follows some WoW addon best practices, but would benefit from more defensive programming, better documentation, and refactoring of complex logic.

**Recommendation:** Address critical and high priority issues before next release. Consider adding a testing checklist for seasonal updates when quest/achievement IDs change.

---

**Review Status:** ✅ Complete  
**Next Steps:** Implement fixes for critical issues, then address high priority items
