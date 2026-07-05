extends CharacterBody2D

const ALEV_TOPU_SAHNESI = preload("res://AlevTopu/alev_topu.tscn")

# --- CAN VE XP DEĞİŞKENLERİ ---
var max_can: float = 100.0
var mevcut_can: float = 100.0

var seviye: int = 1
var mevcut_xp: float = 0.0
var gerekli_xp: float = 100.0


# --- ARAYÜZ BAĞLANTILARI ---
@onready var can_bari = %CanBari
@onready var xp_bari = %XpBari
@onready var seviye_yazisi = %SeviyeYazisi

func _ready():
	# Canavarın bizi haritada bulabilmesi için kendimizi "oyuncu" grubuna ekliyoruz
	add_to_group("oyuncu")
	arayuzu_guncelle()

func _physics_process(delta):
	# Hareket Kontrolü
	var yon = Input.get_vector("Go_left", "Go_right", "Go_up", "Go_down")
	velocity = yon * 250.0
	move_and_slide()
	
	# YENİ KONTROL: Az önce Input Map'e eklediğimiz sol tık aksiyonunu kontrol ediyoruz
	if Input.is_action_just_pressed("Ates_etmek"):
		ates_et()

	# YENİ KONTROL: Az önce Input Map'e eklediğimiz sol tık aksiyonunu kontrol ediyoruz

func ates_et():
	
	print ("Ates Edildi")
	
	# Alev topu nesnesini oluştur
	var yeni_alev_topu = ALEV_TOPU_SAHNESI.instantiate()
	
	# Çıkış noktasını oyuncunun tam merkezi yap
	yeni_alev_topu.global_position = global_position
	
	# --- FARE HEDEFLEME MEKANİĞİ ---
	var fare_pozisyonu = get_global_mouse_position()
	var firlatma_yonu = global_position.direction_to(fare_pozisyonu).normalized()
	
	yeni_alev_topu.yon = firlatma_yonu
	yeni_alev_topu.rotation = firlatma_yonu.angle()
	
	# Alev topunu haritaya ekle
	get_parent().add_child(yeni_alev_topu)
	
# --- SİSTEM FONKSİYONLARI ---

func hasar_al(miktar: float):
	mevcut_can -= miktar
	mevcut_can = clamp(mevcut_can, 0, max_can)
	arayuzu_guncelle()
	if mevcut_can <= 0:
		get_tree().reload_current_scene() # Ölünce restart at

func xp_ekle(miktar: float):
	mevcut_xp += miktar
	while mevcut_xp >= gerekli_xp:
		mevcut_xp -= gerekli_xp
		seviye_atla()
	arayuzu_guncelle()

func seviye_atla():
	seviye += 1
	gerekli_xp = gerekli_xp * 1.3
	mevcut_can = max_can # Seviye atlayınca canı fulle
	print("Yeni Seviye: ", seviye)

func arayuzu_guncelle():
	if can_bari: can_bari.value = mevcut_can
	if xp_bari: 
		xp_bari.max_value = gerekli_xp
		xp_bari.value = mevcut_xp
	if seviye_yazisi: seviye_yazisi.text = "Seviye: " + str(seviye)
