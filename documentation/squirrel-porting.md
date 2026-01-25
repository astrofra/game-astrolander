# Squirrel -> Godot Porting Notes (src/scripts/*.nut)

Scope: This document covers every `.nut` under `src/scripts`. It does not
cover `src/builtin/script` or `src/scriptlib`. Pseudo-code is intentionally
high-level and focuses on Godot architecture equivalents.

## src/scripts/ace_deleter.nut
Role: queue items for deletion once their command list/animation completes.
Godot equivalent: small helper that waits for Tween/AnimationPlayer to finish,
then `queue_free()`.
```gdscript
extends Node
class_name AceDeleter

var queue: Array[Node] = []

func register(node: Node) -> void:
    queue.append(node)

func update() -> void:
    for i in range(queue.size() - 1, -1, -1):
        var n = queue[i]
        if not is_instance_valid(n):
            queue.remove_at(i)
        elif _is_anim_done(n):
            n.queue_free()
            queue.remove_at(i)
```

## src/scripts/achievements.nut
Role: evaluate achievement conditions based on player state.
Godot equivalent: `AchievementsHandler.gd` attached to game controller.
```gdscript
extends Node
class_name AchievementsHandler

var player: Node
var achievements := []

func _ready() -> void:
    achievements = [
        {"eval": _perfect, "ingame": false, "passed": false},
        {"eval": _eco_drive, "ingame": false, "passed": false},
        {"eval": _fuel_close_call, "ingame": false, "passed": false},
    ]

func update() -> void:
    for a in achievements:
        if a.ingame:
            a.passed = a.eval.call()

func _perfect() -> bool:
    return player.hit_counter <= 0
```

## src/scripts/artefact.nut
Role: placeholder item script for artifacts.
Godot equivalent: marker script on artifact nodes; most logic handled by scene.
```gdscript
extends Node3D
class_name Artefact
```

## src/scripts/audio.nut
Role: global SFX/music volume and a sound table.
Godot equivalent: autoload `AudioBus.gd` or `AudioManager.gd`.
```gdscript
extends Node
class_name AudioManager

var sounds := {"explode": preload("res://audio/sfx/sfx_explode.wav")}

func play_sound(id: String) -> void:
    if sounds.has(id):
        var p = AudioStreamPlayer.new()
        p.stream = sounds[id]
        p.volume_db = linear_to_db(get_sfx_volume())
        add_child(p)
        p.play()

func get_sfx_volume() -> float: return Globals.player_data.sfx_volume
func set_sfx_volume(v: float) -> void: Globals.player_data.sfx_volume = clamp(v, 0.0, 1.0)
```

## src/scripts/base_project.nut
Role: scene flow controller with fade and loader scene.
Godot equivalent: autoload scene router that handles transitions.
```gdscript
extends Node
class_name SceneFlow

var requested_scene := ""
var current_scene: Node
var transition: CanvasLayer

func goto_scene(path: String) -> void:
    requested_scene = path
    _start_fade_out()

func _on_fade_out_done() -> void:
    if current_scene:
        current_scene.queue_free()
    current_scene = load(requested_scene).instantiate()
    get_tree().root.add_child(current_scene)
    _start_fade_in()
```

## src/scripts/black_screen.nut
Role: black overlay scene.
Godot equivalent: minimal `CanvasLayer` with ColorRect.
```gdscript
extends CanvasLayer
func _ready() -> void:
    $ColorRect.color = Color.BLACK
```

## src/scripts/bonus.nut
Role: time-limited buffs (fast/slow clock, time stop, shield).
Godot equivalent: coroutine timers on Level script.
```gdscript
func apply_bonus_fast_clock() -> void:
    Engine.time_scale = 2.0 * Globals.clock_scale
    await get_tree().create_timer(Globals.bonus_duration).timeout
    Engine.time_scale = 1.0 * Globals.clock_scale
```

## src/scripts/camera_handler.nut
Role: follow camera with smoothing, velocity-based offset, close-up mode.
Godot equivalent: Camera3D controller script.
```gdscript
extends Camera3D
class_name CameraHandler

var target: Node3D
var target_vel := Vector3.ZERO
var close_up := false
var close_up_factor := 0.0

func _physics_process(delta: float) -> void:
    var pos = global_position
    var v_d = (target.global_position - pos)
    v_d.z = 0.0
    pos += v_d * 5.0 * delta
    # compute offset based on target_vel, clamp, smooth, rotate, etc.
    global_position = pos + _calc_offset()
```

