# AGENTS.md

AngusUI is a single-addon Lua codebase where most files own one feature and attach their public entrypoints onto the shared `AngusUI` table.

**Structure**

- `AngusUI.toc` is the load order and the quickest file index.
- `AngusUI.lua` is the bootstrap file. It should stay focused on slash commands, shared helpers, and startup routing.
- Feature files live in `Modules/`, should keep their own local helpers, and should expose only the small `AngusUI:` API they actually need.
- Saved settings live in `AngusUIDB.settings`.
- Sync data lives in `AngusUICharacterSyncDB` and is built in `Sync.lua`.

**Guidelines**

- Put a short module intention comment on the first line of every Lua file.
- Put short function intention comments directly above non-trivial helpers and exported functions.
- Let each module register and own its own events when it needs live refresh behavior.
- Do not centralize unrelated feature events in `AngusUI.lua`; keep event ownership in the feature module that uses them.
- Prefer file-local helpers first and only export true module entrypoints on `AngusUI`.
- Keep changes small and local to the module that owns the behavior.
- When adding a new reactive feature, create its watcher frame inside that module instead of routing through a global event hub.
