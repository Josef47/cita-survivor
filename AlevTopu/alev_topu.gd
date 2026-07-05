extends Area2D

var hareket_hizi: float = 500.0
var yon: Vector2 = Vector2.RIGHT # Oyuncudan bu yönü alacağız
var hasar_miktari: float = 25.0

func _ready():
	# Canavar da Area2D olduğu için 'area_entered' (alana girdi) sinyalini bağlıyoruz
	area_entered.connect(_on_area_entered)
	
	# Eğer hiçbir şeye çarpmazsa 3 saniye sonra havada yok olsun (Hafıza temizliği)
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _process(delta):
	# Alev topunu belirlenen yöne doğru sürekli ilerlet
	global_position += yon * hareket_hizi * delta

func _on_area_entered(area):
	# Çarptığımız alan "dusmanlar" grubundaysa ve hasar_al fonksiyonu varsa
	if area.is_in_group("dusmanlar") and area.has_method("hasar_al"):
		area.hasar_al(hasar_miktari) # Canavara hasar ver
		queue_free() # Alev topunu yok et
