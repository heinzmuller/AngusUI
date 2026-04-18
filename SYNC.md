# Sync Data Spec

This document is the working contract for `AngusUIDB.sync.account` and
`AngusUICharacterSyncDB`.

It serves two purposes:

- Keep addon-side sync work aligned with a stable saved-variable structure.
- Act as a pasteable implementation spec for an agent or engineer building the
  external dashboard or service that consumes this data.

## Purpose

This sync payload is intended to be consumed by an external dashboard or other
character-management service.

The structure should be treated as an operational data contract, not just an
internal implementation detail.

The goals for this structure are:

- Keep the payload slim so it is cheap to save, parse, and transmit.
- Keep the shape stable so external consumers are easy to maintain.
- Store data in a machine-friendly format, using IDs and compact values where
  possible.
- Keep presentation concerns out of the sync payload; this data is for systems,
  not for the in-game toast UI.
- Prefer raw snapshots that are easy to recompute and easy to extend over more
  decorative nested structures.

## Contract Rules

- The canonical account root is `AngusUIDB.sync.account`.
- The canonical character root is `AngusUICharacterSyncDB`.
- Account data stays in the shared saved-variable file; do not duplicate it into
  the per-character file.
- Character data should stay flat at the character root; do not introduce extra
  wrapper keys like `sync`, `character`, `export`, `payload`, or `data` inside
  `AngusUICharacterSyncDB`.
- Legacy `AngusUIDB.sync.characters` data is obsolete and not part of the
  contract.
- Values should prefer primitives, compact arrays, and ID-keyed tables.
- Names used as keys should only be used when they are naturally stable and
  human-meaningful, such as profession names.
- UI-facing formatting, labels, colors, ordering hints, and display text do not
  belong in this payload.
- Missing gameplay categories should usually still exist as empty tables when
  the addon tracks them, so external consumers can rely on a stable shape.
- Example values in this document are illustrative; consumers should not hardcode
  exact counts, timestamps, or item levels from the examples.

## Consumer Guidance

- Treat `weeklyResetKey` as the main coarse-grained weekly partition key.
- Treat `lastChanged` and `lastChangedResetKey` as snapshot metadata, not as the
  sole source of truth for weekly state.
- Treat `greatVault` values as unlocked reward item levels only.
- Treat `currencies` as `currencyID -> quantity`.
- Treat `gold` as the character's current carried gold value, stored in copper.
- Divide `gold` by `10000` to display a gold-denominated value.
- Treat `account.currencies` as tracked warband-transferable currency totals
  across the account.
- Treat `account.weeklyQuests` as the current account-level set of tracked
  weekly quest IDs that are active this reset, keyed by quest ID with quest
  names as values.
- Treat `account.warbandBank.items` as `itemID -> totalCount` aggregated across
  all purchased warband bank tabs.
- Treat `account.warbandBank.tabs` as the canonical layout snapshot for
  repainting the warband bank in external consumers.
- Treat `weeklies` as the list of tracked active weekly quest IDs completed by that
  character this reset.
- Treat `seasonal.quests` and `seasonal.achievements` as the per-character lists
  of completed tracked seasonal IDs for that character.
  Achievement IDs in `seasonal.achievements` should only be present when the
  achievement was earned by that specific character, not merely completed
  somewhere on the account.
- Treat `professions` as a sparse map of learned professions only.
- Treat `professions[professionName].skillLevel` as the character's current skill
  rank for that learned profession snapshot.
- Treat `AngusUICharacterSyncDB` as a single-character payload with no
  `characters[...]` wrapper.
- Treat account and character sync data as separate payloads coming from
  separate saved-variable files.
- Treat `AngusUIDB.sync.account` as account-wide state shared across all
  characters in the same shared saved-variable file.

## Shape

