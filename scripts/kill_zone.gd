extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Gracz wpadł do KillZone!")

		var hud = get_node("/root/Game/HUD") if has_node("/root/Game/HUD") else null
		print("HUD znaleziony w KillZone, wywołuję on_player_death()")

		if body.has_method("take_damage"):
			body.take_damage(1)  # ✅ zadaj tylko 1 punkt obrażeń
