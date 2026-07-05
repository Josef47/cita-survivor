extends CharacterBody2D

# Alev topu sahnesini sürükleyip bırakabileceğimiz bir yer açıyoruz
@export var alev_sahnesi: PackedScene 

func _unhandled_input(event):
	# Mouse sol tık algılandığında (Input Map'te 'fire' olarak tanımla)
	if event.is_action_pressed("fire"):
		ates_et()

func ates_et():
	# 1. Alev topunu oluştur
	var alev = alev_sahnesi.instantiate()
	
	# 2. Sahneye ekle (Karakterin olduğu yere)
	get_parent().add_child(alev)
	alev.global_position = global_position
	
	# 3. Yönü hesapla (Mouse'un olduğu yöne doğru)
	var mouse_pos = get_global_mouse_position()
	alev.direction = (mouse_pos - global_position).normalized()


var harekethizi = 200.0

func _physics_process(_delta: float) -> void:
	
	var direction = Input.get_vector("go_left", "go_right", "go_up", "go_down")
	
	velocity = direction * harekethizi
	
	
	if direction.length() > 0:
		
	
		# Önce Yukarı/Aşağı hareketini kontrol et (W tuşu)
		if direction.y < 0: 
			if $AnimatedSprite2D.animation != "go_up_animation":
				$AnimatedSprite2D.play("go_up_animation")
			$AnimatedSprite2D.flip_h = false # Yukarı bakarken çevirme
		
		elif direction.y > 0:
			if $AnimatedSprite2D.animation != "go_down_animation":
				$AnimatedSprite2D.play("go_down_animation")
			$AnimatedSprite2D.flip_h = false
			
		# Eğer yukarı gitmiyorsa (else if), o zaman sağa/sola bak
		elif direction.x != 0:
			$AnimatedSprite2D.play("go_right_animation")
			
			if direction.x < 0:
				$AnimatedSprite2D.flip_h = true  # Sola basıyorsan ters çevir
			else:
				$AnimatedSprite2D.flip_h = false # Sağa basıyorsan düz tut
		

	else:
	
		if $AnimatedSprite2D.animation != "idle_animation":
			$AnimatedSprite2D.play("idle_animation")
 
	move_and_slide()
