class_name Player
extends CharacterBody2D

## Player avatar. Owns a HealthComponent and reports its own death upward so the
## game can show a game-over screen. Visuals are drawn in code (no art assets yet).

signal died

const RADIUS: float = 16.0
@export var move_speed: float = 220.0

@onready var health: HealthComponent = $HealthComponent

func _ready() -> void:
	add_to_group("player")
	_build_body()
	health.died.connect(_on_died)

func _physics_process(_delta: float) -> void:
	if health.is_dead():
		return
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right") + _key_axis(KEY_A, KEY_D),
		Input.get_axis("ui_up", "ui_down") + _key_axis(KEY_W, KEY_S)
	)
	velocity = dir.limit_length(1.0) * move_speed
	move_and_slide()

## WASD support without touching the InputMap. Returns -1/0/+1.
func _key_axis(neg: Key, pos: Key) -> float:
	return float(Input.is_physical_key_pressed(pos)) - float(Input.is_physical_key_pressed(neg))

func take_damage(amount: float) -> void:
	health.take_damage(amount)
	queue_redraw()

func _on_died() -> void:
	queue_redraw()
	died.emit()

## --- rendering / physics body built in code ---

func _build_body() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	add_child(shape)

func _draw() -> void:
	var color := Color(0.35, 0.75, 1.0) if not health.is_dead() else Color(0.4, 0.4, 0.4)
	draw_circle(Vector2.ZERO, RADIUS, color)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 32, Color.WHITE, 2.0)
