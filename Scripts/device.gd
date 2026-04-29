extends Node2D

signal device_failed(player_index: int)
signal device_survived(player_index: int)

@export var player_index: int = 0
@export var controller_device_id: int = 0
@export var fall_speed := 120.0
@export var max_tilt := 90.0
@export var tilt_damping := 0.85
@export var player_correction_strength := 90.0
@export var wind_tilt_rate := 70.0

var tilt_angle := 0.0
var wind_direction := 0.0
var alive := true
var landed := false
var falling := false

var ground_y := 700.0
var green_zone_x_min := 0.0
var green_zone_x_max := 0.0

var hover_time := 0.0
var hover_speed := 1.5
var hover_amplitude := 6.0
var base_y := 0.0

# Animation
var anim_timer := 0.0
var anim_frame := 0
const ANIM_FPS := 8.0

var frames: Array[Texture2D] = []

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	base_y = position.y
	hover_time = player_index * 0.4

	label.text = "P%d" % (player_index + 1)

	# Load frames
	frames.append(preload("res://Assets/EDP0.png"))
	frames.append(preload("res://Assets/EDP1.png"))

	sprite.texture = frames[0]

func apply_wind(direction: float):
	wind_direction = direction

func _process(delta: float):
	if not alive or landed:
		return

	# --- Animation ---
	anim_timer += delta

	if anim_timer >= 1.0 / ANIM_FPS:
		anim_timer = 0.0
		anim_frame = (anim_frame + 1) % frames.size()
		sprite.texture = frames[anim_frame]

	# --- Hover or fall ---
	if not falling:
		hover_time += delta
		position.y = base_y + sin(hover_time * hover_speed) * hover_amplitude
	else:
		position.y += fall_speed * delta

	# --- Wind tilt ---
	tilt_angle += wind_direction * wind_tilt_rate * delta

	# --- Player correction ---
	var joy_x := -Input.get_joy_axis(controller_device_id, JOY_AXIS_LEFT_X)

	if abs(joy_x) < 0.15:
		joy_x = 0.0

	tilt_angle -= joy_x * player_correction_strength * delta

	# --- Damping ---
	if abs(joy_x) < 0.15 and wind_direction == 0.0:
		tilt_angle = lerp(tilt_angle, 0.0, 1.0 - tilt_damping)

	rotation_degrees = tilt_angle

	label.text = "P%d  %.1f°" % [
		player_index + 1,
		abs(tilt_angle)
	]

	# --- Fail from over-tilt ---
	if abs(tilt_angle) >= max_tilt:
		_fail()
		return

	# --- Landing check using bottom of sprite ---
	if falling:
		var sprite_height := sprite.texture.get_height() * sprite.scale.y * scale.y
		var bottom_y := position.y + sprite_height / 2.0

		if bottom_y >= ground_y:
			position.y = ground_y - sprite_height / 2.0
			_land()

func _fail():
	alive = false

	modulate = Color(1, 0.3, 0.3)

	label.text = "P%d  FELL!" % (player_index + 1)

	sprite.texture = frames[0]

	emit_signal("device_failed", player_index)

func _land():
	landed = true
	falling = false
	fall_speed = 0

	sprite.texture = frames[0]

	if position.x >= green_zone_x_min and position.x <= green_zone_x_max:
		modulate = Color(0.3, 1, 0.4)

		label.text = "P%d  SAFE!" % (player_index + 1)

		emit_signal("device_survived", player_index)
	else:
		_fail()
