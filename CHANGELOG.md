# Changelog

## 2026-06-05

### Fixed runtime compatibility for project startup

- Added the legacy `ToolEdit`, `ToolPreview`, `ToolProjectPreview`, and `NoTool` constants to `bin/runtime/script/compat.nut`.
- Updated `EngineGetToolMode()` in `bin/runtime/script/compat.nut` to return `NoTool` in the current standalone/project runtime.
- This fixes the startup crash triggered by save-game loading, where the game expected `NoTool` to exist in script scope.

### Restored clock-scale support in the compatibility layer

- Implemented `EngineSetClockScale()` in `bin/runtime/script/compat.nut` so it forwards to `SceneSetClockScale(g_scene, k)` when a scene is active.
- This restores the expected behavior for pause handling and gameplay time-scale changes used by the original scripts.

### Fixed viewport handling in UI scripts

- Added `GetViewportSizeCompat()` to `src/scripts/utils.nut`.
- The helper accepts multiple possible `RendererGetViewport()` return shapes and falls back to `g_screen_width` / `g_screen_height` when needed.
- Updated `WriterWrapper()` in `src/scripts/utils.nut` to use the compatibility helper instead of assuming a `.z` / `.w` viewport layout.
- Updated `NormalizedToScreenSpace()` in `src/scripts/ui.nut` to use the same compatibility helper.
- Updated the focus-layer scaling code in `src/scripts/ui_how_to_control.nut` to stop relying on direct `.z` / `.w` viewport access.
- These changes fix the title-screen crash caused by the current runtime returning a viewport object that does not expose the old `z` field expected by the original code.

### Validation

- Verified that launching the project through `project.ngp` now reaches the title screen without a new Squirrel runtime exception in `engine_log.txt`.
- Verified that gameplay for `level_0.nms` loads and runs correctly when started through the project context used by the game.