## src/scripts/default_stats.nut
Role: default level stats table (stopwatch/fuel targets).
Godot equivalent: `default_stats.gd` or JSON resource.
```gdscript
const LEVEL_DEFAULTS := {
    "level_0": {"stopwatch": 111050, "fuel": 85},
    # ...
}
```

## src/scripts/feedback_emitter.nut
Role: spawn a quick scale-in/out visual effect.
Godot equivalent: spawn a MeshInstance3D or Sprite3D with Tween.
```gdscript
extends Node3D
class_name FeedbackEmitter

var effect_scene := preload("res://effects/feedback.tscn")

func emit(pos: Vector3) -> void:
    var e = effect_scene.instantiate()
    e.global_position = pos
    add_child(e)
    e.play_and_free()
```

## src/scripts/global_callbacks.nut
Role: forward global engine callbacks to current scene script.
Godot equivalent: autoload that forwards OS/system events to active scene.
```gdscript
extends Node
func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().current_scene.on_close_requested()
```

## src/scripts/globals.nut
Role: constants, globals, UI colors, platform helpers.
Godot equivalent: autoload `Globals.gd`.
```gdscript
extends Node
class_name Globals

var supported_languages = ["en", "fr", "es", "it", "jp"]
var current_language = "en"
var screen_size = Vector2(1280, 960)
var gravity = Vector3(0, -4, 0)
var clock_scale = 1.0
var bonus_duration = 10.0
var ui_color_blue = Color8(117, 155, 168, 180)

func is_touch_platform() -> bool:
    return OS.get_name() in ["Android", "iOS"]
```

## src/scripts/inventory.nut
Role: track collected items and notify HUD.
Godot equivalent: `Inventory.gd` used by Level/HUD.
```gdscript
extends Node
class_name Inventory

var items: Array[String] = []
var hud: Node

func add_item(name: String) -> void:
    items.append(name)
    if hud: hud.update_inventory(items)
```

## src/scripts/level_generator.nut
Role: build a level from a bitmap (color codes -> walls/start/end/artifacts).
Godot equivalent: offline converter or runtime generator.
```gdscript
extends Node
class_name LevelGenerator

@export var bitmap_path := "res://levels/level_0.png"
var color_code = {"wall": Color(1, 0.5, 0), "start": Color(1, 0, 0)}

func generate(scene_root: Node3D) -> void:
    var img = Image.load_from_file(bitmap_path)
    for y in img.get_height():
        for x in img.get_width():
            var c = img.get_pixel(x, y)
            if _is_wall(c): _spawn_block(scene_root, x, y)
            elif _is_start(c): _set_start(x, y)
```

## src/scripts/locale.nut
Role: select language based on system and load locale table.
Godot equivalent: use `TranslationServer` and `.translation` resources.
```gdscript
extends Node
class_name LocaleManager

func select_language_from_system() -> void:
    var lang = OS.get_locale_language()
    TranslationServer.set_locale(lang)

func load_locale_table() -> void:
    # load Translation resources or JSON dictionaries
    pass
```

## src/scripts/locale_en.nut
## src/scripts/locale_fr.nut
## src/scripts/locale_es.nut
## src/scripts/locale_it.nut
## src/scripts/locale_de.nut
## src/scripts/locale_jp.nut
## src/scripts/locale_cn.nut
Role: dictionaries of localized strings, some with arrays (credits).
Godot equivalent: `Translation` resources + JSON for complex arrays.
```gdscript
const LOCALE_EN := {
    "game_title": "ASTLAN",
    "credits": [{"desc": "Game Code & 3D Graphics", "name": "Astrofra"}],
}
```

## src/scripts/lunar_lander.nut
Role: player controller and physics, fuel/life, thrusters, collisions, audio.
Godot equivalent: `PlayerLander.gd` on `RigidBody3D` (closest to forces/impulses).

Suggested node setup:
- `PlayerLander` (RigidBody3D)
  - `pod_body_mesh` (MeshInstance3D)
  - `pod_body_wounded` (MeshInstance3D)
  - `thrust_item_l` (Marker3D)
  - `thrust_item_r` (Marker3D)
  - `flame_item_l` / `flame_item_m` / `flame_item_r` (MeshInstance3D or Sprite3D)
  - `shield_mesh` (MeshInstance3D)
  - `weak_zone` (Area3D or Marker3D)
  - `Audio/ThrustClean` (AudioStreamPlayer3D)
  - `Audio/ThrustDirty` (AudioStreamPlayer3D)
  - `Audio/Collision` (AudioStreamPlayer3D)

