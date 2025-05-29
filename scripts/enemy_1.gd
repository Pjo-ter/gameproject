extends CharacterBody2D

const SPEED = 300.0
const JUMP_FORCE = -400.0

var is_attacking = false
var is_dead = false
var player_in_range := false
var cancel_attack_early := false

var player: Node2D = null
@export var jump_threshold: float = 50.0
@export var speed: float = 100.0
@export var xp_reward: int = 10

@onready var kill_zone = $KillZone
@onready var attack_collider = $KillZone/CollisionShape2D
@onready var sprite = $AnimatedSprite2D
@onready var player_detect = $PlayerDetect

func _ready():
	for c in get_tree().get_nodes_in_group("player"):
		print("🎯 W grupie player jest:", c.name, "typ:", c)

	add_to_group("enemies")
	print("👾 Przeciwnik", name, "dodany do grupy enemies!")

	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
		collision_shape.set_deferred("one_way_collision", false)

	player_detect.body_entered.connect(_on_player_detect_body_entered)
	player_detect.body_exited.connect(_on_player_detect_body_exited)

	sprite.z_index = 10
	attack_collider.disabled = true
	kill_zone.body_entered.connect(_on_kill_zone_body_entered)
	kill_zone.body_exited.connect(_on_kill_zone_body_exited)

func set_target(p: Node2D):
	player = p
	print("🎯 Przeciwnik otrzymał gracza jako cel:", player)

func _physics_process(delta: float) -> void:
	if is_dead or player == null:
		return

	_update_facing_direction()

	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	velocity.y += 1200 * delta  # Grawitacja

	if is_on_floor() and should_jump():
		velocity.y = JUMP_FORCE

	move_and_slide()
	play_animation()

func should_jump() -> bool:
	return player != null and player.global_position.y + 40 < global_position.y

func _process(delta):
	if is_instance_valid(player) and not is_dead:
		_update_facing_direction()

func _update_facing_direction():
	if player == null:
		return
	var facing_left = player.global_position.x < global_position.x
	sprite.flip_h = facing_left
	kill_zone.scale.x = -1 if facing_left else 1
	player_detect.scale.x = -1 if facing_left else 1

func _on_player_detect_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		if not is_attacking:
			attack()

func _on_player_detect_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		cancel_attack_early = true
		attack_collider.disabled = true

func attack():
	if is_attacking:
		return
	is_attacking = true
	sprite.play("attack")
	sprite.animation_finished.connect(_on_attack_finished)

	await get_tree().create_timer(0.3).timeout
	attack_collider.disabled = false

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1)

func _on_attack_finished():
	if sprite.animation == "attack":
		attack_collider.disabled = true
		is_attacking = false
		cancel_attack_early = false
		sprite.animation_finished.disconnect(_on_attack_finished)
		if player_in_range:
			attack()

func die():
	if is_dead:
		return
	is_dead = true
	queue_free()

func play_animation():
	if is_attacking:
		if sprite.animation != "attack":
			sprite.play("attack")
	elif velocity.length() > 1:
		sprite.play("walk")
	else:
		sprite.play("idle")

func _on_kill_zone_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_kill_zone_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
