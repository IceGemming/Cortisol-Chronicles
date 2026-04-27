# EggDropGame.gd
# Root script — spawns 5 devices, wires wind, tracks results.

extends Node2D

const PLAYER_COUNT := 5
const DEVICE_SCENE := preload("res://Device.tscn")

# Visual layout
const START_Y := -100.0
const GROUND_Y := 700.0
const SPACING := 120.0           # horizontal gap between devices
const START_X := 100.0

# Green zone on the ground (centered, fairly forgiving)
const GREEN_ZONE_WIDTH := 60.0
const GREEN_ZONE_HALF := GREEN_ZONE_WIDTH / 2.0

@onready var wind_manager: Node = $WindManager
@onready var wind_label: Label = $WindLabel
@onready var result_label: Label = $ResultLabel
@onready var ground_sprite: Node2D = $Ground

var devices: Array[Node2D] = []
var survived_count := 0
var failed_count := 0
var results := {}  # player_index -> "survived" | "failed"

func _ready():
	result_label.text = ""
	wind_label.text = "Wind: calm"

	for i in PLAYER_COUNT:
		var device: Node2D = DEVICE_SCENE.instantiate()
		device.player_index = i
		device.controller_device_id = i  # player 0 = joypad 0, etc.
		device.position = Vector2(START_X + i * SPACING, START_Y)
		device.ground_y = GROUND_Y
		# Each device has its own green zone centered below it
		var cx := START_X + i * SPACING
		device.green_zone_x_min = cx - GREEN_ZONE_HALF
		device.green_zone_x_max = cx + GREEN_ZONE_HALF
		add_child(device)
		device.device_failed.connect(_on_device_failed)
		device.device_survived.connect(_on_device_survived)
		devices.append(device)
	
	_spawn_green_zones()

func _on_wind_changed(direction: float):
	var dir_text := "→ RIGHT" if direction > 0 else "← LEFT"
	wind_label.text = "Wind: %s" % dir_text
	# Push wind to all living devices
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

func _check_all_done():
	if results.size() < PLAYER_COUNT:
		return
	# All done — show summary
	var summary := "Results:\n"
	for i in PLAYER_COUNT:
		var outcome: String = results.get(i, "failed")
		summary += "P%d: %s\n" % [i + 1, outcome.to_upper()]
	result_label.text = summary
	# Save to GameManager and move on after delay
	GameManager.egg_drop_results = results
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
