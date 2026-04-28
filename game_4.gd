extends Node2D

const TOTAL_TIME := 60.0
const SEND_UNLOCK_TIME := 50.0
const TASK_LIFETIME := 5.0
const SPAWN_INTERVAL_START := 3.0
const SPAWN_INTERVAL_END := 1.2
const CURSOR_SPEED := 600.0

const ALL_TASKS := [
	"Proofread essay", "Attach resume", "Check deadline",
	"Confirm email", "Add activities list", "Write cover letter",
	"Request transcript", "Fill common app", "Ask for rec letter",
	"Update GPA section", "Review financial aid", "Submit SAT scores",
	"Check word count", "Save draft", "Verify mailing address",
	"Add extracurriculars", "Spell check", "Export as PDF",
	"Log into portal", "Check essay prompt",
]

# Cursor colors for each player
const CURSOR_COLORS := [
	Color(1, 0.3, 0.3),    # P1 red
	Color(0.3, 0.8, 1),    # P2 blue
	Color(0.3, 1, 0.4),    # P3 green
	Color(1, 1, 0.3),      # P4 yellow
	Color(1, 0.4, 1),      # P5 purple
]

# Safe area for task buttons — keep away from UI edges
const TASK_AREA_MARGIN_TOP := 120.0
const TASK_AREA_MARGIN_BOTTOM := 160.0  # leave room for send button
const TASK_AREA_MARGIN_SIDE := 20.0
const BUTTON_W := 220.0
const BUTTON_H := 52.0

@onready var timer_label: Label = $UI/TopBar/TimerLabel
@onready var score_label: Label = $UI/TopBar/ScoreLabel
@onready var midnight_label: Label = $UI/MidnightLabel
@onready var send_button: Button = $UI/SendButton
@onready var result_panel: Panel = $UI/ResultPanel
@onready var result_label: Label = $UI/ResultPanel/ResultLabel
@onready var task_layer: Node2D = $TaskLayer    # buttons spawn here
@onready var cursor_layer: Node2D = $CursorLayer
@onready var spawn_timer: Timer = $SpawnTimer

var screen_size: Vector2
var elapsed: float = 0.0
var completed: int = 0
var missed: int = 0
var sent: bool = false
var game_over: bool = false
var send_unlocked: bool = false
var shake_time: float = 0.0

var available_tasks: Array = []
var cursors: Array = []       # array of Node2D cursor sprites

class TaskEntry:
	var button: Button
	var time_remaining: float
	var task_text: String

var active_tasks: Array = []

# --- Cursor class ---
class Cursor:
	var node: Node2D
	var pos: Vector2
	var device_id: int
	var color: Color
	var label: Label

func _ready():
	screen_size = get_viewport().get_visible_rect().size

	result_panel.hide()
	send_button.hide()
	midnight_label.text = ""

	available_tasks = ALL_TASKS.duplicate()
	available_tasks.shuffle()

	_spawn_cursors()

	send_button.pressed.connect(_on_send_pressed)
	spawn_timer.wait_time = SPAWN_INTERVAL_START
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	_spawn_task()

func _spawn_cursors():
	for i in 5:
		var cursor_node := Node2D.new()

		# Crosshair drawn with Line2Ds
		var h := Line2D.new()
		h.points = [Vector2(-12, 0), Vector2(12, 0)]
		h.width = 2.5
		h.default_color = CURSOR_COLORS[i]
		cursor_node.add_child(h)

		var v := Line2D.new()
		v.points = [Vector2(0, -12), Vector2(0, 12)]
		v.width = 2.5
		v.default_color = CURSOR_COLORS[i]
		cursor_node.add_child(v)

		# Small circle center
		var dot := Line2D.new()
		dot.default_color = CURSOR_COLORS[i]
		dot.width = 4.0
		var pts: Array[Vector2] = []
		for a in range(0, 361, 20):
			pts.append(Vector2(cos(deg_to_rad(a)), sin(deg_to_rad(a))) * 4.0)
		dot.points = pts
		cursor_node.add_child(dot)

		# Player label under cursor
		var lbl := Label.new()
		lbl.text = "P%d" % (i + 1)
		lbl.position = Vector2(8, 8)
		lbl.add_theme_color_override("font_color", CURSOR_COLORS[i])
		lbl.add_theme_font_size_override("font_size", 13)
		cursor_node.add_child(lbl)

		# Start spread out so cursors don't stack
		cursor_node.position = Vector2(
			screen_size.x * 0.2 + i * (screen_size.x * 0.15),
			screen_size.y * 0.5
		)
		cursor_layer.add_child(cursor_node)

		var c := Cursor.new()
		c.node = cursor_node
		c.pos = cursor_node.position
		c.device_id = i
		c.color = CURSOR_COLORS[i]
		cursors.append(c)

