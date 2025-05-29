extends Control

func _ready():
	if has_node("ButtonStart"):
		$ButtonStart.pressed.connect(_on_start_pressed)
	else:
		print("Nie znaleziono przycisku ButtonStart w scenie menu.")
	$ButtonExit.pressed.connect(_on_exit_pressed) # Jeśli masz drugi przycisk

func _on_start_pressed():
	var scene_path = "res://scenes/game.tscn"
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		print("Scena nie znaleziona:", scene_path)

func _on_exit_pressed():
	get_tree().quit()