```lua
AngusUIDB = {
    sync = {
        account = {
            weeklyResetKey = 123456,
            firstWorldBoss = false,
            weeklyQuests = {
                [57637] = "Disturbance Detected: Firelands",
            },
            currencies = {
                [3383] = 0,
                [3341] = 0,
                [3343] = 0,
                [3345] = 0,
                [3347] = 0,
                [3378] = 0,
                [3212] = 0,
            },
            warbandBank = {
                gold = 0,
                slotCount = 98,
                items = {
                    [211297] = 48,
                    [224828] = 12,
                },
                tabs = {
                    [1] = {
                        id = 13,
                        name = "Mats",
                        icon = 4620675,
                        slots = {
                            [1] = {
                                itemID = 211297,
                                count = 20,
                            },
                            [2] = {
                                itemID = 224828,
                                count = 5,
                            },
                        },
                    },
                },
            },
        },
    },
}

AngusUICharacterSyncDB = {
    weeklyResetKey = 123456,
    lastChanged = "2026-04-05",
    lastChangedResetKey = 123456,
    delves = {
        gildedStashesLooted = 0,
        trovehuntersBounty = false,
        cofferKeyShardsRemaining = 600,
    },
    prey = {
        normal = 0,
        hard = 0,
        nightmare = 0,
        weekly = false,
    },
    professions = {
        ProfessionName = {
            skillLevel = 100,
            treatise = false,
            weekly = false,
            treasuresRemaining = 2,
            concentration = {
                current = 500,
                timestamp = 1775412345,
            },
        },
    },
    greatVault = {
        raid = {},
        dungeons = {},
        delves = {},
    },
    currencies = {
        [3383] = 0,
        [3341] = 0,
        [3343] = 0,
        [3345] = 0,
        [3347] = 0,
        [3378] = 0,
        [3212] = 0,
        [3310] = 0,
        [3028] = 0,
    },
    gold = 0,
    seasonal = {
        quests = {},
        achievements = {},
    },
    weeklies = {
        57637,
    },
}
```

## Currency IDs

```lua
3383 = Adventurer Dawncrest
3341 = Veteran Dawncrest
3343 = Champion Dawncrest
3345 = Hero Dawncrest
3347 = Myth Dawncrest
3378 = Dawnlight Manaflux
3212 = Radiant Spark Dust
3310 = Coffer Key Shards
3028 = Restored Coffer Key
```

Account-level currency totals are only populated for tracked currencies that are
warband-transferable according to the live client API.

## Active Weekly Quests

Currently tracked rotating weekly quests are the active Timewalking raid quests:

```lua
47523 = Disturbance Detected: Black Temple
50316 = Disturbance Detected: Ulduar
57637 = Disturbance Detected: Firelands
```

`account.weeklyQuests` only contains tracked quests that are actually active for
the current weekly reset. `AngusUICharacterSyncDB.weeklies` only contains quest
IDs from that active set which the character has completed.

## Fresh Weekly Character

Example for a newly reset character with no tracked weekly progress yet.

```lua
AngusUICharacterSyncDB = {
    weeklyResetKey = 123456,
    lastChanged = "2026-04-05",
    lastChangedResetKey = 123456,
    delves = {
        gildedStashesLooted = 0,
        trovehuntersBounty = false,
        cofferKeyShardsRemaining = 600,
    },
    prey = {
        normal = 0,
        hard = 0,
        nightmare = 0,
        weekly = false,
    },
    professions = {
        Alchemy = {
            skillLevel = 100,
            treatise = false,
            weekly = false,
            treasuresRemaining = 2,
            concentration = {
                current = 500,
                timestamp = 1775412345,
            },
        },
        Herbalism = {
            skillLevel = 100,
            treatise = false,
            weekly = false,
            treasuresRemaining = 2,
            concentration = {
                current = 500,
                timestamp = 1775412345,
            },
        },
    },
    greatVault = {
        raid = {},
        dungeons = {},
        delves = {},
    },
    currencies = {
        [3383] = 0,
        [3341] = 0,
        [3343] = 0,
        [3345] = 0,
        [3347] = 0,
        [3378] = 0,
        [3212] = 0,
        [3310] = 0,
        [3028] = 0,
    },
    gold = 0,
    seasonal = {
        quests = {},
        achievements = {},
    },
    weeklies = {},
}
```

## Partially Done Character

Example for a character with partial weekly progress.

```lua
AngusUICharacterSyncDB = {
    weeklyResetKey = 123456,
    lastChanged = "2026-04-05",
    lastChangedResetKey = 123456,
    delves = {
        gildedStashesLooted = 2,
        trovehuntersBounty = true,
        cofferKeyShardsRemaining = 240,
    },
    prey = {
        normal = 3,
        hard = 1,
        nightmare = 3,
        weekly = false,
    },
    professions = {
        Alchemy = {
            skillLevel = 91,
            treatise = true,
            weekly = false,
            treasuresRemaining = 1,
            concentration = {
                current = 412,
                timestamp = 1775416789,
            },
        },
        Herbalism = {
            skillLevel = 78,
            treatise = false,
            weekly = true,
            treasuresRemaining = 0,
            concentration = {
                current = 284,
                timestamp = 1775416789,
            },
        },
    },
    greatVault = {
        raid = { 671 },
        dungeons = { 678, 684 },
        delves = { 665 },
    },
    currencies = {
        [3383] = 51,
        [3341] = 37,
        [3343] = 18,
        [3345] = 6,
        [3347] = 2,
        [3378] = 4280,
        [3212] = 24,
        [3310] = 360,
        [3028] = 2,
    },
    gold = 9876543,
    seasonal = {
        quests = {
            93525,
        },
        achievements = {},
    },
    weeklies = {
        57637,
    },
}
```

