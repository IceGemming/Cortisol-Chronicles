extends CharacterBody2D

@export var device_id: int = 0
@export var speed: float = 250.0
@export var deadzone: float = 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	print("X: ", Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X), " Y: ", Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y))
	var input_dir := Vector2.ZERO
	
	# Read raw analog stick data for the specific controller ID
	input_dir.x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	input_dir.y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
	
	# Apply circular deadzone to prevent controller drift
	if input_dir.length() < deadzone:
		input_dir = Vector2.ZERO
		
	velocity = input_dir * speed
	move_and_slide()
	
	_update_spritesheet(input_dir)

func _update_spritesheet(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		sprite.play("default_down")
	# AnimationPlayer logic for a 4-direction spritesheet
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			sprite.play("walk_left")
		elif direction.x > 0:
			sprite.play("walk_right")
	elif direction.y < 0:
		sprite.play("walk_up")
	else:
		sprite.play("walk_down")
