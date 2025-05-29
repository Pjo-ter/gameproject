extends CharacterBody2D
var max_health: int = 100
var current_health: int = max_health

const SPEED = 300.0
const JUMP_FORCE = -400.0
var is_attacking = false

var experience: float = 0
var level: int = 1
var max_level: int = 15
var exp_to_next_level: float = 100.0



@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var attack_collider = $AttackArea/CollisionShape2D
var hud = null

func _ready():
	add_to_group("player")
	attack_collider.disabled = true
	attack_area.body_entered.connect(_on_attack_area_body_entered)

	await get_tree().process_frame

	hud = get_tree().get_first_node_in_group("hud")

	# 🔄 Wczytanie danych z Global
	level = Global.player_level
	experience = Global.player_experience
	exp_to_next_level = Global.player_exp_to_next
	max_health = Global.player_max_health
	current_health = Global.player_current_health

	if hud:
		hud.update_health(current_health, max_health)
		hud.update_exp(experience, exp_to_next_level)
		hud.update_level(level)

func add_experience(_exp: float):
	experience += _exp
	print("✨ EXP +", _exp, "->", experience, "/", exp_to_next_level)

	while experience >= exp_to_next_level and level < max_level:
		experience -= exp_to_next_level
		level += 1
		exp_to_next_level = ceil(exp_to_next_level * 1.5)
		print("⬆️ Awans na poziom", level, "➡️ Nowy próg:", exp_to_next_level)

	if level >= max_level:
		experience = min(experience, exp_to_next_level)
		print("🏁 Maksymalny poziom osiągnięty!")

	# 🔄 Zapis do Global
	Global.player_level = level
	Global.player_experience = experience
	Global.player_exp_to_next = exp_to_next_level

	if hud:
		hud.update_exp(experience, exp_to_next_level)
		hud.update_level(level)

func take_damage(amount: int = 1):
	current_health -= amount
	print("💔 Obrażenia:", amount, "HP =", current_health, "/", max_health)

	# 🔄 Zapis aktualnego HP
	Global.player_current_health = current_health

	if hud:
		hud.update_health(current_health, max_health)

	if current_health <= 0:
		die()

func die():
	print("☠️ Gracz zginął.")
	if hud:
		hud.on_player_death()
	Global.player_current_health = 0
	queue_free()

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED
	velocity.y += 1200 * delta  # Grawitacja

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()

	if is_attacking:
		if sprite.animation != "attack":
			sprite.play("attack")
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

	if direction != 0:
		sprite.flip_h = direction < 0
		attack_area.scale.x = -1 if direction < 0 else 1

func _input(event):
	if event.is_action_pressed("attack") and not is_attacking:
		attack()

func attack():
	print("🔥 Atak rozpoczęty!")
	is_attacking = true
	sprite.play("attack")
	sprite.animation_finished.connect(_on_attack_finished)

	await get_tree().create_timer(0.3).timeout
	attack_collider.disabled = false

func _on_attack_area_body_entered(body):
	if body.is_in_group("enemies"):
		print("💥 Trafiono przeciwnika:", body.name)
		body.die()
		add_experience(10)

func _on_attack_finished():
	if sprite.animation == "attack":
		attack_collider.disabled = true
		is_attacking = false
		print("❌ AttackArea WYŁĄCZONE!")
		sprite.animation_finished.disconnect(_on_attack_finished)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	Global.player_current_health = current_health
	if hud:
		hud.update_health(current_health, max_health)
