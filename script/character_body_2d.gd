extends CharacterBody2D

@export var device_id: int = 0
@export var speed: float = 250.0
@export var deadzone: float = 0.2

@onready var sprite: Sprite2D = $Sprite2D
# @onready var anim_player: AnimationPlayer = $AnimationPlayer

func _physics_process(_delta: float) -> void:
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
		# anim_player.play("idle")
		return
		
	# Basic horizontal flip
	if direction.x != 0:
		sprite.flip_h = direction.x < 0

	# AnimationPlayer logic for a 4-direction spritesheet
	# if abs(direction.x) > abs(direction.y):
	#     anim_player.play("walk_side")
	# elif direction.y < 0:
	#     anim_player.play("walk_up")
	# else:
	#     anim_player.play("walk_down")
