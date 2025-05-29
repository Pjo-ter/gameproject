extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialog_box: Panel = get_node("/root/Scena2/DialogCanvas/Panel")
@onready var dialog_label: Label = dialog_box.get_node("Label")
@onready var choice_container: VBoxContainer = dialog_box.get_node("VBoxContainer")
@onready var choice_buttons = [
	choice_container.get_node("Option1"),
	choice_container.get_node("Option2"),
	choice_container.get_node("Option3")
]

@onready var interaction_area: Area2D = $Area2D

@export var dialog_lines: Array[String] = [
	"Hej! Jak się masz?"
]

@export var dialog_choices = [
	["W porządku.", "Zostaw mnie w spokoju.", "Kim jesteś?"]
]

@export var move_speed := 40.0
@export var gravity := 400.0
@export var jump_velocity := -250.0

var is_walking_scripted := false
var dialog_index := 0
var dialog_active := false
var player_in_range := false
var direction := 1
var jump_timer := 0.0

func _ready():
	dialog_box.visible = false
	choice_container.visible = false
	animated_sprite.play("idle")
	for btn in choice_buttons:
		btn.pressed.connect(_on_choice_pressed.bind(btn))
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept") and not dialog_active:
		_start_dialog()
		return

	if dialog_active and not is_walking_scripted:
		move_and_slide()
		return

	velocity.y += gravity * delta
	velocity.x = 0  # NPC nie porusza się automatycznie

	if Input.is_action_just_pressed("npc_jump") and is_on_floor():
		velocity.y = jump_velocity
		animated_sprite.play("jump")
	elif not is_on_floor():
		animated_sprite.play("jump")
	else:
		animated_sprite.play("idle")

	move_and_slide()

func _start_dialog():
	dialog_active = true
	dialog_index = 0
	dialog_box.visible = true
	dialog_label.text = dialog_lines[dialog_index]
	_show_choices(dialog_index)
	animated_sprite.play("idle")

func _show_choices(index: int):
	choice_container.visible = true
	var choices = dialog_choices[index]
	for i in range(choice_buttons.size()):
		if i < choices.size():
			choice_buttons[i].text = choices[i]
			choice_buttons[i].visible = true
		else:
			choice_buttons[i].visible = false

func _on_choice_pressed(button: Button):
	dialog_label.text = "Wybrałeś: " + button.text
	choice_container.visible = false

	if button.name == "Option1":
		if is_on_floor():
			velocity.y = jump_velocity
			animated_sprite.play("jump")
		_end_dialog()

	elif button.name == "Option2":
		_end_dialog()
		await _walk_sequence()

	elif button.name == "Option3":
		dialog_label.text = "Chuj cię to boli?"
		await get_tree().create_timer(2).timeout
		_end_dialog()

func _end_dialog():
	dialog_box.visible = false
	dialog_active = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		_end_dialog()

func _walk_sequence() -> void:
	dialog_active = true
	is_walking_scripted = true

	animated_sprite.play("walk")
	animated_sprite.flip_h = false
	for i in range(2):
		global_position.x += 32
		await get_tree().create_timer(0.2).timeout

	animated_sprite.flip_h = true
	for i in range(2):
		global_position.x -= 32
		await get_tree().create_timer(0.2).timeout

	animated_sprite.play("idle")
	is_walking_scripted = false
	dialog_active = false
