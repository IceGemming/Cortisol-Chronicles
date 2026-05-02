# WindManager.gd
extends Node

signal wind_changed(direction: float)

@export var min_interval := 2.0
@export var max_interval := 5.0
@export var start_wind_strength := 250.0
@export var max_wind_strength := 60.0 

var wind_strength := 0.0
var last_direction := 1.0
var current_direction := 1.0
var elapsed_time := 0.0

@onready var timer := $WindTimer

func _ready() -> void:
	wind_strength = start_wind_strength
	timer.wait_time = randf_range(min_interval, max_interval)
	timer.start()

func _process(delta: float) -> void:
	elapsed_time += delta
	var progress: float = clampf(elapsed_time / 50.0, 0.0, 1.0)
	wind_strength = lerpf(max_wind_strength, start_wind_strength, progress)

func _on_wind_timer_timeout() -> void:
	if randf() < 0.3:
		current_direction = 0.0
		timer.wait_time = randf_range(1.0, 2.0)
	else:
		current_direction = 1.0 if last_direction == -1.0 else -1.0
		last_direction = current_direction
		timer.wait_time = randf_range(min_interval, max_interval)
		
	emit_signal("wind_changed", current_direction)
	timer.start()
