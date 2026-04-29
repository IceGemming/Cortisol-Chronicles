class_name PlayerCharacter
extends CharacterBody2D

# ─────────────────────────────────────────────
#  Player — PS5 controller support
#  Set player_id and team in the Inspector
#  Controls (per controller):
#    Left joystick → move (all 4 directions)
#    Triangle       → pick up / drop / deliver screw
# ─────────────────────────────────────────────
@export var player_id: int = 1
@export var team: String = "A"
@export var speed: float = 250.0
@export var deadzone: float = 0.2

# device_id is derived from player_id in _ready()
var device_id: int = 0

# PS5 button constant (Godot SDL mapping)
const JOY_BTN_TRIANGLE: int = 3

# How close the player needs to be to the robot to deliver
const DELIVER_RANGE: float = 120.0

# ─────────────────────────────────────────────
#  State
# ─────────────────────────────────────────────
var carried_part: Node = null
var _action_held: bool = false
var last_direction: Vector2 = Vector2.DOWN

# ─────────────────────────────────────────────
#  Boundaries
#  Set floor_y in the Inspector to match your
#  floor node's Y position in the scene.
# ─────────────────────────────────────────────
@export var floor_y: float = 560.0

const SCREEN_LEFT:  float = 20.0
const SCREEN_RIGHT: float = 1260.0
const SCREEN_TOP:   float = 20.0
const CENTER_LINE:  float = 640.0

# ─────────────────────────────────────────────
#  Node references
# ─────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = get_node("/root/Main/GameManager")

func _ready() -> void:
	device_id = player_id - 1
	add_to_group("players")

	if has_node("Camera2D"):
		$Camera2D.enabled = false

	sprite.play("default_down")

func _physics_process(_delta: float) -> void:
	if game_manager and game_manager.game_over:
		sprite.play("default_down")
		return

	_handle_movement()
	_handle_action()
	_carry_part_follow()
	move_and_slide()

func _handle_movement() -> void:
	var input_dir := Vector2.ZERO

	input_dir.x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	input_dir.y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)

	# Apply deadzone
	if input_dir.length() < deadzone:
		input_dir = Vector2.ZERO

	# Track last non-zero direction for idle animation
	if input_dir != Vector2.ZERO:
		last_direction = input_dir

	velocity = input_dir * speed

	# Clamp to team side (X) and screen bounds (Y)
	var new_pos := position + velocity * get_physics_process_delta_time()
	if team == "A":
		new_pos.x = clamp(new_pos.x, SCREEN_LEFT, CENTER_LINE - 30.0)
	else:
		new_pos.x = clamp(new_pos.x, CENTER_LINE + 30.0, SCREEN_RIGHT)
	new_pos.y = clamp(new_pos.y, SCREEN_TOP, floor_y)

	position = new_pos
	velocity = Vector2.ZERO

	_update_spritesheet(input_dir)

func _update_spritesheet(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		# Idle animation based on last direction travelled
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

func _handle_action() -> void:
	var triangle_pressed: bool = Input.is_joy_button_pressed(device_id, JOY_BTN_TRIANGLE)

	if not triangle_pressed:
		_action_held = false
		return

	if _action_held:
		return
	_action_held = true

	if carried_part == null:
		_try_pickup()
	else:
		_try_deliver_or_drop()

# Deliver if near the robot, otherwise drop on the floor
func _try_deliver_or_drop() -> void:
	var robots := get_tree().get_nodes_in_group("robot_" + team)
	for robot in robots:
		if position.distance_to(robot.position) <= DELIVER_RANGE:
			robot.receive_part(self)
			carried_part = null
			return
	# Not close enough to any robot — just drop it
	_drop_part()

func _try_pickup() -> void:
	var parts := get_tree().get_nodes_in_group("parts")
	var best_part: Node = null
	var best_dist: float = 90.0

	for p in parts:
		if p.is_carried:
			continue
		var d := position.distance_to(p.position)
		if d < best_dist:
			best_dist = d
			best_part = p

	if best_part:
		carried_part = best_part
		best_part.pick_up(self)

func _drop_part() -> void:
	if carried_part:
		carried_part.drop(position + Vector2(0, 40))
		carried_part = null

func _carry_part_follow() -> void:
	if carried_part:
		carried_part.position = position + Vector2(0, -55)

# Kept for compatibility in case robot.gd still calls these
func enter_robot_zone() -> void:
	pass

func exit_robot_zone() -> void:
	pass