## Completed Weekly Character

Example for a character with the tracked weeklies fully done.

```lua
AngusUICharacterSyncDB = {
    weeklyResetKey = 123456,
    lastChanged = "2026-04-05",
    lastChangedResetKey = 123456,
    delves = {
        gildedStashesLooted = 4,
        trovehuntersBounty = true,
        cofferKeyShardsRemaining = 0,
    },
    prey = {
        normal = 4,
        hard = 2,
        nightmare = 4,
        weekly = true,
    },
    professions = {
        Blacksmithing = {
            skillLevel = 100,
            treatise = true,
            weekly = true,
            treasuresRemaining = 0,
            concentration = {
                current = 732,
                timestamp = 1775420000,
            },
        },
        Mining = {
            skillLevel = 100,
            treatise = true,
            weekly = true,
            treasuresRemaining = 0,
            concentration = {
                current = 605,
                timestamp = 1775420000,
            },
        },
    },
    greatVault = {
        raid = { 684, 691, 701 },
        dungeons = { 678, 684, 691 },
        delves = { 665, 671, 678 },
    },
    currencies = {
        [3383] = 120,
        [3341] = 88,
        [3343] = 44,
        [3345] = 19,
        [3347] = 8,
        [3378] = 9420,
        [3212] = 75,
        [3310] = 600,
        [3028] = 4,
    },
    gold = 5432100,
    seasonal = {
        quests = {
            93525,
        },
        achievements = {
            61519,
        },
    },
    weeklies = {
        57637,
    },
}
```

## Notes

- `account.firstWorldBoss` is account-wide, not per-character.
- `account.currencies` stores account totals for tracked warband-transferable
  currencies as `currencyID = count`.
- `account.weeklyQuests` stores the active tracked weekly quests for the current
  reset as `questID = questName`.
- `account.warbandBank.gold` is deposited warband-bank gold stored in copper.
- `account.warbandBank.slotCount` is the slot count per tab used by the saved
  layout snapshot.
- `account.warbandBank.items` stores aggregated item totals as `itemID = count`.
- `account.warbandBank.tabs[index]` stores tab order, tab metadata, and sparse
  slot contents so external apps can reconstruct the original tab/slot layout.
- `account.warbandBank.tabs[index].slots[slotID]` is only present when that slot
  contains an item; empty slots are omitted.
- `AngusUICharacterSyncDB` is the complete sync payload for one character,
  stored in the per-character saved-variable file.
- `AngusUICharacterSyncDB.weeklies` is a sorted array of completed tracked
  weekly quest IDs for the currently active `account.weeklyQuests` set.
- `prey.normal`, `prey.hard`, and `prey.nightmare` are tracked separately and
  each store a weekly `0..4` completion count for that difficulty.
- `prey.weekly` reflects only whether `A Nightmarish Task` is completed for the
  current week.
- Warband bank item snapshots update when the addon can read account-bank
  contents; if the bank is not currently accessible, the last known item snapshot
  is preserved while gold may still update.
- `professions` only contains learned professions for that character.
- `professions[professionName].skillLevel` stores the current profession skill
  rank captured from the live profession APIs.
- `greatVault` only stores unlocked reward rows as item-level arrays.
- `currencies` stores tracked currency snapshots as `currencyID = count`.
- `gold` stores the character's current on-hand gold value in copper; divide by
  `10000` to display gold.
- `seasonal.quests` and `seasonal.achievements` store only the completed tracked
  per-character seasonal IDs for external consumers.
- `seasonal.achievements` should follow the same character-earned rule as the
  addon's crest achievement checks, using the live achievement API's
  character-earned signal rather than account-wide completion.
- `lastChanged` and timestamps are examples only.
- This document should be updated whenever the sync contract changes.
