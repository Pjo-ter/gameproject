extends CanvasLayer

var survival_time: int = 0  # Aktualny czas przetrwania
var max_survived_time: int = 0 #  Usunięto @export, aby rekord nie resetował się w Inspectorze

# 🔹 Wczytanie rekordu przy starcie gry
func _ready():
	load_max_survived_time()

# Aktualizacja czasu przetrwania co 1 sekundę
func _on_survival_timer_timeout() -> void:
	survival_time += 1
	$SurvivedTimeLabel.text = str(survival_time)

# Wywołaj tę funkcję, gdy gracz umrze
func on_player_death():
	print("on_player_death() wywołane!")

	# 🔹 Zatrzymanie timera
	if has_node("SurvivalTimer"):
		var timer = get_node("SurvivalTimer")
		timer.stop()
		print("Timer zatrzymany!")  
	else:
		print("BŁĄD: SurvivalTimer nie znaleziony w HUD!")

	  # 🔹 Sprawdzenie, czy został pobity rekord przetrwania
	print("Poprzedni rekord:", max_survived_time, "Aktualny czas przetrwania:", survival_time)
	
	if survival_time > max_survived_time:
		max_survived_time = survival_time  # ✅ Zapis nowego rekordu
		save_max_survived_time()  # ✅ Teraz rekord zostanie zapisany do pliku
		print("🎉 Nowy rekord: ", max_survived_time)
	else:
		print("Nie pobito rekordu, czas przetrwania:", survival_time, " Rekord:", max_survived_time)


	# 🔹 Pokazanie ekranu Game Over
	var game_over_screen = get_node_or_null("/root/Game/GameOver")
	if game_over_screen:
		game_over_screen.show()
		print("Game Over pokazany!")  
	else:
		print("BŁĄD: Game Over nie znaleziony w drzewie scen!")
		
	
# 🔹 Funkcja zapisująca rekord do pliku (Godot 4)
func save_max_survived_time():
	var file = FileAccess.open("user://game_data.cfg", FileAccess.WRITE)
	if file:
		file.store_string(str(max_survived_time))
		print("Rekord zapisany:", max_survived_time)
	else:
		print("BŁĄD: Nie udało się zapisać rekordu!")
	
	
# 🔹 Funkcja ładująca rekord z pliku (Godot 4)
func load_max_survived_time():
	if FileAccess.file_exists("user://game_data.cfg"):
		var file = FileAccess.open("user://game_data.cfg", FileAccess.READ)
		if file:
			max_survived_time = int(file.get_as_text().strip_edges())  # ➡️ Wczytanie i konwersja na int
			print("Załadowano rekord:", max_survived_time)
		else:
			print("BŁĄD: Nie udało się otworzyć pliku do odczytu!")
	else:
		print("Brak zapisanego rekordu, ustawiono 0")
