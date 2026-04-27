# WindManager.gd
# Attach as a child of EggDropGame, or add as Autoload.
# Emits wind_changed(direction: float) every few seconds.
# direction: +1.0 = blowing right, -1.0 = blowing left

extends Node

signal wind_changed(direction: float)

@export var min_interval := 2.0
@export var max_interval := 5.0
@export var wind_strength := 200.0  # pixels/sec of angular push

var current_direction := 1.0
@onready var timer := $WindTimer

func _ready():
	timer.wait_time = randf_range(min_interval, max_interval)
	timer.start()


func _on_wind_timer_timeout() -> void:
	print('time')
	# Randomly flip or keep direction
	current_direction = 1.0 if randf() > 0.5 else -1.0
	emit_signal("wind_changed", current_direction)
	timer.wait_time = randf_range(min_interval, max_interval)
	timer.start()
