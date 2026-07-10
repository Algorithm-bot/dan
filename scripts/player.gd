extends CharacterBody2D

const SPEED = 350.0
const JUMP_VELOCITY = -700.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 200
var is_dead = false

# --- SPECIAL ATTACK VARIABLES ---
var special_charge = 0.0
const MAX_CHARGE = 100.0
const CHARGE_RATE = 5.0 # Adds 20 per second (takes 5 seconds to fill up)

@onready var jump = $jump
@onready var swing = $swing
@onready var special_attack_sound = $special_attack_sound
@onready var normal_step_sound = $NormalStepSound 
@onready var blood_step_sound = $BloodStepSound
@onready var health_bar = $ProgressBar
@onready var charge_bar = $ChargeBar 
@onready var attack_area = $AttackArea 
@onready var animated_sprite = $AnimatedSprite2D

var facing_right = true
var is_attacking = false
var is_on_blood = false

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)
	add_to_group("Player")
	
	# Set up the charge bar
	if charge_bar:
		charge_bar.max_value = MAX_CHARGE
		charge_bar.value = special_charge

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- NEW: THE BOTTOMLESS PIT CHECK ---
	# If the player falls past a Y-coordinate of 1000, they die!
	if global_position.y > 1000:
		if not is_dead: # Make sure we don't trigger the death timer multiple times
			die()

	# --- CHARGE BAR FILLER ---
	if special_charge < MAX_CHARGE:
		special_charge += CHARGE_RATE * delta
		# Prevent it from overflowing past 100
		if special_charge > MAX_CHARGE:
			special_charge = MAX_CHARGE
		charge_bar.value = special_charge

	# Jump
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump.play() # PLAY THE JUMP SOUND HERE!

	# Left / Right movement
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			facing_right = true
		elif direction < 0:
			facing_right = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- FOOTSTEP AUDIO LOGIC ---
	if direction != 0 and is_on_floor() and not is_attacking and not is_dead:
		# If standing in blood...
		if is_on_blood:
			normal_step_sound.stop() # Make sure dirt sound stops
			if not blood_step_sound.playing:
				blood_step_sound.play()
				
		# If standing on normal dirt...
		else:
			blood_step_sound.stop() # Make sure blood sound stops
			if not normal_step_sound.playing:
				normal_step_sound.play()
				
	# If we are standing still or in the air, stop all footstep sounds
	else:
		normal_step_sound.stop()
		blood_step_sound.stop()

	# Apply the physics and update the visual animations
	move_and_slide()
	update_animations(direction)

func update_animations(direction):
	# --- 1. SPECIAL ATTACK (Holding Q or F) ---
	if Input.is_action_pressed("special_attack") and special_charge >= MAX_CHARGE and not is_attacking and not is_dead: 
		is_attacking = true
		special_charge = 0.0 # Consume the charge!
		charge_bar.value = special_charge
		
		animated_sprite.play("whirlwind") 
		animated_sprite.scale = Vector2(1.5, 1.5) 
		
		# --- NEW: Make the physical hit-box bigger too! ---
		attack_area.scale = Vector2(1.5, 1.5)
		
		special_attack_sound.play() # PLAY THE SPECIAL WHIRLWIND SOUND HERE!
		
		if attack_area.has_overlapping_bodies():
			for body in attack_area.get_overlapping_bodies():
				if body.is_in_group("Enemy"):
					if body.has_method("take_damage"):
						body.take_damage(50) 
						
		return # Stop reading other animations

	# --- 2. NORMAL ATTACK ---
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dead: 
		is_attacking = true
		
		swing.play() # PLAY THE NORMAL SWING SOUND HERE!
		
		if facing_right:
			animated_sprite.play("right_attacking")
		else:
			animated_sprite.play("left_attacking")
			
		if attack_area.has_overlapping_bodies():
			for body in attack_area.get_overlapping_bodies():
				if body.is_in_group("Enemy"):
					if body.has_method("take_damage"):
						body.take_damage(15) 
		
	if is_attacking:
		return

	# --- 3. RUNNING (Default Movement) ---
	if direction != 0:
		animated_sprite.flip_h = false 
		
		if facing_right:
			animated_sprite.play("right_running")
		else:
			animated_sprite.play("left_running")

	# --- 4. IDLE ---
	else:
		animated_sprite.flip_h = false
		if facing_right:
			animated_sprite.play("right_idle")
		else:
			animated_sprite.play("left_idle")

# Automatically runs the moment ANY animation finishes playing
func _on_animation_finished():
	# Normal attacks ending
	if animated_sprite.animation == "left_attacking" or animated_sprite.animation == "right_attacking":
		is_attacking = false
		
	# Special attack ending
	if animated_sprite.animation == "whirlwind": 
		is_attacking = false
		animated_sprite.scale = Vector2(1.0, 1.0)
		
		# --- NEW: Shrink the hit-box back to normal size! ---
		attack_area.scale = Vector2(1.0, 1.0)

# --- HEALTH FUNCTIONS ---
func take_damage(damage_amount):
	if is_dead:
		return
		
	health -= damage_amount
	health_bar.value = health
	
	if health <= 0:
		die()

# --- HEALING FUNCTION ---
func heal(heal_amount):
	if is_dead:
		return 
		
	health += heal_amount
	
	if health > 200:
		health = 200
		
	health_bar.value = health 

func die():
	# 1. Stop the player from moving or doing anything else
	is_dead = true
	set_physics_process(false)
	animated_sprite.play("dying")
	
	
	# 2. Wait for 1.5 seconds (so the death isn't jarringly instant)
	await get_tree().create_timer(2.5).timeout
	
	# 3. Reload the current level!
	get_tree().reload_current_scene()
