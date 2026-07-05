extends CharacterBody2D

var speed = 80
var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
"spawn_interval"
func _physics_process(_delta):
	if player == null:
		return
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	if direction.x > 0:
		$AnimatedSprite2D.play("walk_right")
	else:
		$AnimatedSprite2D.play("walk_left")
