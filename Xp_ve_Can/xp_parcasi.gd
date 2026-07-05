extends Area2D

# Bu parçayı toplayınca oyuncuya kaç XP verileceğini buradan ayarlayabilirsin
@export var xp_degeri: float = 35.0 

func _ready():
	# Bir nesne bu alana girdiğinde çalışacak fonksiyonu bağlıyoruz
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Eğer çarpan nesnenin içinde "xp_ekle" adında bir fonksiyon varsa (yani oyuncuysa)
	if body.has_method("xp_ekle"):
		body.xp_ekle(xp_degeri) # Oyuncuya XP'yi ver
		queue_free() # Parçayı haritadan sil (toplanmış oldu)
