extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -200.0

func _physics_process(delta: float) -> void:
	if is_instance_valid(player) and not is_dead:
		# Obracanie przeciwnika w stronę gracza
		$AnimatedSprite2D.flip_h = player.global_position.x < global_position.x
		
		var collision_shape = get_node_or_null("CollisionShape2D")
		if collision_shape:
			collision_shape.scale.x = -1 if $AnimatedSprite2D.flip_h else 1  

		# Obliczanie kierunku w osi X i Y
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed

	move_and_slide()
	play_animation()  # ✅ Wywołanie funkcji animacji po ruchu 

@export var player: Node2D  # Można przypisać ręcznie, ale znajdziemy automatycznie
@export var jump_threshold: float = 50.0  # Minimalna różnica wysokości, przy której przeciwnik skoczy
@export var speed: float = 100.0  # Prędkość ruchu przeciwnika
@export var xp_reward: int = 10  #  Ile XP gracz dostanie po zabiciu przeciwnika
var is_dead = false  # 🔹 Flaga, żeby przeciwnik nie dodał XP kilka razy

func _ready():
	add_to_group("enemies")
	print("👾 Przeciwnik", name, "dodany do grupy enemies!")
	print("🔍 Warstwa przeciwnika:", collision_layer, " Maska:", collision_mask)  # Debugowanie
	
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
		collision_shape.set_deferred("one_way_collision", false)  # ✅ Upewnij się, że nie ma jednokierunkowej kolizji
		print("🛠️ CollisionShape2D aktywowany jako dynamiczne ciało!")

	var viewport_rect = get_viewport_rect()
	if not viewport_rect.has_point(global_position):
		print("⚠️ Przeciwnik spawnowany poza ekranem!")
	
	$AnimatedSprite2D.z_index = 10  # ✅ Przeciwnicy będą wyżej niż tło
	print("🎭 z_index ustawiony na:", $AnimatedSprite2D.z_index)
	
	if player == null:  # Jeśli nie przypisano w Inspectorze
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			print("BŁĄD: Nie znaleziono gracza!")

func _process(delta):
	if is_instance_valid(player) and not is_dead:
		# Obracanie przeciwnika w stronę gracza
		$AnimatedSprite2D.flip_h = player.global_position.x < global_position.x
		
		var collision_shape = get_node_or_null("CollisionShape2D")
		if collision_shape:
			collision_shape.scale.x = -1 if $AnimatedSprite2D.flip_h else 1  

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func die():
	print("💀 Przeciwnik", name, "został zabity!")  # Debug
	if is_dead:
		return  # Zapobiega wielokrotnemu dodaniu XP
	is_dead = true  # Ustaw flagę przed dodaniem XP
	if player:
		print("🎖️ Dodawanie XP:", xp_reward)
		player.add_experience(xp_reward)  # Gracz dostaje XP
		queue_free()  # Usunięcie przeciwnika

func play_animation():
	if velocity.length() > 1:  # Jeśli przeciwnik się porusza
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")  # Jeśli przeciwnik stoi, odtwarzaj animację idle
