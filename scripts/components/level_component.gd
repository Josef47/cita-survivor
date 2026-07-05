class_name LevelComponent
extends Node

## Reusable experience / leveling system, built to mirror HealthComponent.
## Attach as a child of any entity that gains XP. The owner listens to
## `leveled_up` to decide what a level-up means for it (heal, buff, etc.).

signal xp_changed(current: float, required: float)
signal leveled_up(new_level: int)

@export var base_xp: float = 100.0
## Each level requires `growth` times more XP than the previous one.
@export var growth: float = 1.3

var level: int = 1
var current_xp: float = 0.0
var xp_to_next: float = 100.0

func _ready() -> void:
	xp_to_next = base_xp
	xp_changed.emit(current_xp, xp_to_next)

func add_xp(amount: float) -> void:
	if amount <= 0.0:
		return
	current_xp += amount
	# A single orb might grant several levels at once.
	while current_xp >= xp_to_next:
		current_xp -= xp_to_next
		_level_up()
	xp_changed.emit(current_xp, xp_to_next)

func _level_up() -> void:
	level += 1
	xp_to_next = ceilf(xp_to_next * growth)
	leveled_up.emit(level)
