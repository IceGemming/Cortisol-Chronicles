class_name PlayerCharacter
extends CharacterBody2D
@export var device_id: int = 0
@export var speed: float = 250.0
@export var deadzone: float = 0.2
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2.ZERO
	
	input_dir.x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	input_dir.y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
	
	if input_dir.length() < deadzone:
		input_dir = Vector2.ZERO
	
	# Track last non-zero direction before stopping
	if input_dir != Vector2.ZERO:
		last_direction = input_dir
		
	velocity = input_dir * speed
	move_and_slide()
	
	_update_spritesheet(input_dir)

func _update_spritesheet(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		# Pick idle animation based on the last direction travelled
		if abs(last_direction.x) > abs(last_direction.y):
			if last_direction.x < 0:
				sprite.play("default_left")
			else:
				sprite.play("default_right")
		elif last_direction.y < 0:
			sprite.play("default_up")
		else:
			sprite.play("default_down")
		return
	
	# Walk animations
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			sprite.play("walk_left")
		else:
			sprite.play("walk_right")
	elif direction.y < 0:
		sprite.play("walk_up")
	else:
		sprite.play("walk_down")
