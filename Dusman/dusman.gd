extends Area2D

# Canavarın Özellikleri
var max_can: float = 100.0
var mevcut_can: float = 100.0
var hareket_hizi: float = 120.0
var temas_hasari: float = 10.0

# --- SÜREKLİ HASAR İÇİN SÜRE AYARLARI ---
var hasar_sikligi: float = 1.0 # Karakter canavarın içindeyken kaç saniyede bir hasar alsın?
var hasar_zamanlayici: float = 0.0 # Süreyi geriye doğru sayacak değişken

# Öldüğünde içinden çıkacak XP sahnesi
const XP_PARCASI_SAHNESI = preload("res://Xp_ve_Can/xp_parcasi.tscn")

func _ready():
	# Canavarı otomatik olarak "dusmanlar" grubuna ekliyoruz
	add_to_group("dusmanlar")
	# NOT: body_entered bağlantısını sildik, çünkü artık takibi her karede canlı yapacağız.

func _process(delta):
	# Oyuncuyu haritadaki "oyuncu" grubundan otomatik olarak buluyoruz
	var oyuncu = get_tree().get_first_node_in_group("oyuncu")
	
	if oyuncu:
		# Oyuncuya doğru hareket etme mantığı (Senin yazdığın kısım)
		var yon = global_position.direction_to(oyuncu.global_position)
		global_position += yon * hareket_hizi * delta
		
	# --- SÜREKLİ HASAR SİSTEMİ ---
	# Eğer zamanlayıcı çalışıyorsa süreyi geri sayıyoruz
	if hasar_zamanlayici > 0:
		hasar_zamanlayici -= delta
		
	# Süre dolduysa (veya sıfırsa) hasar verme kontrolü yapıyoruz
	if hasar_zamanlayici <= 0:
		# Canavarın (Area2D) içinde o an bulunan tüm fiziksel bedenleri alıyoruz
		var icerdeki_bedenler = get_overlapping_bodies()
		
		for beden in icerdeki_bedenler:
			# Eğer içerideki nesne oyuncuysa (hasar_al fonksiyonu varsa ve oyuncu grubundaysa)
			if beden.has_method("hasar_al") and beden.is_in_group("oyuncu"):
				beden.hasar_al(temas_hasari) # Oyuncuya hasar ver
				hasar_zamanlayici = hasar_sikligi # Zamanlayıcıyı yeniden 1 saniyeye kur
				break # Oyuncuyu bulup vurduğumuz için döngüyü sonlandır

# Oyuncu bize vurduğunda bu fonksiyon çalışacak
func hasar_al(miktar: float):
	mevcut_can -= miktar
	print("Canavar hasar aldı! Kalan Can: ", mevcut_can)
	
	if mevcut_can <= 0:
		ol()

func ol():
	print("Canavar öldü! XP düşüyor...")
	
	var dusen_xp = XP_PARCASI_SAHNESI.instantiate()
	dusen_xp.global_position = global_position
	
	get_parent().call_deferred("add_child", dusen_xp)
	queue_free()