func _process(delta: float):
	if game_over:
		return

	elapsed += delta
	var remaining: float = TOTAL_TIME - elapsed
	var secs: int = int(ceil(remaining))
	timer_label.text = "0:%02d" % secs

	# Speed up spawning
	var t: float = clamp(elapsed / TOTAL_TIME, 0.0, 1.0)
	spawn_timer.wait_time = lerp(SPAWN_INTERVAL_START, SPAWN_INTERVAL_END, t)

	# Last 10 seconds
	if remaining <= TOTAL_TIME - SEND_UNLOCK_TIME and not send_unlocked:
		_unlock_send()
	if remaining <= 10.0:
		timer_label.modulate = Color(1, 0.15, 0.15) if int(elapsed * 4) % 2 == 0 else Color(1, 1, 1)
		shake_time += delta * 20.0
		timer_label.position.x = sin(shake_time) * 3.0
		midnight_label.text = "MIDNIGHT IS COMING!"
		midnight_label.modulate = Color(1, 0.2, 0.2) if int(elapsed * 3) % 2 == 0 else Color(0.8, 0.1, 0.1)
	elif remaining <= 20.0:
		midnight_label.text = "Hurry up..."
		midnight_label.modulate = Color(1, 0.6, 0.1)

	# Move cursors
	_process_cursors(delta)

	# Tick task lifetimes
	var expired: Array = []
	for entry in active_tasks:
		entry.time_remaining -= delta
		if entry.button.has_node("ProgressBar"):
			var bar: ProgressBar = entry.button.get_node("ProgressBar")
			bar.value = (entry.time_remaining / TASK_LIFETIME) * 100.0
			var pct: float = entry.time_remaining / TASK_LIFETIME
			bar.modulate = Color(1.0, pct, 0.0)
		if entry.time_remaining <= 0.0:
			expired.append(entry)
	for entry in expired:
		_expire_task(entry)

	if elapsed >= TOTAL_TIME:
		game_over = true
		if not sent:
			_finish(false)

func _process_cursors(delta: float):
	for c in cursors:
		var joy_x: float = Input.get_joy_axis(c.device_id, JOY_AXIS_LEFT_X)
		var joy_y: float = Input.get_joy_axis(c.device_id, JOY_AXIS_LEFT_Y)

		if abs(joy_x) < 0.15: joy_x = 0.0
		if abs(joy_y) < 0.15: joy_y = 0.0

		c.pos += Vector2(joy_x, joy_y) * CURSOR_SPEED * delta
		c.pos.x = clamp(c.pos.x, 0.0, screen_size.x)
		c.pos.y = clamp(c.pos.y, 0.0, screen_size.y)
		c.node.position = c.pos

		# A button (joypad button 0) = click
		if Input.is_joy_button_pressed(c.device_id, JOY_BUTTON_A):
			_try_click(c)

func _try_click(c: Cursor):
	# Check send button first
	if send_unlocked and not sent:
		var sb_rect := Rect2(send_button.global_position, send_button.size)
		if sb_rect.has_point(c.pos):
			_on_send_pressed()
			return

	# Check task buttons
	for entry in active_tasks:
		var btn: Button = entry.button
		var btn_rect := Rect2(btn.global_position, btn.size)
		if btn_rect.has_point(c.pos):
			_on_task_pressed(entry)
			return

func _unlock_send():
	send_unlocked = true
	send_button.show()
	var tween := create_tween().set_loops()
	tween.tween_property(send_button, "modulate", Color(1, 1, 0.2), 0.4)
	tween.tween_property(send_button, "modulate", Color(1, 0.6, 0.0), 0.4)

func _on_spawn_timer_timeout():
	if not game_over:
		_spawn_task()

func _spawn_task():
	if available_tasks.is_empty():
		available_tasks = ALL_TASKS.duplicate()
		available_tasks.shuffle()

	var task_text: String = available_tasks.pop_back()

	var btn := Button.new()
	btn.text = task_text
	btn.custom_minimum_size = Vector2(BUTTON_W, BUTTON_H)
	btn.size = Vector2(BUTTON_W, BUTTON_H)

	# Random position within safe area
	var rx: float = randf_range(
		TASK_AREA_MARGIN_SIDE,
		screen_size.x - BUTTON_W - TASK_AREA_MARGIN_SIDE
	)
	var ry: float = randf_range(
		TASK_AREA_MARGIN_TOP,
		screen_size.y - BUTTON_H - TASK_AREA_MARGIN_BOTTOM
	)
	btn.position = Vector2(rx, ry)

	# Progress bar
	var bar := ProgressBar.new()
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(BUTTON_W, 6)
	bar.position = Vector2(0, BUTTON_H - 6)
	btn.add_child(bar)

	task_layer.add_child(btn)

	var entry: TaskEntry = TaskEntry.new()
	entry.button = btn
	entry.time_remaining = TASK_LIFETIME
	entry.task_text = task_text
	active_tasks.append(entry)

	# Animate in with a quick scale pop
	btn.scale = Vector2(0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_task_pressed(entry: TaskEntry):
	if game_over:
		return
	completed += 1
	_update_score()
	active_tasks.erase(entry)
	entry.button.modulate = Color(0.3, 1.0, 0.4)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(entry.button):
		entry.button.queue_free()

func _expire_task(entry: TaskEntry):
	missed += 1
	_update_score()
	active_tasks.erase(entry)
	entry.button.modulate = Color(1.0, 0.2, 0.2)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(entry.button):
		entry.button.queue_free()

func _update_score():
	score_label.text = "✓ %d   ✗ %d" % [completed, missed]

func _on_send_pressed():
	if game_over or not send_unlocked:
		return
	sent = true
	game_over = true
	spawn_timer.stop()
	_finish(true)

func _finish(success: bool):
	spawn_timer.stop()
	for entry in active_tasks:
		if is_instance_valid(entry.button):
			entry.button.queue_free()
	active_tasks.clear()

	GameManager.tasks_completed = completed
	GameManager.tasks_missed = missed
	GameManager.sent = sent

	var result_text: String = ""
	if success:
		result_text = "APPLICATION SENT!\n\n✓ Completed: %d\n✗ Missed: %d\n\n" % [completed, missed]
		if missed == 0:
			result_text += "Perfect run!"
		elif completed > missed:
			result_text += "Good work — mostly on top of it."
		else:
			result_text += "Chaotic, but it went out."
	else:
		result_text = "TIME'S UP!\n\nThe application was never sent...\n\n✓ Completed: %d\n✗ Missed: %d" % [completed, missed]

	result_label.text = result_text
	result_panel.show()
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://ending.tscn")
