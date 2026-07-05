extends Area2D

# Dikenin ne kadar hasar vereceğini buradan değiştirebilirsin
@export var hasar_miktari: float = 20.0 

func _ready():
	# Bir nesne dikene çarptığında çalışacak fonksiyonu bağlıyoruz
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Eğer dikene çarpan nesnenin içinde "hasar_al" fonksiyonu varsa (yani oyuncuysa)
	if body.has_method("hasar_al"):
		body.hasar_al(hasar_miktari) # Oyuncuya hasar ver
