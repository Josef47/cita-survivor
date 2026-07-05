class_name Enemy
extends CharacterBody2D

## Basic chaser. Moves toward the player and deals contact damage on a cooldown.
## Death is handled by its HealthComponent: on `died` it awards score and frees.

signal died(enemy: Enemy)

const RADIUS: float = 12.0
@export var move_speed: float = 90.0
@export var contact_damage: float = 10.0
@export var contact_interval: float = 0.6

@onready var health: HealthComponent = $HealthComponent

var _player: Node2D
var _contact_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	_build_body()
	_player = get_tree().get_first_node_in_group("player")
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if health.is_dead() or _player == null or not is_instance_valid(_player):
		return

	var to_player := _player.global_position - global_position
	velocity = to_player.normalized() * move_speed
	move_and_slide()

	_contact_timer = maxf(_contact_timer - delta, 0.0)
	if to_player.length() <= RADIUS + Player.RADIUS + 2.0 and _contact_timer == 0.0:
		if _player.has_method("take_damage"):
			_player.take_damage(contact_damage)
		_contact_timer = contact_interval

func take_damage(amount: float) -> void:
	health.take_damage(amount)
	_flash()

func _on_died() -> void:
	died.emit(self)
	queue_free()

## --- feedback / rendering ---

func _flash() -> void:
	modulate = Color(2.0, 2.0, 2.0)
	var t := create_tween()
	t.tween_property(self, "modulate", Color.WHITE, 0.15)

func _build_body() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	shape.shape = circle
	add_child(shape)

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.9, 0.3, 0.3))
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 24, Color(0.4, 0.1, 0.1), 2.0)
