class_name Enemy
extends CharacterBody2D

## Basic chaser. Moves toward the player, deals contact damage on a cooldown,
## and drops an XP orb when it dies. Death is handled by its HealthComponent:
## on `died` it drops loot, awards score and frees.

signal died(enemy: Enemy)

const RADIUS: float = 12.0
const XP_ORB_SCENE: PackedScene = preload("res://scenes/xp_orb.tscn")

@export var move_speed: float = 90.0
@export var contact_damage: float = 10.0
@export var contact_interval: float = 0.6

@onready var health: HealthComponent = $HealthComponent
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _player: Node2D
var _contact_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	_player = get_tree().get_first_node_in_group("player")
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if health.is_dead() or _player == null or not is_instance_valid(_player):
		return

	var to_player := _player.global_position - global_position
	velocity = to_player.normalized() * move_speed
	move_and_slide()

	var anim := "walk_right" if to_player.x >= 0.0 else "walk_left"
	if _sprite.animation != anim:
		_sprite.play(anim)

	_contact_timer = maxf(_contact_timer - delta, 0.0)
	if to_player.length() <= RADIUS + Player.RADIUS + 2.0 and _contact_timer == 0.0:
		if _player.has_method("take_damage"):
			_player.take_damage(contact_damage)
		_contact_timer = contact_interval

func take_damage(amount: float) -> void:
	health.take_damage(amount)
	_flash()

func _on_died() -> void:
	_drop_xp()
	died.emit(self)
	queue_free()

func _drop_xp() -> void:
	var orb := XP_ORB_SCENE.instantiate()
	orb.global_position = global_position
	get_tree().current_scene.add_child(orb)

## --- feedback ---

func _flash() -> void:
	modulate = Color(2.0, 2.0, 2.0)
	var t := create_tween()
	t.tween_property(self, "modulate", Color.WHITE, 0.15)
