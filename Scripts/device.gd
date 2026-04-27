# Device.gd
# Attach to a Node2D that represents one player's falling device.
# Children:
#   - Sprite2D (or AnimatedSprite2D) for the visual
#   - Label showing player name + tilt angle
#   - CollisionShape2D if using physics

extends Node2D

signal device_failed(player_index: int)
signal device_survived(player_index: int)

@export var player_index: int = 0        # 0–4
@export var controller_device_id: int = 0  # joypad device index (0–4)
@export var fall_speed := 60.0          # pixels per second downward
@export var max_tilt := 50.0            # degrees — fail threshold
@export var tilt_damping := 0.85        # how quickly tilt settles
@export var player_correction_strength := 90.0  # degrees/sec player can apply
@export var wind_tilt_rate := 35.0      # degrees/sec wind adds when active

var tilt_angle := 0.0          # current rotation in degrees
var wind_direction := 0.0      # +1 right, -1 left, 0 calm
var alive := true
var landed := false

# Ground Y — set by EggDropGame after positioning
var ground_y := 800.0
# Green zone range (screen X) — set by EggDropGame
var green_zone_x_min := 0.0
var green_zone_x_max := 0.0

@onready var label: Label = $Label
@onready var sprite: Node2D = $Sprite2D

func _ready():
	label.text = "P%d" % (player_index + 1)

func apply_wind(direction: float):
	wind_direction = direction

func _process(delta: float):
	if not alive or landed:
		return

	# --- Fall ---
	position.y += fall_speed * delta

	# --- Wind pushes tilt ---
	tilt_angle += wind_direction * wind_tilt_rate * delta

	# --- Player counteracts with left joystick X axis ---
	# InputMap axis 0 = left stick horizontal on most controllers
	var joy_x := Input.get_joy_axis(controller_device_id, JOY_AXIS_LEFT_X)
	# Dead zone
	if abs(joy_x) < 0.15:
		joy_x = 0.0

	tilt_angle -= joy_x * player_correction_strength * delta

	# --- Natural damping toward 0 when no input ---
	if abs(joy_x) < 0.15 and wind_direction == 0.0:
		tilt_angle = lerp(tilt_angle, 0.0, 1.0 - tilt_damping)

	# --- Apply rotation visually ---
	rotation_degrees = tilt_angle
	label.text = "P%d  %.1f°" % [player_index + 1, abs(tilt_angle)]

	# --- Fail check ---
	if abs(tilt_angle) >= max_tilt:
		_fail()
		return

	# --- Landing check ---
	if position.y >= ground_y:
		_land()

func _fail():
	alive = false
	modulate = Color(1, 0.3, 0.3)  # flash red
	label.text = "P%d  FELL!" % (player_index + 1)
	emit_signal("device_failed", player_index)

func _land():
	landed = true
	fall_speed = 0
	# Check if within green zone
	if position.x >= green_zone_x_min and position.x <= green_zone_x_max:
		modulate = Color(0.3, 1, 0.4)  # green = survived
		label.text = "P%d  SAFE!" % (player_index + 1)
		emit_signal("device_survived", player_index)
	else:
		_fail()