Key behaviors:
- Read input (touch or keyboard), optionally reverse controls.
- Apply thrust forces to body and side thrusters.
- Consume fuel while thrusting.
- Fade thruster flames and spawn smoke when close to walls.
- Auto-align rotation to upright based on speed and angular velocity.
- Handle collisions with damage scaling by speed and impact angle.
- Shield on/off toggles mesh visibility and collision.
- Loop thrust audio with clean/dirty blend, play collision sounds.

Pseudo-GDScript (structural outline):
```gdscript
extends RigidBody3D
class_name PlayerLander

@export var thrust := 15.0
@export var consumption := 2.5
@export var max_speed := 25.0
@export var speed_min_damage := 5.0
@export var speed_max_damage := 15.0
@export var min_damage := 5.0
@export var max_damage := 20.0

var fuel := 100.0
var life := 100.0
var shield_enabled := false
var thrusters_active := false
var current_speed := 0.0
var current_velocity := Vector3.ZERO
var low_dt_comp := 1.0
var low_speed_timer := 0.0
var hit_timeout := 0.0

var update_fn: Callable

@onready var mesh_body := $pod_body_mesh
@onready var mesh_wounded := $pod_body_wounded
@onready var thrust_l := $thrust_item_l
@onready var thrust_r := $thrust_item_r
@onready var flame_l := $flame_item_l
@onready var flame_m := $flame_item_m
@onready var flame_r := $flame_item_r
@onready var shield_mesh := $shield_mesh
@onready var thrust_clean := $Audio/ThrustClean
@onready var thrust_dirty := $Audio/ThrustDirty
@onready var collision_sfx := $Audio/Collision

func _ready() -> void:
    gravity_scale = 1.0
    axis_lock_angular_x = true
    axis_lock_angular_y = true
    linear_damp = 0.9
    mesh_body.scale = Vector3.ONE
    mesh_wounded.scale = Vector3.ZERO
    update_fn = _update_player_dead
    _setup_audio()

func _physics_process(delta: float) -> void:
    low_dt_comp = clamp(1.0 / (60.0 * delta), 0.0, 1.0)
    current_speed = linear_velocity.length()
    current_velocity = linear_velocity.normalized()
    _handle_low_speed_timer()
    if update_fn: update_fn.call(delta)

func _update_player_dead(delta: float) -> void:
    _fade_thrusters()
    _update_audio()

func _update_player_alive(delta: float) -> void:
    var left := false
    var right := false
    _read_input(left, right)
    if Globals.reversed_controls:
        var tmp = right; right = left; left = tmp
    if left or right:
        if fuel > 0.0:
            _consume_fuel(delta)
    _apply_thrust(left, right, delta)
    _fade_thrusters()
    _auto_align(delta)
    _update_audio()
    _check_player_stats()

func _read_input(out_left: bool, out_right: bool) -> void:
    if Globals.is_touch_platform():
        # interpret multitouch positions, update UI feedback
        pass
    else:
        out_left = Input.is_action_pressed("move_left")
        out_right = Input.is_action_pressed("move_right")

func _apply_thrust(left: bool, right: bool, delta: float) -> void:
    thrusters_active = false
    if fuel <= 0.0:
        return
    # speed limiting
    var speed_over = max(linear_velocity.length() - max_speed, 0.0)
    if speed_over > 0.0:
        apply_central_impulse(-linear_velocity * speed_over * low_dt_comp)
    if left and not right:
        _apply_side_thrust(thrust_l, flame_l, 1.0)
        thrusters_active = true
    elif right and not left:
        _apply_side_thrust(thrust_r, flame_r, -1.0)
        thrusters_active = true
    elif left and right:
        apply_central_force(global_transform.basis.y * thrust * mass * low_dt_comp)
        _boost_flames()
        thrusters_active = true

func _apply_side_thrust(marker: Node3D, flame: Node3D, dir: float) -> void:
    var f = global_transform.basis.x * thrust * 0.9 * mass * low_dt_comp * dir
    apply_central_force(f)
    flame.modulate.a = clamp(flame.modulate.a + 0.35, 0.0, 1.0)
    _smoke_feedback(marker)

func _fade_thrusters() -> void:
    # random decay like original
    flame_l.modulate.a *= 0.25
    flame_m.modulate.a *= 0.25
    flame_r.modulate.a *= 0.25

func _consume_fuel(delta: float) -> void:
    fuel -= consumption * (delta / Globals.clock_scale) * low_dt_comp
    _ui_update_fuel()

func _auto_align(delta: float) -> void:
    var rot_z = rotation.z
    var ang_z = angular_velocity.z
    var align = clamp(abs(rad_to_deg(rot_z)) / 180.0, 0.0, 1.0) * 250.0
    var sp = clamp(range_lerp(current_speed, 0.25, 0.5, 0.0, 1.0), 0.0, 1.0)
    align *= sp
    apply_torque(Vector3(0, 0, (-rot_z - ang_z)) * align * mass * low_dt_comp)

func _on_body_entered(body: Node) -> void:
    if current_speed < speed_min_damage:
        return
    if shield_enabled:
        return
    var impact = current_speed
    var angle = 1.0
    if body.name == "DeadlySlimeItem":
        _take_slime_damage()
    else:
        _take_damage(impact, angle)

func _take_damage(impact_speed: float, angle_incidence: float) -> void:
    if Time.get_ticks_msec() - hit_timeout < 1000:
        return
    var dmg = clamp(impact_speed, speed_min_damage, speed_max_damage)
    dmg = lerp(min_damage, max_damage, (dmg - speed_min_damage) / (speed_max_damage - speed_min_damage))
    dmg *= angle_incidence
    if dmg > 0.0:
        _body_impact_feedback()
        hit_timeout = Time.get_ticks_msec()
        life -= dmg
        _ui_update_life()

func enable_shield() -> void:
    shield_enabled = true
    shield_mesh.visible = true

func disable_shield() -> void:
    shield_enabled = false
    shield_mesh.visible = false
```

