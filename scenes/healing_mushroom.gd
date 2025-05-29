extends Area2D

@export var heal_amount: int = 10
var is_used: bool = false  # 🔥 dodajemy nową zmienną

func _on_body_entered(body: Node2D) -> void:
	if is_used:
		return  # ❌ jeśli już wykorzystany, ignoruj

	if body.is_in_group("player"):
		if body.has_method("heal"):
			body.heal(heal_amount)
			is_used = true  # ✅ oznacz jako wykorzystany
			hide()  # 🔥 ukryj grzyba po użyciu
			$CollisionShape2D.disabled = true  # 🔥 wyłącz kolizję po użyciu
