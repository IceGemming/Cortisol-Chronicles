extends Node2D

const PLAYER_COUNT := 5
const DEVICE_SCENE := preload("res://device.tscn")

const GROUND_Y := 780.0          # final resting Y of ground
const GROUND_HIDDEN_Y := 900.0   # starts below camera here
const SPACING := 120.0
const START_X := 100.0
const GREEN_ZONE_WIDTH := 60.0
const GREEN_ZONE_HALF := GREEN_ZONE_WIDTH / 2.0

const TOTAL_TIME := 60.0
const FALL_START_TIME := 50.0

@onready var wind_manager: Node = $WindManager
@onready var wind_label: Label = $WindLabel
@onready var result_label: Label = $ResultLabel
@onready var timer_label: Label = $TimerLabel

var devices: Array = []
var green_zones: Array = []
var survived_count := 0
var failed_count := 0
var results := {}

var elapsed := 0.0
var falling_started := false
var game_over := false

func _ready():
	result_label.text = ""
	wind_label.text = "Wind: calm"

	# Spawn devices
	for i in PLAYER_COUNT:
		var device = DEVICE_SCENE.instantiate()
		device.player_index = i
		device.controller_device_id = i
		device.position = Vector2(START_X + i * SPACING, GROUND_Y / 2.0)
		device.ground_y = GROUND_Y
		device.falling = false
		var cx := START_X + i * SPACING
		device.green_zone_x_min = cx - GREEN_ZONE_HALF
		device.green_zone_x_max = cx + GREEN_ZONE_HALF
		add_child(device)
		device.device_failed.connect(_on_device_failed)
		device.device_survived.connect(_on_device_survived)
		devices.append(device)

	_spawn_ground_and_zones()

func _spawn_ground_and_zones():
	# Ground bar — starts hidden below screen
	var ground_bar := ColorRect.new()
	ground_bar.color = Color(0.3, 0.2, 0.1)   # brown ground color
	ground_bar.size = Vector2(2000, 20)
	ground_bar.position = Vector2(-300, GROUND_HIDDEN_Y)
	ground_bar.name = "GroundBar"
	add_child(ground_bar)
	green_zones.append(ground_bar)  # include in tween group

	# Green zones — also start hidden below screen
	for i in PLAYER_COUNT:
		var zone := ColorRect.new()
		zone.color = Color(0.2, 0.9, 0.3, 0.8)
		zone.size = Vector2(GREEN_ZONE_WIDTH, 16)
		# Final position at GROUND_Y, hidden at GROUND_HIDDEN_Y
		zone.position = Vector2(
			START_X + i * SPACING - GREEN_ZONE_HALF,
			GROUND_HIDDEN_Y - 16   # just above the ground bar
		)
		add_child(zone)
		green_zones.append(zone)

func _begin_falling():
	wind_label.text = "FALLING!"

	# Tween ground and zones up into view
	var tween := create_tween()
	tween.set_parallel(true)   # all tweens run simultaneously

	for node in green_zones:
		var is_ground_bar: bool = node.name == "GroundBar"
		var target_y: float
		if is_ground_bar:
			target_y = GROUND_Y
		else:
			target_y = GROUND_Y - 16   # green zones sit just above ground
		tween.tween_property(node, "position:y", target_y, 1.5)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BACK)  # slight overshoot for juice

	# Start devices falling after the ground finishes rising
	await get_tree().create_timer(1.5).timeout
	for device in devices:
		if device.alive and not device.landed:
			device.falling = true

func _process(delta: float):
	if game_over:
		return

	elapsed += delta
	var remaining := TOTAL_TIME - elapsed

	# Timer display
	var secs := int(ceil(remaining))
	timer_label.text = "0:%02d" % secs

	# Flash red in last 10 seconds
	if remaining <= 10.0:
		timer_label.modulate = Color(1, 0.2, 0.2) if int(elapsed * 4) % 2 == 0 else Color(1, 1, 1)

	# Trigger fall phase
	if not falling_started and elapsed >= FALL_START_TIME:
		falling_started = true
		_begin_falling()

	# Time's up
	if elapsed >= TOTAL_TIME:
		game_over = true
		_force_end_all()

func _on_wind_changed(direction: float):
	var dir_text := "→ RIGHT" if direction > 0 else "← LEFT"
	wind_label.text = "Wind: %s" % dir_text
	for device in devices:
		if device.alive and not device.landed:
			device.apply_wind(direction)

func _on_device_failed(player_index: int):
	results[player_index] = "failed"
	failed_count += 1
	_check_all_done()

func _on_device_survived(player_index: int):
	results[player_index] = "survived"
	survived_count += 1
	_check_all_done()

func _force_end_all():
	for i in PLAYER_COUNT:
		if not results.has(i):
			results[i] = "survived" if devices[i].alive else "failed"
			if results[i] == "survived":
				survived_count += 1
	_finish()

func _check_all_done():
	if results.size() >= PLAYER_COUNT:
		game_over = true
		_finish()

func _finish():
	GameManager.egg_drop_results = results
	GameManager.get_egg_score()
	var summary := "Results:\n"
	for i in PLAYER_COUNT:
		summary += "P%d: %s\n" % [i + 1, results.get(i, "failed").to_upper()]
	result_label.text = summary
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://cutscene_4.tscn")