## src/scripts/metal_mine.nut
Role: physics item tethered near the player, nudged by forces.
Godot equivalent: `RigidBody3D` with joints/forces.
```gdscript
extends RigidBody3D
class_name MetalMine

@onready var ship := get_parent().get_node("player")
func _physics_process(delta: float) -> void:
    _apply_balance_force()
```

## src/scripts/minimap.nut
Role: render a minimap texture and update player/artifact icons.
Godot equivalent: `Minimap.gd` on `Control`, using `Viewport` or `Image`.
```gdscript
extends Control
class_name MiniMap

var map_texture: ImageTexture

func update_markers(player_pos: Vector3, artifacts: Array, bonus: Array) -> void:
    # convert world -> map coords and move icons
```

## src/scripts/mobiles_handler.nut
Role: contains multiple "mobile" behavior classes.
Godot equivalent: separate scripts per entity or a shared base class.
Key classes and mapping:
- `MobileBase`: base node with `on_setup`, `on_update`.
- `HomingMine`: state machine (idle/hunt/explode/emit cloud/self delete).
- `SpecialArtifactRotation`: rotation behavior.
- `SimpleRotation`: constant rotation.
- `MeshSelectBasedOnPlatform`: swap mesh on touch platforms.
- `MobileDeadlySlime`: damaging hazard logic.
- `MobileLazerGun`: shoots laser with timers.
- `SeaPlantOscillation`: sinusoidal sway.
- `MobileElevator`: constraints enable/disable + motion.
- `MobileJawGate`: gate motion and collision check.
- `MobileRotary`: rotary moving obstacle.
```gdscript
extends Node3D
class_name HomingMine

enum {IDLE, HUNT, EXPLODE}
var state := IDLE

func _physics_process(delta: float) -> void:
    match state:
        IDLE: _idle(delta)
        HUNT: _hunt(delta)
        EXPLODE: _explode()
```

## src/scripts/particle_emitter.nut
Role: custom particle emitter using duplicated mesh + animation.
Godot equivalent: `GPUParticles3D` or manual spawn + Tween.
```gdscript
extends Node3D
class_name ParticleEmitter

@export var particle_scene: PackedScene
@export var emit_freq := 0.1

func _process(delta: float) -> void:
    if auto_emit and _time_to_emit():
        _emit_particle()
```

## src/scripts/preloader.nut
Role: load a list of meshes while updating a progress bar.
Godot equivalent: loading screen scene + `ResourceLoader.load_threaded_request`.
```gdscript
extends Control
class_name Preloader

var resources := []
var index := 0

func _process(delta: float) -> void:
    if index < resources.size():
        ResourceLoader.load(resources[index])
        index += 1
        _update_progress()
    else:
        SceneFlow.goto_scene("res://scenes/screen_logo.tscn")
```

