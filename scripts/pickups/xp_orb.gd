extends Area2D

## An XP drop left behind by a dead enemy. Grants XP to the player on touch.
## Drawn in code (a small green gem) so it needs no art asset.

@export var xp_value: float = 25.0

const RADIUS: float = 6.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("add_xp"):
		body.add_xp(xp_value)
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.3, 0.9, 0.5))
	draw_circle(Vector2.ZERO, RADIUS * 0.5, Color(0.85, 1.0, 0.9))
