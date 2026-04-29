class_name PlayerCharacter
extends CharacterBody2D

@export var device_id: int = 0
@export var speed: float = 250.0
@export var deadzone: float = 0.2
@export var can_move: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bubble: AnimatedSprite2D = get_node_or_null("ThoughtBubble")
@onready var feedback_pivot: Node2D = get_node_or_null("FeedbackPivot")
@onready var result_label: Label = get_node_or_null("FeedbackPivot/ResultLabel")
@onready var time_label: Label = get_node_or_null("FeedbackPivot/TimeLabel")
@onready var player_indicator: Label = get_node_or_null("PlayerIndicator")

var feedback_start_y: float
var last_direction: Vector2 = Vector2.DOWN
var player_colors: Array[Color] = [
	Color(1.0, 0.2, 0.2), # P1: Red
	Color(0.2, 0.6, 1.0), # P2: Blue
	Color(0.2, 0.8, 0.2), # P3: Green
	Color(1.0, 0.8, 0.2), # P4: Yellow
	Color(0.8, 0.2, 0.8)  # P5: Purple
]

func _ready() -> void:
	if get_tree().get_first_node_in_group("minigame_manager"):
		can_move = false
		sprite.play("default_up")
		
	if feedback_pivot:
		feedback_pivot.modulate.a = 0.0
		feedback_start_y = feedback_pivot.position.y
		
	if player_indicator:
		player_indicator.text = "P" + str(device_id + 1)
		var color_index = clampi(device_id, 0, player_colors.size() - 1)
		player_indicator.add_theme_color_override("font_color", player_colors[color_index])

func show_feedback(state: String, time: float = 0.0) -> void:
	feedback_pivot.position.y = feedback_start_y
	feedback_pivot.modulate.a = 1.0
	
	if state == "correct":
		result_label.text = "Correct!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
		time_label.text = "%.2fs" % time
		time_label.visible = true
	elif state == "slow":
		result_label.text = "Too Slow!"
		result_label.add_theme_color_override("font_color", Color.RED)
		time_label.text = "%.2fs" % time
		time_label.visible = true
	else: # "wrong"
		result_label.text = "Oh No!"
		result_label.add_theme_color_override("font_color", Color.RED)
		time_label.visible = false
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(feedback_pivot, "position:y", feedback_start_y - 5.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(feedback_pivot, "modulate:a", 0.0, 0.5).set_delay(1.5)
	
func _physics_process(_delta: float) -> void:
	if not can_move:
		return
		
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	input_dir.y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
	
	if input_dir.length() < deadzone:
		input_dir = Vector2.ZERO
	
	if input_dir != Vector2.ZERO:
		last_direction = input_dir
		
	velocity = input_dir * speed
	move_and_slide()
	_update_spritesheet(input_dir)

func _input(event: InputEvent) -> void:
	if not can_move and event is InputEventJoypadButton and event.is_pressed():
		if event.device == device_id:
			var manager = get_tree().get_first_node_in_group("minigame_manager")
			if manager:
				manager.register_input(device_id, event.button_index)
				hide_thought_bubble()

func show_thought_bubble(button_index: int) -> void:
	bubble.visible = true
	bubble.animation = "Buttons"
	bubble.stop() # Prevents the frames from cycling
	
	match button_index:
		JOY_BUTTON_X: bubble.frame = 0 # Square
		JOY_BUTTON_B: bubble.frame = 1 # Circle
		JOY_BUTTON_A: bubble.frame = 2 # Cross
		JOY_BUTTON_Y: bubble.frame = 3 # Triangle

func hide_thought_bubble() -> void:
	bubble.visible = false

func _update_spritesheet(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
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
	
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			sprite.play("walk_left")
		else:
			sprite.play("walk_right")
	elif direction.y < 0:
		sprite.play("walk_up")
	else:
		sprite.play("walk_down")
