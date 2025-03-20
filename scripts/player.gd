extends CharacterBody2D

const SPEED = 300.0
var is_attacking = false  # ✅ Flaga do śledzenia ataku

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea  # ✅ Pobranie AttackArea

func _ready():
	await get_tree().process_frame  # Poczekaj na pełne załadowanie sceny

	# Ponowne przypisanie dla bezpieczeństwa
	attack_area = get_node_or_null("AttackArea")  

	if not attack_area:
		print("❌ BŁĄD: AttackArea nie znaleziono!")  # Debugowanie
		return
	
	#attack_area.set_deferred("disabled", true)  # ✅ Wyłączamy na starcie
	print("✅ AttackArea znalezione i wyłączone!")

	# Sprawdź i połącz sygnał, tylko jeśli attack_area istnieje
	if not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		attack_area.body_entered.connect(_on_attack_area_body_entered)
		print("🔗 Połączono body_entered!")
	else:
		print("✔️ body_entered już podłączone")


func _physics_process(delta: float) -> void:
	if is_attacking:  # ✅ Jeśli atak trwa, nie zmieniamy animacji!
		return  

	var direction = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if direction != Vector2.ZERO:
		sprite.play("walk")
	else:
		sprite.play("idle")

	if direction.x != 0:
		sprite.flip_h = direction.x < 0

func _input(event):
	if event.is_action_pressed("attack") and not is_attacking:
		attack()

func attack():
	print("🔥 Atak rozpoczęty!")  # Debug
	is_attacking = true  # ✅ Blokada ruchu
	sprite.play("attack")  # ✅ Odtworzenie animacji

	# ✅ Sprawdzamy klatkę animacji, aby aktywować AttackArea
	sprite.frame_changed.connect(_on_animation_frame_changed)

	# ✅ Gdy animacja się skończy, resetujemy atak
	sprite.animation_finished.connect(_on_attack_finished)


func _on_animation_frame_changed():
	if sprite.animation == "attack" and sprite.frame == 3:
		attack_area.set_deferred("disabled", false)
		print("⚔️ AttackArea AKTYWNE!")
		
		await get_tree().create_timer(0.3).timeout  # Czekamy 0.1s, aby wykryć kolizję
		
		check_attack_collision()
		attack_area.set_deferred("disabled", true)
		print("❌ AttackArea WYŁĄCZONE!")

func _on_attack_area_body_entered(body):
	print("🚀 Wykryto obiekt w AttackArea:", body.name)
	if body.is_in_group("enemies"):
		print("✅ Obiekt", body.name, "jest w grupie enemies!")
	else:
		print("❌ UWAGA! Obiekt", body.name, "NIE JEST w grupie enemies!")  # Sprawdzenie, czy jakikolwiek obiekt jest wykrywany
	if is_attacking and body.is_in_group("enemies"):  # ✅ Sprawdzamy, czy gracz atakuje i czy to przeciwnik
		print("💥 Trafiono przeciwnika:", body.name)  # Debug
		body.die()  # ✅ Usuwamy przeciwnika

func check_attack_collision():
	var overlapping_bodies = attack_area.get_overlapping_bodies()
	print("🔎 Sprawdzam kolizję: znaleziono", overlapping_bodies.size(), "obiektów!")
	
	for body in overlapping_bodies:
		print("🛑 Kolizja z:", body.name)
		
		if is_attacking and body.is_in_group("enemies"):
			print("💥 Trafiono przeciwnika:", body.name)
			body.die()

func _on_attack_finished():
	if sprite.animation == "attack":
		attack_area.set_deferred("disabled", true)  # ✅ Dezaktywujemy AttackArea
		is_attacking = false  # ✅ Gracz może ponownie zaatakować
		print("❌ AttackArea WYŁĄCZONE!")  # Debug

	# ✅ Odłączamy sygnały, aby nie spamowały po zakończeniu ataku
	sprite.frame_changed.disconnect(_on_animation_frame_changed)
	sprite.animation_finished.disconnect(_on_attack_finished)
