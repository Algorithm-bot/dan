extends Area2D

var speed = 300
var direction: Vector2 = Vector2.ZERO # CHANGED: Now a Vector2 instead of just 1 or -1

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# CHANGED: Move along both X and Y axes based on the vector
	position += direction * speed * delta

func _on_body_entered(body):
	# Check if the object we hit is an enemy
	if body.is_in_group("Player"):
		body.take_damage(10) # Assuming your enemy has a take_damage function
		queue_free() # Destroy the fireball on impact

func _on_screen_exited():
	queue_free() # Destroy the fireball when it leaves the screen
