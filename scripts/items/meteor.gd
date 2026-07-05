class_name Meteor
extends Node2D

## A single falling meteor spawned by the Meteorite Staff.
## It drops from above onto `impact_position`, then damages every enemy inside
## `blast_radius` (a circle) and plays an expanding shockwave before freeing.

const FALL_HEIGHT: float = 420.0
const FALL_TIME: float = 0.55

var impact_position: Vector2
var damage: float = 40.0
var blast_radius: float = 120.0

var _rock_offset: Vector2 = Vector2(0, -FALL_HEIGHT)  # animates to zero on landing
var _shock_alpha: float = 0.0
var _shock_scale: float = 0.0
var _landed: bool = false

func setup(target: Vector2, dmg: float, radius: float) -> void:
	impact_position = target
	damage = dmg
	blast_radius = radius

func _ready() -> void:
	global_position = impact_position
	var t := create_tween()
	# Ease-in so it accelerates like a falling rock.
	t.tween_property(self, "_rock_offset", Vector2.ZERO, FALL_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(_impact)
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func _impact() -> void:
	_landed = true
	_apply_area_damage()
	_play_shockwave()

## Circular area-of-effect: hit every live enemy whose center is within radius.
func _apply_area_damage() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(impact_position) <= blast_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

func _play_shockwave() -> void:
	_shock_alpha = 0.8
	_shock_scale = 0.15
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "_shock_scale", 1.0, 0.35).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "_shock_alpha", 0.0, 0.35)
	t.chain().tween_callback(queue_free)

func _draw() -> void:
	if not _landed:
		# The falling rock plus a small target marker on the ground.
		draw_arc(Vector2.ZERO, blast_radius, 0.0, TAU, 48, Color(1.0, 0.5, 0.1, 0.35), 2.0)
		var rock_pos := _rock_offset
		draw_circle(rock_pos, 10.0, Color(0.6, 0.35, 0.2))
		draw_circle(rock_pos, 6.0, Color(1.0, 0.6, 0.2))
	else:
		# Expanding shockwave ring.
		var ring := Color(1.0, 0.6, 0.15, _shock_alpha)
		draw_arc(Vector2.ZERO, blast_radius * _shock_scale, 0.0, TAU, 48, ring, 6.0)
		draw_circle(Vector2.ZERO, blast_radius * _shock_scale * 0.4, Color(1.0, 0.8, 0.3, _shock_alpha * 0.5))
