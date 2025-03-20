extends Node2D

@export var enemy_scene: PackedScene  # Scena przeciwnika
@export var spawn_positions: Array[Node2D]  # Lista miejsc spawnów
@export var max_enemies: int = 10  # Maksymalna liczba przeciwników

@onready var spawn_timer: Timer = $SpawnTimer  # Pobranie referencji do timera
var current_enemy_count: int = 0  # Licznik przeciwników

func _ready():
	print("Czy _on_SpawnTimer_timeout istnieje?", has_method("_on_SpawnTimer_timeout"))
	print("spawn_timer:", spawn_timer)
	print("Czy spawn_timer istnieje?", spawn_timer != null)
	print("Czy spawn_timer jest Timerem?", spawn_timer is Timer)
	print("Czy spawn_timer ma sygnał timeout?", spawn_timer.has_signal("timeout"))
	print("📏 Rozmiar viewportu:", get_viewport().size)
	print("🖥️ Granice viewportu:", get_viewport_rect())

	await get_tree().process_frame  # ✅ Czekamy na załadowanie sceny

	if not spawn_timer.timeout.is_connected(_on_SpawnTimer_timeout):
		print("✅ Timeout jeszcze nie był podłączony, podłączam...")
		spawn_timer.timeout.connect(_on_SpawnTimer_timeout)
	else:
		print("❗ Timeout już był podłączony, nie podłączam ponownie.")

	start_spawn_timer()

func start_spawn_timer():
	spawn_timer.wait_time = randf_range(0.2, 1.0)  # Losowy czas (0.2s - 1s)
	spawn_timer.start()
	print("🎯 Timer wystartował! Czas:", spawn_timer.wait_time)

func _on_SpawnTimer_timeout():
	print("✅ Timeout zadziałał!")  # 🔥 Debugowanie
	spawn_enemy()
	start_spawn_timer()

func spawn_enemy():
	print("Spawning enemy!")  # Debugowanie

	if current_enemy_count >= max_enemies:
		print("❌ Limit przeciwników osiągnięty!")
		return  

	if spawn_positions.is_empty():
		print("Błąd: Brak pozycji spawnów!")
		return

	var spawn_position = spawn_positions[randi() % spawn_positions.size()]
	var enemy = enemy_scene.instantiate()

	# ✅ Pobieramy rozmiar ekranu
	var viewport_rect = get_viewport_rect()
	
	# ✅ Upewniamy się, że przeciwnik jest wewnątrz ekranu
	enemy.global_position.x = clamp(spawn_position.global_position.x, viewport_rect.position.x + 50, viewport_rect.end.x - 50)
	enemy.global_position.y = clamp(spawn_position.global_position.y, viewport_rect.position.y + 50, viewport_rect.end.y - 50)

	add_child(enemy)

	print("📍 Przeciwnik dodany na pozycji:", enemy.global_position)

	current_enemy_count += 1

	enemy.tree_exited.connect(func(): 
		current_enemy_count -= 1
	
	
	)
func _draw():
	for spawn in spawn_positions:
		if spawn:  # Upewniamy się, że spawn_position istnieje
			draw_rect(Rect2(spawn.global_position - Vector2(5, 5), Vector2(10, 10)), Color(1, 0, 0, 1))
