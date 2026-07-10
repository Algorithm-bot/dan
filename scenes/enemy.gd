extends CharacterBody2D

const PACE_SPEED = 300.0
const CHASE_SPEED = 300.0
const JUMP_VELOCITY = -800.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# 1 means Right, -1 means Left
var direction = 1

var is_dead = false
var is_attacking = false
var player_to_chase = null
var health = 100

@onready var GrowlSound = $GrowlSound
@onready var jump = $jump
@onready var swing = $swing
@onready var health_bar = $ProgressBar
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var ledge_check = $LedgeCheck

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)
	add_to_group("Enemy")

func _physics_process(delta):
	# --- 1. DEATH STATE ---
	if is_dead:
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	# --- 2. GRAVITY ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- 3. ATTACKING STATE ---
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# --- 4. AI MOVEMENT LOGIC ---
	if player_to_chase != null:
		# CHASE THE PLAYER!
		var direction_to_player = sign(player_to_chase.global_position.x - global_position.x)

		if direction_to_player != 0:
			direction = direction_to_player

		velocity.x = direction * CHASE_SPEED

		# JUMP LOGIC
		if is_on_floor() and (is_on_wall() or not ledge_check.is_colliding()):

			var player_in_attack_range = false
			for body in attack_area.get_overlapping_bodies():
				if body.is_in_group("Player"):
					player_in_attack_range = true

			# Only jump if the player is NOT the thing we are bumping into
			if not player_in_attack_range:
				velocity.y = JUMP_VELOCITY
				jump.play()

	else:
		# PACING NORMALLY
		velocity.x = direction * PACE_SPEED

		if is_on_wall() or not ledge_check.is_colliding():
			direction *= -1

	# --- 5. ANIMATION & FACING ---
	if not is_on_floor():
		animated_sprite.play("jump")
		animated_sprite.flip_h = (direction < 0)

	elif direction != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = (direction < 0)

		detection_area.scale.x = direction
		attack_area.scale.x = direction

		ledge_check.position.x = 20 * direction

	else:
		animated_sprite.play("idle")

	move_and_slide()

# --- SIGNALS ---

func _on_detection_area_body_entered(body):
	if is_dead:
		return

	if body.is_in_group("Player"):
		player_to_chase = body

		if not GrowlSound.playing:
			GrowlSound.play()

func _on_detection_area_body_exited(body):
	if body.is_in_group("Player"):
		player_to_chase = null

func _on_attack_area_body_entered(body):
	if is_dead:
		return

	if body.is_in_group("Player"):
		attack()

# --- ACTIONS ---

func attack():
	if not is_attacking and not is_dead:
		is_attacking = true
		animated_sprite.play("attack_1")

		swing.play()

		# Deal damage to the player!
		if attack_area.has_overlapping_bodies():
			for body in attack_area.get_overlapping_bodies():
				if body.is_in_group("Player"):
					if body.has_method("take_damage"):
						body.take_damage(2)

func take_damage(damage_amount):
	if is_dead:
		return

	health -= damage_amount
	health_bar.value = health

	if health <= 0:
		die()

func die():
	is_dead = true
	player_to_chase = null
	velocity.x = 0

	health_bar.hide()
	animated_sprite.play("dead")

	GrowlSound.stop()

	detection_area.monitoring = false
	attack_area.monitoring = false

func _on_animation_finished():
	if animated_sprite.animation == "attack_1":
		is_attacking = false

		if attack_area.has_overlapping_bodies():
			for body in attack_area.get_overlapping_bodies():
				if body.is_in_group("Player"):
					attack()