## src/scripts/project.nut
Role: main project handler, includes script list, setup of globals/save/locale.
Godot equivalent: `ProjectHandler.gd` autoload that extends `SceneFlow`.
```gdscript
extends SceneFlow
class_name ProjectHandler

var player_data := {"total_score": 0, "current_level": 0}
var save_game := SaveGame.new()

func _ready() -> void:
    LocaleManager.select_language_from_system()
    GlobalSave.load()
```

## src/scripts/replay.nut
Role: record positions/rotations to a metafile or text.
Godot equivalent: record to JSON or `.tres` custom resource.
```gdscript
class_name ReplayItemMotion
var frames := []

func record(clock: float, pos: Vector3, rot: Vector3) -> void:
    frames.append({"t": clock, "pos": pos, "rot": rot})
```

## src/scripts/save.nut
Role: save/load player data, persist globals.
Godot equivalent: `SaveGame.gd` using `FileAccess` + JSON.
```gdscript
extends Node
class_name SaveGame

func save_player(data: Dictionary) -> void:
    var f = FileAccess.open(_save_path(), FileAccess.WRITE)
    f.store_string(JSON.stringify(data))

func load_player(defaults: Dictionary) -> Dictionary:
    if not FileAccess.file_exists(_save_path()):
        return defaults
    var f = FileAccess.open(_save_path(), FileAccess.READ)
    return JSON.parse_string(f.get_as_text())
```

## src/scripts/screen_credits.nut
Role: credits screen + UI scrolling + back button.
Godot equivalent: `CreditsScreen.tscn` with `CreditsUI.gd`.
```gdscript
extends Control
class_name CreditsScreen

func _ready() -> void:
    $CreditsUI.populate(credits_table)
```

## src/scripts/screen_game.nut
Role: main gameplay scene controller (level lifecycle, win/lose, pickups).
Godot equivalent: `LevelController.gd` on root of level scene.
```gdscript
extends Node3D
class_name LevelController

var player: PlayerLander
var update_fn: Callable
var timer_table := {}

func _ready() -> void:
    _find_scene_items()
    update_fn = _update_intro

func _process(delta: float) -> void:
    _update_ui()
    if update_fn: update_fn.call()

func _update_game_running() -> void:
    _check_artifacts()
    _check_bonus()
    _check_player_stats()
```

## src/scripts/screen_game_end.nut
Role: end-game credits scrolling with background photos.
Godot equivalent: `GameEndScreen.tscn` with `GameEndUI.gd`.
```gdscript
extends Control
class_name GameEndUI

func _process(delta: float) -> void:
    $ScrollContainer.scroll_vertical += int(delta * 50.0)
```

## src/scripts/screen_game_over.nut
Role: game over screen with timeout and back button.
Godot equivalent: simple Control scene.
```gdscript
extends Control
class_name GameOverScreen

func _ready() -> void:
    await get_tree().create_timer(10.0).timeout
    SceneFlow.goto_scene("res://scenes/screen_title.tscn")
```

## src/scripts/screen_game_restart.nut
Role: immediate restart screen.
Godot equivalent: tiny scene that calls `SceneFlow.goto_scene`.
```gdscript
extends Node
func _ready() -> void:
    ProjectHandler.start_game()
```

## src/scripts/screen_game_ui.nut
Role: in-game HUD, pause menu, gauges, help, touch feedback.
Godot equivalent: `InGameUI.tscn` with `InGameUI.gd`.
```gdscript
extends Control
class_name InGameUI

func update_life(value: float) -> void:
    $LifeBar.value = value

func show_pause() -> void:
    $PauseWindow.show()
    get_tree().paused = true
```

## src/scripts/screen_leaderboard.nut
Role: leaderboard UI + HTTP request + slideshow background.
Godot equivalent: use `HTTPRequest` node + `SlideShow`.
```gdscript
extends Control
class_name LeaderboardScreen

@onready var http := $HTTPRequest

func _ready() -> void:
    http.request("https://example.com/leaderboard")

func _on_request_completed(_result, _code, _headers, body):
    var data = JSON.parse_string(body.get_string_from_utf8())
    $LeaderboardUI.refresh(data)
```

