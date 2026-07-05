extends Area2D

## A fireball thrown by the player. Flies in a straight line, damages the first
## enemy it touches, then despawns. Also despawns on its own after `lifetime`
## seconds so stray shots don't pile up.

@export var speed: float = 320.0
@export var damage: float = 25.0
@export var lifetime: float = 2.0

## Set by whoever spawns the fireball, before adding it to the tree.
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
