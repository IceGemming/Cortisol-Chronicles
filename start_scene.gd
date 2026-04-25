extends Node2D
class_name StartScene

const ANALOG_DEADZONE: float = 0.2

@export var cursor_speed: float = 600.0

@onready var start_button: Button = $Button
@onready var cursor_sprite: Sprite2D = $CursorLayer/CursorSprite

var cursor_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	cursor_position = _get_viewport_center()
	cursor_sprite.global_position = cursor_position

func _process(delta: float) -> void:
	_update_cursor(delta)
	_update_button_state()

func _update_cursor(delta: float) -> void:
	var movement: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	movement += _get_analog_input()
	if movement.length() > 1.0:
		movement = movement.normalized()
	cursor_position += movement * cursor_speed * delta
	cursor_position = _clamp_to_viewport(cursor_position)
	cursor_sprite.global_position = cursor_position

func _get_analog_input() -> Vector2:
	var analog: Vector2 = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))
	if abs(analog.x) < ANALOG_DEADZONE:
		analog.x = 0.0
	if abs(analog.y) < ANALOG_DEADZONE:
		analog.y = 0.0
	return analog

func _clamp_to_viewport(position: Vector2) -> Vector2:
	var rect: Rect2 = get_viewport().get_visible_rect()
	position.x = clamp(position.x, rect.position.x, rect.position.x + rect.size.x)
	position.y = clamp(position.y, rect.position.y, rect.position.y + rect.size.y)
	return position

func _get_viewport_center() -> Vector2:
	var rect: Rect2 = get_viewport().get_visible_rect()
	return rect.position + rect.size * 0.5

func _update_button_state() -> void:
	var button_rect: Rect2 = start_button.get_global_rect()
	var is_over_button: bool = button_rect.has_point(cursor_position)
	if is_over_button:
		if not start_button.has_focus():
			start_button.grab_focus()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game_1_multi.tscn")
