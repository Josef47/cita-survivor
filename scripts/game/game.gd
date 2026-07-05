extends Node2D

## Top-level game controller. Spawns the player, equips the Meteorite Staff,
## spawns waves of enemies, tracks kills, and drives the death / game-over flow.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")
const STAFF_SCRIPT := preload("res://scripts/items/meteorite_staff.gd")

@export var spawn_interval: float = 1.2
@export var spawn_margin: float = 60.0   ## how far outside the screen enemies appear

var _player: Player
var _kills: int = 0
var _game_over: bool = false

@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _health_bar: ProgressBar = $HUD/HealthBar
@onready var _kills_label: Label = $HUD/KillsLabel
@onready var _game_over_panel: Control = $HUD/GameOverPanel

func _ready() -> void:
	_game_over_panel.visible = false
	_spawn_player()
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.timeout.connect(_spawn_enemy)
	_spawn_timer.start()

func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate()
	_player.global_position = get_viewport_rect().size * 0.5
	_player.died.connect(_on_player_died)
	# Must add to the tree before touching `health` — it's an @onready var that is
	# only assigned once the player node runs _ready().
	add_child(_player)
	_player.health.health_changed.connect(_on_player_health_changed)

	# Equip the Meteorite Staff item.
	var staff := STAFF_SCRIPT.new()
	staff.name = "MeteoriteStaff"
	_player.add_child(staff)

	_health_bar.max_value = _player.health.max_health
	_health_bar.value = _player.health.current_health
	_update_kills()

func _spawn_enemy() -> void:
	if _game_over or _player == null:
		return
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.global_position = _random_edge_position()
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)

## A random point just outside the visible screen, around the player.
func _random_edge_position() -> Vector2:
	var view := get_viewport_rect().size
	var side := randi() % 4
	match side:
		0: return Vector2(randf_range(0, view.x), -spawn_margin)              # top
		1: return Vector2(view.x + spawn_margin, randf_range(0, view.y))      # right
		2: return Vector2(randf_range(0, view.x), view.y + spawn_margin)      # bottom
		_: return Vector2(-spawn_margin, randf_range(0, view.y))             # left

func _on_enemy_died(_enemy: Enemy) -> void:
	_kills += 1
	_update_kills()

func _on_player_health_changed(current: float, _maximum: float) -> void:
	_health_bar.value = current

func _on_player_died() -> void:
	_game_over = true
	_spawn_timer.stop()
	_game_over_panel.visible = true
	($HUD/GameOverPanel/RestartLabel as Label).text = "You died — killed %d enemies\nPress R to restart" % _kills

func _update_kills() -> void:
	_kills_label.text = "Kills: %d" % _kills

func _unhandled_input(event: InputEvent) -> void:
	if _game_over and event is InputEventKey and event.pressed \
			and (event as InputEventKey).physical_keycode == KEY_R:
		get_tree().reload_current_scene()
