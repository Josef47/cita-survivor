extends Node2D

@export var enemy_scene : PackedScene
@export var spawn_interval : float = 2.0
@export var spawn_range : float = 500.0

var timer : Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.connect("timeout", _on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	var enemy = enemy_scene.instantiate()
	var random_x = randf_range(-spawn_range, spawn_range)
	var random_y = randf_range(-spawn_range, spawn_range)
	enemy.global_position = Vector2(random_x, random_y)
	get_tree().current_scene.add_child(enemy)
