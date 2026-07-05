class_name Player
extends CharacterBody2D

## Player avatar (the witch). Owns a HealthComponent and a LevelComponent, moves
## with WASD, plays directional animations, and throws fireballs toward the mouse
## on the "fire" action. Death is reported upward so the game shows a game-over.

signal died

const RADIUS: float = 16.0
const FIREBALL_SCENE: PackedScene = preload("res://scenes/fireball.tscn")

@export var move_speed: float = 220.0

@onready var health: HealthComponent = $HealthComponent
@onready var level: LevelComponent = $LevelComponent
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	health.died.connect(_on_died)
	level.leveled_up.connect(_on_leveled_up)

func _physics_process(_delta: float) -> void:
	if health.is_dead():
		return
	var dir := Input.get_vector("go_left", "go_right", "go_up", "go_down")
	velocity = dir * move_speed
	move_and_slide()
	_animate(dir)

func _unhandled_input(event: InputEvent) -> void:
	if not health.is_dead() and event.is_action_pressed("fire"):
		_fire()

## Choose a directional animation from the movement vector (vertical wins ties).
func _animate(dir: Vector2) -> void:
	var anim := "idle_animation"
	if dir != Vector2.ZERO:
		if absf(dir.y) >= absf(dir.x):
			anim = "go_up_animation" if dir.y < 0.0 else "go_down_animation"
			_sprite.flip_h = false
		else:
			anim = "go_right_animation"
			_sprite.flip_h = dir.x < 0.0
	if _sprite.animation != anim:
		_sprite.play(anim)

func _fire() -> void:
	var fireball := FIREBALL_SCENE.instantiate()
	fireball.direction = (get_global_mouse_position() - global_position).normalized()
	fireball.global_position = global_position
	# Live in world space so it keeps flying as the player moves.
	get_tree().current_scene.add_child(fireball)

func take_damage(amount: float) -> void:
	health.take_damage(amount)

func add_xp(amount: float) -> void:
	level.add_xp(amount)

## Reward for leveling up: refill health.
func _on_leveled_up(_new_level: int) -> void:
	health.heal(health.max_health)

func _on_died() -> void:
	died.emit()
