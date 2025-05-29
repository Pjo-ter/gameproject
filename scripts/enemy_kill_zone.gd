extends Area2D

func _ready():
	connect("body_entered", _on_body_entered)  # Podłącz sygnał kolizji
	set_deferred("monitorable", false)  # Na starcie EnemyKillZone jest nieaktywne

func _on_body_entered(body):
	print("🚀 EnemyKillZone: wykryto obiekt:", body.name)
	print("🔍 Czy EnemyKillZone jest aktywne?", monitorable)

	if monitorable and body.is_in_group("enemies"):  
		print("💀 Przeciwnik", body.name, "zginął w Enemy_kill_zone!")
		body.die()