## src/scripts/screen_level_end.nut
Role: level debrief, score computation, story image flow.
Godot equivalent: `LevelEndScreen.gd` driven by state machine.
```gdscript
extends Control
class_name LevelEndScreen

enum {SHOW_STORY, SHOW_SCORE, WAIT}
var state := SHOW_STORY

func _process(delta: float) -> void:
    match state:
        SHOW_STORY: _show_story()
        SHOW_SCORE: _show_score()
```

## src/scripts/screen_level_end_ui.nut
Role: level end UI layout and buttons.
Godot equivalent: `LevelEndUI.tscn`.
```gdscript
extends Control
class_name LevelEndUI

func display_debrief(data: Dictionary) -> void:
    $ScoreLabel.text = str(data.score)
```

## src/scripts/screen_loader.nut
Role: loading overlay with a static logo.
Godot equivalent: simple Control with sprite + optional animation.
```gdscript
extends Control
class_name LoaderScreen
```

## src/scripts/screen_logo.nut
Role: studio logo animation flow (owl -> Astrofra).
Godot equivalent: animation/timeline + state switching.
```gdscript
extends Control
class_name LogoScreen

func _ready() -> void:
    await $OwlAnim.animation_finished
    await $AstrofraAnim.animation_finished
    SceneFlow.goto_scene("res://scenes/screen_title.tscn")
```

## src/scripts/screen_title.nut
Role: title screen behavior, launching game, leaderboard, credits.
Godot equivalent: `TitleScreen.gd` using `TitleUI`.
```gdscript
extends Control
class_name TitleScreen

func start_game() -> void:
    SceneFlow.goto_scene(ProjectHandler.current_level_path())
```

## src/scripts/screen_title_ui.nut
Role: title UI layout (title/options/level select) + animations.
Godot equivalent: three Panels in a `CanvasLayer` with tweened transitions.
```gdscript
extends Control
class_name TitleUI

func scroll_to_options() -> void:
    $Tween.tween_property($Pages, "position:x", -virtual_width, 0.5)
```

## src/scripts/slideshow.nut
Role: 2-sprite cross-fade slideshow with subtle scale/rotation.
Godot equivalent: `SlideShow.gd` swapping textures.
```gdscript
extends Node
class_name SlideShow

var textures: Array[Texture2D]
var time_left := 0.0

func _process(delta: float) -> void:
    time_left -= delta
    if time_left <= 0.0:
        _swap_textures()
```

## src/scripts/stopwatch_handler.nut
Role: stopwatch timer used by gameplay.
Godot equivalent: simple helper class.
```gdscript
class_name Stopwatch
var clock := 0.0
var counting := false

func update(delta: float) -> void:
    if counting: clock += delta
```

## src/scripts/thread_handler.nut
Role: manual coroutine list for threaded behaviors.
Godot equivalent: use `await` and timers instead of custom thread list.
```gdscript
func wait_seconds(s: float) -> void:
    await get_tree().create_timer(s).timeout
```

## src/scripts/ui.nut
Role: UI helpers, custom label class, editable text field, BaseUI, and SFX.
Godot equivalent: replace with Godot UI nodes + reusable scripts.
```gdscript
extends Control
class_name BaseUI

func play_ui_select() -> void:
    AudioManager.play_sound("ui_select")
```

## src/scripts/ui_how_to_control.nut
Role: animated tutorial overlay using coroutine timing.
Godot equivalent: `HowToControl.gd` with AnimationPlayer or Tweens.
```gdscript
extends Control
class_name HowToControl

func play_sequence() -> void:
    $AnimationPlayer.play("how_to_control")
```

## src/scripts/utils.nut
Role: helper functions (hashing, filters, color conversion).
Godot equivalent: utility singleton or static methods.
```gdscript
class_name Utils

static func rgb_to_hsl(c: Color) -> Vector3:
    # implement conversion
    return Vector3(h, s, l)
```

## src/scripts/vfx.nut
Role: simple VFX behaviors (oscillating scale, alpha flicker).
Godot equivalent: attach scripts to nodes.
```gdscript
extends Node3D
class_name GodRayOscillation

@export var amplitude := 1.0
@export var freq := 1.0

func _process(delta: float) -> void:
    # oscillate child scales
```

## src/scripts/weather.nut
Role: ambient/fog settings, simplified for touch platforms.
Godot equivalent: environment tweaks on Level scene.
```gdscript
func apply_ambient(scene: Node3D) -> void:
    var env := $WorldEnvironment.environment
    env.fog_enabled = true
    if Globals.is_touch_platform():
        env.ambient_light_energy = 2.0
```
