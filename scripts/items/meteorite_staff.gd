class_name MeteoriteStaff
extends Node2D

## Item: "Meteorite Staff".
## An automatic weapon. On a fixed interval it calls down meteors that strike
## random locations (biased toward where enemies are) and deal circular AoE damage.
##
## Attach as a child of the player (or anything with global_position). Meteors are
## added to the current scene so they live in world space, not local to the staff.

const ITEM_NAME: String = "Meteorite Staff"
const METEOR_SCENE: PackedScene = preload("res://scenes/meteor.tscn")

@export var cast_interval: float = 3.0   ## seconds between volleys
@export var meteors_per_cast: int = 1     ## how many meteors each volley
@export var damage: float = 40.0
@export var blast_radius: float = 120.0
@export var scatter: float = 60.0         ## random offset around the chosen target
## Radius around the player used to pick a random point when no enemies exist.
@export var idle_range: float = 220.0

var _timer: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_timer = cast_interval

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = cast_interval
		_cast()

func _cast() -> void:
	for i in meteors_per_cast:
		_spawn_meteor(_pick_target())

## Prefer a random enemy's position; fall back to a random point near the player.
func _pick_target() -> Vector2:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var base: Vector2
	if enemies.size() > 0:
		var target: Node2D = enemies[_rng.randi_range(0, enemies.size() - 1)]
		base = target.global_position
	else:
		var angle := _rng.randf_range(0.0, TAU)
		var dist := _rng.randf_range(0.0, idle_range)
		base = global_position + Vector2.RIGHT.rotated(angle) * dist

	# Add scatter so repeated casts don't stack on the exact same spot.
	var jitter := Vector2(
		_rng.randf_range(-scatter, scatter),
		_rng.randf_range(-scatter, scatter)
	)
	return base + jitter

func _spawn_meteor(target: Vector2) -> void:
	var meteor: Meteor = METEOR_SCENE.instantiate()
	meteor.setup(target, damage, blast_radius)
	# Add to the scene root so the meteor is independent of the moving player.
	get_tree().current_scene.add_child(meteor)
