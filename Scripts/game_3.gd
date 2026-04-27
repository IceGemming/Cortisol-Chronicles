extends Node2D

const PLAYER_COUNT := 5
const DEVICE_SCENE := preload("res://device.tscn")

const GROUND_Y := 700.0
const SPACING := 120.0
const START_X := 100.0
const GREEN_ZONE_WIDTH := 60.0
const GREEN_ZONE_HALF := GREEN_ZONE_WIDTH / 2.0

const TOTAL_TIME := 60.0
const FALL_START_TIME := 50.0   # when falling begins

@onready var wind_manager: Node = $WindManager
@onready var wind_label: Label = $WindLabel
@onready var result_label: Label = $ResultLabel
@onready var timer_label: Label = $TimerLabel

var devices: Array = []
var survived_count := 0
var failed_count := 0
var results := {}

var elapsed := 0.0
var falling_started := false
var game_over := false

func _ready():
	result_label.text = ""
	wind_label.text = "Wind: calm"

	for i in PLAYER_COUNT:
		var device = DEVICE_SCENE.instantiate()
		device.player_index = i
		device.controller_device_id = i
		# Center all devices vertically in the middle of the screen
		device.position = Vector2(START_X + i * SPACING, GROUND_Y / 2.0)
		device.ground_y = GROUND_Y
		device.falling = false          # start frozen
		var cx := START_X + i * SPACING
		device.green_zone_x_min = cx - GREEN_ZONE_HALF
		device.green_zone_x_max = cx + GREEN_ZONE_HALF
		add_child(device)
		device.device_failed.connect(_on_device_failed)
		device.device_survived.connect(_on_device_survived)
		devices.append(device)

	_spawn_green_zones()

func _process(delta: float):
	if game_over:
		return

	elapsed += delta
	var remaining := TOTAL_TIME - elapsed

	# --- Timer display ---
	var secs := int(remaining)
	timer_label.text = "0:%02d" % secs

	# --- Flash timer red in last 10 seconds ---
	if remaining <= 10.0:
		timer_label.modulate = Color(1, 0.2, 0.2) if int(elapsed * 4) % 2 == 0 else Color(1, 1, 1)
	
	# --- Start falling at 50 seconds ---
	if not falling_started and elapsed >= FALL_START_TIME:
		falling_started = true
		_begin_falling()

	# --- Time's up ---
	if elapsed >= TOTAL_TIME:
		game_over = true
		_force_end_all()

func _begin_falling():
	wind_label.text = "FALLING!"
	for device in devices:
		if device.alive and not device.landed:
			device.falling = true   # unlocks fall in Device.gd

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
	# Any device still alive at time's up counts as survived
	for i in PLAYER_COUNT:
		if not results.has(i):
			if devices[i].alive:
				results[i] = "survived"
				survived_count += 1
			else:
				results[i] = "failed"
	_finish()

func _check_all_done():
	if results.size() >= PLAYER_COUNT:
		game_over = true
		_finish()

func _finish():
	GameManager.egg_drop_results = results
	var summary := "Results:\n"
	for i in PLAYER_COUNT:
		var outcome: String = results.get(i, "failed")
		summary += "P%d: %s\n" % [i + 1, outcome.to_upper()]
	result_label.text = summary
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://cutscene_4.tscn")

func _spawn_green_zones():
	for i in PLAYER_COUNT:
		var zone := ColorRect.new()
		zone.color = Color(0.2, 0.9, 0.3, 0.7)
		zone.size = Vector2(GREEN_ZONE_WIDTH, 16)
		zone.position = Vector2(
			START_X + i * SPACING - GREEN_ZONE_HALF,
			GROUND_Y
		)
		add_child(zone)
