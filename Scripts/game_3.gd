extends Node2D

const PLAYER_COUNT := 5
const DEVICE_SCENE := preload("res://device.tscn")

const GROUND_Y := 780.0
const GROUND_HIDDEN_Y := 900.0
const GREEN_ZONE_WIDTH := 80.0
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
var results : Dictionary = {}

var elapsed := 0.0
var falling_started := false
var game_over := false
var can_proceed := false

var screen_width: float
var spacing: float
var start_x: float

var wind_particles: CPUParticles2D
var continue_label: Label

func _ready() -> void:
	_setup_ui()
	_setup_wind_visuals()
	
	result_label.text = ""
	wind_label.text = "Wind: Calm"

	screen_width = get_viewport_rect().size.x
	spacing = screen_width / (PLAYER_COUNT + 1)
	start_x = spacing

	for i in PLAYER_COUNT:
		var device = DEVICE_SCENE.instantiate()
		device.player_index = i
		device.controller_device_id = i
		device.position = Vector2(start_x + (i * spacing), GROUND_Y / 2.0)
		device.ground_y = GROUND_Y
		device.falling = false
		
		var cx := start_x + (i * spacing)
		device.green_zone_x_min = cx - GREEN_ZONE_HALF
		device.green_zone_x_max = cx + GREEN_ZONE_HALF
		
		add_child(device)
		device.device_failed.connect(_on_device_failed)
		device.device_survived.connect(_on_device_survived)
		devices.append(device)

	_spawn_ground_and_zones()

func _setup_ui() -> void:
	var custom_font = load("res://Assets/Kenney Fonts/Fonts/Kenney Future.ttf")

	var huge_font = LabelSettings.new()
	huge_font.font = custom_font
	huge_font.font_size = 48
	huge_font.font_color = Color(1.0, 0.9, 0.2) # Yellow color
	huge_font.outline_size = 12
	huge_font.outline_color = Color.BLACK
	huge_font.shadow_size = 6
	huge_font.shadow_color = Color(0, 0, 0, 0.8)
	huge_font.shadow_offset = Vector2(3, 3)
	
	var screen_size := get_viewport_rect().size

	if timer_label: 
		timer_label.label_settings = huge_font
		timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		timer_label.z_index = 100

	if wind_label: 
		wind_label.label_settings = huge_font
		wind_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		wind_label.size.x = screen_size.x
		wind_label.position.x = 0
		wind_label.position.y = 120
		wind_label.z_index = 100

	if result_label: 
		var result_font = huge_font.duplicate()
		result_font.font_size = 64
		result_font.font_color = Color(1.0, 1.0, 1.0) # White color for results
		result_label.label_settings = result_font
		result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		result_label.size = screen_size
		result_label.position = Vector2.ZERO
		result_label.z_index = 100

	continue_label = Label.new()
	continue_label.text = "Press X to continue"
	continue_label.label_settings = huge_font
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.size.x = screen_size.x
	continue_label.position.y = screen_size.y - 80
	continue_label.z_index = 100
	continue_label.hide()
	add_child(continue_label)

func _setup_wind_visuals() -> void:
	wind_particles = CPUParticles2D.new()
	wind_particles.emitting = false
	wind_particles.amount = 60
	wind_particles.lifetime = 1.5
	wind_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	wind_particles.emission_rect_extents = Vector2(10, get_viewport_rect().size.y / 2)
	wind_particles.gravity = Vector2.ZERO
	wind_particles.scale_amount_min = 4.0
	wind_particles.scale_amount_max = 12.0
	wind_particles.color = Color(1.0, 1.0, 1.0, 0.6)
	add_child(wind_particles)

func _spawn_ground_and_zones() -> void:
	var ground_bar := ColorRect.new()
	ground_bar.color = Color(0.3, 0.2, 0.1)
	ground_bar.size = Vector2(screen_width + 400, 40)
	ground_bar.position = Vector2(-200, GROUND_HIDDEN_Y)
	ground_bar.name = "GroundBar"
	add_child(ground_bar)
	green_zones.append(ground_bar)

	for i in PLAYER_COUNT:
		var zone := ColorRect.new()
		zone.color = Color(0.2, 0.9, 0.3, 0.8)
		zone.size = Vector2(GREEN_ZONE_WIDTH, 16)
		zone.position = Vector2(
			start_x + (i * spacing) - GREEN_ZONE_HALF,
			GROUND_HIDDEN_Y - 16
		)
		add_child(zone)
		green_zones.append(zone)

