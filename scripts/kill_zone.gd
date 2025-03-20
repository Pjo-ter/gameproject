extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Gracz wpadł do KillZone!")  # Debugowanie

		var hud = get_node("/root/Game/HUD") if has_node("/root/Game/HUD") else null
		if hud:
			print("HUD znaleziony w KillZone, wywołuję on_player_death()")  # Debugowanie
			hud.on_player_death()

		body.queue_free()  # Usuń gracza
