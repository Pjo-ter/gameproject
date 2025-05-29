extends Node2D

@export var enemy_scene: PackedScene  # Scena przeciwnika
@export var spawn_positions: Array[Node2D]  # Lista miejsc spawnów
@export var max_enemies: int = 10  # Maksymalna liczba przeciwników

@onready var spawn_timer: Timer = $SpawnTimer
var current_enemy_count: int = 0
var player: Node2D = null

func _ready():
	print("📏 Rozmiar viewportu:", get_viewport().size)
	print("🖥️ Granice viewportu:", get_viewport_rect())

	await get_tree().process_frame
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is CharacterBody2D:
			player = candidate
			break

	if player == null:
		print("❌ Nie znaleziono gracza w grupie 'player'!")

	# Test spójności listy spawnów
	for pos in spawn_positions:
		if pos == null:
			print("⚠️ spawn_positions zawiera null!")

	if not spawn_timer.timeout.is_connected(_on_SpawnTimer_timeout):
		spawn_timer.timeout.connect(_on_SpawnTimer_timeout)

	start_spawn_timer()

func start_spawn_timer():
	spawn_timer.wait_time = randf_range(0.2, 1.0)
	spawn_timer.start()
	print("🎯 Timer wystartował! Czas:", spawn_timer.wait_time)

func _on_SpawnTimer_timeout():
	print("✅ Timeout zadziałał!")
	spawn_enemy()
	start_spawn_timer()

func spawn_enemy():
	print("Spawning enemy!")

	if current_enemy_count >= max_enemies:
		print("❌ Limit przeciwników osiągnięty!")
		return

	if spawn_positions.is_empty():
		print("❌ Brak pozycji spawnów!")
		return

	var spawn_position = spawn_positions[randi() % spawn_positions.size()]
	if spawn_position == null:
		print("❌ spawn_position == null! Pomijam generowanie przeciwnika.")
		return

	var enemy = enemy_scene.instantiate()
	var viewport_rect = get_viewport_rect()

	enemy.global_position.x = clamp(spawn_position.global_position.x, viewport_rect.position.x + 50, viewport_rect.end.x - 50)
	enemy.global_position.y = clamp(spawn_position.global_position.y, viewport_rect.position.y + 50, viewport_rect.end.y - 50)

	if player != null and enemy.has_method("set_target"):
		enemy.set_target(player)

	add_child(enemy)
	print("📍 Przeciwnik dodany na pozycji:", enemy.global_position)

	current_enemy_count += 1

	enemy.tree_exited.connect(func():
		current_enemy_count -= 1
	)
