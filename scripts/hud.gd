extends CanvasLayer

var survival_time: int = 0
var max_survived_time: int = 0

@onready var exp_bar = $ExpBar
@onready var level_label = $LevelLabel
@onready var health_bar = $HealthBar


# 🔹 Wczytanie rekordu przy starcie gry
func _ready():
	load_max_survived_time()

# 🔹 Aktualizacja EXP paska
func update_exp(exp: float, threshold: float) -> void:
	exp_bar.max_value = threshold
	exp_bar.value = exp

# 🔹 Aktualizacja poziomu
func update_level(level: int) -> void:
	level_label.text = "Poziom " + str(level)

func update_health(current: int, max: int) -> void:
	health_bar.max_value = max
	health_bar.value = current


# 🔹 Wywołaj tę funkcję, gdy gracz umrze
func on_player_death():
	print("on_player_death() wywołane!")

	if has_node("SurvivalTimer"):
		var timer = get_node("SurvivalTimer")
		timer.stop()
		print("Timer zatrzymany!")  
	else:
		print("BŁĄD: SurvivalTimer nie znaleziony w HUD!")

	print("Poprzedni rekord:", max_survived_time, "Aktualny czas przetrwania:", survival_time)
	
	if survival_time > max_survived_time:
		max_survived_time = survival_time
		save_max_survived_time()
		print("🎉 Nowy rekord: ", max_survived_time)
	else:
		print("Nie pobito rekordu, czas przetrwania:", survival_time, " Rekord:", max_survived_time)

	var game_over_screen = get_node_or_null("/root/Game/GameOver")
	if game_over_screen:
		game_over_screen.show()
		print("Game Over pokazany!")  
	else:
		print("BŁĄD: Game Over nie znaleziony w drzewie scen!")

# 🔹 Zapis rekordu
func save_max_survived_time():
	var file = FileAccess.open("user://game_data.cfg", FileAccess.WRITE)
	if file:
		file.store_string(str(max_survived_time))
		print("Rekord zapisany:", max_survived_time)
	else:
		print("BŁĄD: Nie udało się zapisać rekordu!")

# 🔹 Wczytanie rekordu
func load_max_survived_time():
	if FileAccess.file_exists("user://game_data.cfg"):
		var file = FileAccess.open("user://game_data.cfg", FileAccess.READ)
		if file:
			max_survived_time = int(file.get_as_text().strip_edges())
			print("Załadowano rekord:", max_survived_time)
		else:
			print("BŁĄD: Nie udało się otworzyć pliku do odczytu!")
	else:
		print("Brak zapisanego rekordu, ustawiono 0")
