extends Node2D

signal device_failed(player_index: int)
signal device_survived(player_index: int)

@export var player_index: int = 0
@export var controller_device_id: int = 0
@export var fall_speed := 120.0
@export var max_tilt := 50.0
@export var tilt_damping := 0.85
@export var player_correction_strength := 90.0
@export var wind_tilt_rate := 15.0

var tilt_angle := 0.0
var wind_direction := 0.0
var alive := true
var landed := false
var falling := false           # controlled by EggDropGame

var ground_y := 700.0
var green_zone_x_min := 0.0
var green_zone_x_max := 0.0

# Hover bob effect while waiting
var hover_offset := 0.0
var hover_speed := 1.5
var hover_amplitude := 6.0
var base_y := 0.0
var hover_time := 0.0

@onready var label: Label = $Label
@onready var sprite: Node2D = $Sprite2D

func _ready():
	base_y = position.y
	label.text = "P%d" % (player_index + 1)
	# Stagger the hover phase so they don't all bob in sync
	hover_time = player_index * 0.4

func apply_wind(direction: float):
	wind_direction = direction

func _process(delta: float):
	if not alive or landed:
		return

	# --- Phase 1: floating --- 
	if not falling:
		hover_time += delta
		hover_offset = sin(hover_time * hover_speed) * hover_amplitude
		position.y = base_y + hover_offset

	# --- Phase 2: falling ---
	else:
		position.y += fall_speed * delta

	# --- Wind pushes tilt (always active) ---
	tilt_angle += wind_direction * wind_tilt_rate * delta

	# --- Player corrects with left joystick ---
	var joy_x := Input.get_joy_axis(controller_device_id, JOY_AXIS_LEFT_X)
	if abs(joy_x) < 0.15:
		joy_x = 0.0
	tilt_angle -= joy_x * player_correction_strength * delta

	# --- Damping toward upright when no input and no wind ---
	if abs(joy_x) < 0.15 and wind_direction == 0.0:
		tilt_angle = lerp(tilt_angle, 0.0, 1.0 - tilt_damping)

	# --- Clamp and apply visual rotation ---
	rotation_degrees = tilt_angle

	# --- Update label ---
	label.text = "P%d  %.1f°" % [player_index + 1, abs(tilt_angle)]

	# --- Fail if tilted too far ---
	if abs(tilt_angle) >= max_tilt:
		_fail()
		return

	# --- Land check (only during fall phase) ---
	if falling and position.y >= ground_y:
		_land()

func _fail():
	alive = false
	modulate = Color(1, 0.3, 0.3)
	label.text = "P%d  FELL!" % (player_index + 1)
	emit_signal("device_failed", player_index)

func _land():
	landed = true
	fall_speed = 0
	if position.x >= green_zone_x_min and position.x <= green_zone_x_max:
		modulate = Color(0.3, 1, 0.4)
		label.text = "P%d  SAFE!" % (player_index + 1)
		emit_signal("device_survived", player_index)
	else:
		_fail()