func _begin_falling() -> void:
	wind_label.text = "FALLING!"
	wind_particles.emitting = false

	var tween := create_tween()
	tween.set_parallel(true)

	for node in green_zones:
		var is_ground_bar: bool = node.name == "GroundBar"
		var target_y: float = GROUND_Y if is_ground_bar else GROUND_Y - 16
		
		tween.tween_property(node, "position:y", target_y, 1.5)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(1.5).timeout
	for device in devices:
		if device.alive and not device.landed:
			device.falling = true

func _process(delta: float) -> void:
	if can_proceed:
		var pressed_x := false
		if Input.is_physical_key_pressed(KEY_X):
			pressed_x = true
		for i in 5:
			if Input.is_joy_button_pressed(i, JOY_BUTTON_A):
				pressed_x = true
		if pressed_x:
			get_tree().change_scene_to_file("res://cutscene_4.tscn")
		return

	if game_over:
		return

	elapsed += delta
	var remaining := TOTAL_TIME - elapsed

	var secs := int(ceil(remaining))
	timer_label.text = "0:%02d" % secs

	if remaining <= 10.0:
		timer_label.modulate = Color(1, 0.2, 0.2) if int(elapsed * 4) % 2 == 0 else Color(1, 1, 1)

	if not falling_started and elapsed >= FALL_START_TIME:
		falling_started = true
		_begin_falling()

	if elapsed >= TOTAL_TIME:
		game_over = true
		_force_end_all()

func _on_wind_changed(direction: float) -> void:
	if falling_started:
		return
		
	if direction > 0:
		wind_label.text = "→ WIND RIGHT →"
	elif direction < 0:
		wind_label.text = "← WIND LEFT ←"
	else:
		wind_label.text = "- CALM -"

	if direction != 0:
		wind_particles.emitting = true
		var screen_h = get_viewport_rect().size.y
		wind_particles.position.y = screen_h / 2
		
		if direction > 0:
			wind_particles.position.x = -50
			wind_particles.initial_velocity_min = 1000.0
			wind_particles.initial_velocity_max = 1400.0
		else:
			wind_particles.position.x = screen_width + 50
			wind_particles.initial_velocity_min = -1000.0
			wind_particles.initial_velocity_max = -1400.0
	else:
		wind_particles.emitting = false

	for device in devices:
		if device.alive and not device.landed:
			device.apply_wind(direction)

func _spawn_landing_dust(pos: Vector2) -> void:
	var dust = CPUParticles2D.new()
	dust.emitting = true
	dust.one_shot = true
	dust.explosiveness = 0.95
	dust.amount = 30
	dust.lifetime = 0.6
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	dust.emission_sphere_radius = 20.0
	dust.direction = Vector2(0, -1)
	dust.spread = 80.0
	dust.initial_velocity_min = 150.0
	dust.initial_velocity_max = 300.0
	dust.scale_amount_min = 4.0
	dust.scale_amount_max = 12.0
	dust.color = Color(0.8, 0.8, 0.8, 0.7)
	dust.position = pos
	
	add_child(dust)
	get_tree().create_timer(1.0).timeout.connect(dust.queue_free)

func _on_device_failed(player_index: int) -> void:
	results[player_index] = "failed"
	failed_count += 1
	_check_all_done()

func _on_device_survived(player_index: int) -> void:
	results[player_index] = "survived"
	survived_count += 1
	
	_spawn_landing_dust(Vector2(devices[player_index].position.x, GROUND_Y))
	_check_all_done()

func _force_end_all() -> void:
	for i in PLAYER_COUNT:
		if not results.has(i):
			results[i] = "survived" if devices[i].alive else "failed"
			if results[i] == "survived":
				survived_count += 1
	_finish()

func _check_all_done() -> void:
	if results.size() >= PLAYER_COUNT:
		game_over = true
		_finish()

func _finish() -> void:
	wind_particles.emitting = false
	wind_label.hide()
	GameManager.egg_drop_results = results
	var summary := "Results:\n"
	for i in PLAYER_COUNT:
		summary += "P%d: %s\n" % [i + 1, results.get(i, "failed").to_upper()]
	result_label.text = summary
	
	if survived_count > 0:
		var confetti = get_node_or_null("CPUParticles2D")
		if confetti:
			confetti.emitting = true

	await get_tree().create_timer(1.5).timeout
	continue_label.show()
	can_proceed = true
