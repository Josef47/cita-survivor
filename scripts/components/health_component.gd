class_name HealthComponent
extends Node

## Reusable health + death system.
## Attach as a child of any entity (player, enemy). The owner listens to the
## `died` signal to decide what "death" means for it (game over, drop loot, free).

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal healed(amount: float)
signal died

@export var max_health: float = 100.0
## When true, once dead any further damage is ignored (prevents double-death).
var _is_dead: bool = false

var current_health: float

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(amount: float) -> void:
	if _is_dead or amount <= 0.0:
		return
	current_health = maxf(current_health - amount, 0.0)
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		_die()

func heal(amount: float) -> void:
	if _is_dead or amount <= 0.0:
		return
	current_health = minf(current_health + amount, max_health)
	healed.emit(amount)
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return _is_dead

func get_health_ratio() -> float:
	return current_health / max_health if max_health > 0.0 else 0.0

func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	died.emit()
