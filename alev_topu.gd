extends Area2D

@export var speed = 100
var direction = Vector2.ZERO

func _physics_process(delta):
	# Alev topunu belirlenen yöne doğru hareket ettir
	position += direction * speed * delta
	
	
	
