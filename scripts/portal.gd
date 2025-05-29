extends Area2D

@export var target_scene_path: String = "res://scenes/scena_2.tscn"


func _ready():
	print("Portal gotowy. Warstwy:", collision_layer, " Maska:", collision_mask)
	$Sprite2D.scale.x *= -1

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("🌍 Przenoszę gracza do sceny:", target_scene_path)
		get_tree().change_scene_to_file(target_scene_path)
