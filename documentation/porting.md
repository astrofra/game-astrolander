# Porting Roadmap: GameStart3D -> Godot

This document describes a practical, step-by-step plan to port the project
from the discontinued GameStart3D engine to Godot. The goal is to preserve
gameplay behavior while adopting Godot-native scene, scripting, and asset
pipelines. No code changes are executed yet; this is a roadmap only.

## Scope and assumptions
- Main game logic lives in `src/scripts`.
- Levels are stored in `src/levels` as `.nms` "xml-ish" scenegraph files.
- GameStart3D can load a `.nms` scene as a node (scene instance, like a Prefab).
- All original assets remain available in original formats (`.fbx`, `.mp3`,
  `.png`, `.tga`, etc).

## Goals
- Rebuild the game in Godot with equivalent gameplay, visuals, and audio.
- Create a repeatable pipeline to migrate `.nms` levels to Godot scenes.
- Keep parity with original content and minimize behavior regressions.

## Phase 0 - Discovery and inventory
1) Repository audit
   - Enumerate script entry points in `src/scripts`.
   - Identify runtime systems: input, camera, UI, AI, physics, audio, save/load.
   - List all `.nms` files in `src/levels` and their relationships.
   - Inventory assets by type and usage (meshes, textures, audio, materials).

2) Engine feature mapping
   - Map GameStart3D concepts to Godot equivalents:
     - Node -> Godot Node
     - Scene instance (prefab) -> Godot PackedScene instance
     - Scenegraph -> Godot scene tree
   - Identify custom features in GameStart3D that require custom Godot systems
     (e.g., physics tweaks, animation handling, custom shaders).

3) Decide target Godot version
   - Choose Godot 4.x (recommended) or 3.x (compatibility).
   - Lock engine version early to avoid rework.

Deliverables:
- Script/system inventory summary.
- Asset inventory spreadsheet or markdown list.
- Mapping table between GameStart3D and Godot features.

## Phase 1 - Project setup and scaffolding
1) Godot project creation
   - Create a new Godot project root (recommended in a `godot/` subfolder).
   - Define folders: `scenes/`, `scripts/`, `assets/`, `levels/`, `ui/`, `audio/`.
   - Configure project settings: display, input map, physics settings, audio.

2) Base systems
   - Create a minimal boot scene: `Main.tscn`.
   - Add a root `Game` node to manage scene loading and global systems.
   - Stub managers: `LevelManager`, `AudioManager`, `SaveManager`.

Deliverables:
- Godot project with boot scene and managers.
- Input map aligned with current controls.

## Phase 2 - `.nms` format understanding and conversion plan
1) Analyze `.nms` structure
   - Identify node types, transforms, components, and references.
   - Determine how scene instances are referenced (by name, path, id).
   - Identify material, mesh, and texture bindings.

2) Define conversion strategy
   - Option A: Build a one-time converter to `.tscn` (recommended).
   - Option B: Runtime importer inside Godot (if iteration speed is needed).
   - Determine how to map `.nms` nodes to Godot nodes (e.g., MeshInstance3D,
     Node3D, Camera3D, Light3D, Area3D).

3) Establish prefabs -> PackedScenes mapping
   - Each "scene instance" referenced by `.nms` maps to a `.tscn` in Godot.
   - Build a catalog of prefab names and corresponding Godot scenes.

Deliverables:
- `.nms` format notes.
- Node mapping table (GameStart3D node -> Godot node).
- Decision on conversion approach and tool plan.

## Phase 3 - Asset import pipeline
1) Meshes and animations
   - Decide conversion path: `.fbx` -> `.glb` or direct import.
   - Validate scale, orientation, and animation playback.

2) Textures and materials
   - Convert `.tga` to `.png` if needed for consistency.
   - Create a material library; define how to map GameStart3D materials.

3) Audio
   - Import `.mp3`/`.wav` and verify looping behavior and volume levels.

Deliverables:
- Asset import guidelines and checklists.
- A sample asset pack imported and verified in Godot.

## Phase 4 - Core gameplay systems port
1) Script translation strategy
   - Decide on GDScript or C#.
   - Define a mapping approach for key script systems.
   - Identify scripts that can be reused vs rewritten.

2) Implement critical systems first
   - Player controller and camera.
   - Physics behavior (collisions, triggers, movement).
   - UI/menus and HUD.
   - Audio triggers and music system.

Deliverables:
- Core systems implemented and verified in a small test level.
- Behavior parity checklist for player controls and camera.

## Phase 5 - Level conversion and validation
1) Convert a single representative level
   - Pick a mid-complexity `.nms` file.
   - Convert to Godot scene(s), fix layout, and verify gameplay.

2) Iterate on converter and mapping
   - Adjust conversion rules for missing features and edge cases.
   - Create tooling or manual fixes for problematic nodes.

3) Batch-convert remaining levels
   - Run conversion process for all `.nms` files.
   - Validate each level for missing assets, broken references, or scale issues.

Deliverables:
- Working conversion pipeline.
- All levels converted with validation notes.

## Phase 6 - Parity testing and polish
1) Gameplay parity checks
   - Compare behaviors to original: movement, physics, AI, triggers.
   - Establish a bug list for regressions.

2) Visual and audio parity
   - Lighting equivalence, material look, and post-processing.
   - Audio mix and spatialization.

3) Performance and stability
   - Measure FPS, memory usage, load times.
   - Optimize scene hierarchy and asset usage.

Deliverables:
- Parity and regression report.
- Performance profiling summary.

## Phase 7 - Release prep
1) Build configuration
   - Export presets for target platforms.
   - Validate input and display settings.

2) Documentation
   - Update README with build and run steps.
   - Document conversion workflow and tooling.

Deliverables:
- Export presets configured.
- Porting documentation finalized.

## Risks and mitigations
- Unknown `.nms` edge cases -> start with a representative level early.
- Custom engine behaviors -> isolate and re-implement in Godot.
- Asset scale/orientation mismatches -> set consistent import conventions.

## Proposed next actions
1) Approve target Godot version and scripting language.
2) Select a representative `.nms` level for the first conversion pass.
3) Confirm whether a converter tool should be built or runtime import is required.
