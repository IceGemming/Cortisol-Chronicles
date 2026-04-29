extends Node2D

const TOTAL_TIME := 60.0
const SEND_UNLOCK_TIME := 50.0
const TASK_LIFETIME := 5.0
const SPAWN_INTERVAL_START := 3.0
const SPAWN_INTERVAL_END := 1.2
const CURSOR_SPEED := 600.0
const BUTTON_W := 220.0
const BUTTON_H := 52.0
const TASK_AREA_MARGIN_TOP := 120.0
const TASK_AREA_MARGIN_BOTTOM := 160.0
const TASK_AREA_MARGIN_SIDE := 20.0

const ALL_TASKS := [
	"Proofread essay", "Attach resume", "Check deadline",
	"Confirm email", "Add activities list", "Write cover letter",
	"Request transcript", "Fill common app", "Ask for rec letter",
	"Update GPA section", "Review financial aid", "Submit SAT scores",
	"Check word count", "Save draft", "Verify mailing address",
	"Add extracurriculars", "Spell check", "Export as PDF",
	"Log into portal", "Check essay prompt",
]

const CURSOR_COLORS := [
	Color(1, 0.3, 0.3),
	Color(0.3, 0.8, 1),
	Color(0.3, 1, 0.4),
	Color(1, 1, 0.3),
	Color(1, 0.4, 1),
]

# Onready — all under MainCanvas/Root
@onready var task_root: Control = $MainCanvas/Root/TaskRoot
@onready var cursor_root: Control = $MainCanvas/Root/CursorRoot
@onready var timer_label: Label = $MainCanvas/Root/TopBar/TimerLabel
@onready var score_label: Label = $MainCanvas/Root/TopBar/ScoreLabel
@onready var midnight_label: Label = $MainCanvas/Root/MidnightLabel
@onready var send_button: Button = $MainCanvas/Root/SendButton
@onready var result_panel: Panel = $MainCanvas/Root/ResultPanel
@onready var result_label: Label = $MainCanvas/Root/ResultPanel/ResultLabel
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

class TaskEntry:
	var button: Button
	var time_remaining: float

var active_tasks: Array = []

class Cursor:
	var root: Control       # the Control that moves
	var pos: Vector2
	var device_id: int

var cursors: Array = []

func _ready():
	screen_size = get_viewport().get_visible_rect().size

	result_panel.hide()
	send_button.hide()
	midnight_label.text = ""
	score_label.text = "✓ 0   ✗ 0"

	available_tasks = ALL_TASKS.duplicate()
	available_tasks.shuffle()

	_build_cursors()

	send_button.pressed.connect(_on_send_pressed)
	spawn_timer.wait_time = SPAWN_INTERVAL_START
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

	# Spawn one task immediately so screen isn't empty
	_spawn_task()

# --------------- CURSORS ---------------

func _build_cursors():
	for i in 5:
		# Root control — zero size, just a position anchor
		var root := Control.new()
		root.position = Vector2(
			screen_size.x * (0.15 + i * 0.17),
			screen_size.y * 0.5
		)
		root.z_index = 10
		cursor_root.add_child(root)

		# Horizontal bar of crosshair
		var h := ColorRect.new()
		h.color = CURSOR_COLORS[i]
		h.size = Vector2(26, 3)
		h.position = Vector2(-13, -1)
		root.add_child(h)

		# Vertical bar of crosshair
		var v := ColorRect.new()
		v.color = CURSOR_COLORS[i]
		v.size = Vector2(3, 26)
		v.position = Vector2(-1, -13)
		root.add_child(v)

		# Center dot
		var dot := ColorRect.new()
		dot.color = CURSOR_COLORS[i]
		dot.size = Vector2(5, 5)
		dot.position = Vector2(-2, -2)
		root.add_child(dot)

		# Player label
		var lbl := Label.new()
		lbl.text = "P%d" % (i + 1)
		lbl.position = Vector2(10, 6)
		lbl.add_theme_color_override("font_color", CURSOR_COLORS[i])
		lbl.add_theme_font_size_override("font_size", 14)
		root.add_child(lbl)

		var c := Cursor.new()
		c.root = root
		c.pos = root.global_position
		c.device_id = i
		cursors.append(c)

# --------------- TASKS ---------------

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
	btn.size = Vector2(BUTTON_W, BUTTON_H)
	btn.position = Vector2(
		randf_range(TASK_AREA_MARGIN_SIDE, screen_size.x - BUTTON_W - TASK_AREA_MARGIN_SIDE),
		randf_range(TASK_AREA_MARGIN_TOP, screen_size.y - BUTTON_H - TASK_AREA_MARGIN_BOTTOM)
	)

	# Progress bar
	var bar := ProgressBar.new()
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false
	bar.size = Vector2(BUTTON_W, 6)
	bar.position = Vector2(0, BUTTON_H - 6)
	btn.add_child(bar)

	task_root.add_child(btn)

	var entry: TaskEntry = TaskEntry.new()
	entry.button = btn
	entry.time_remaining = TASK_LIFETIME
	active_tasks.append(entry)

	# Pop-in tween
	btn.pivot_offset = Vector2(BUTTON_W / 2.0, BUTTON_H / 2.0)
	btn.scale = Vector2(0.4, 0.4)
	var tw := create_tween()
	tw.tween_property(btn, "scale", Vector2(1, 1), 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# --------------- PROCESS ---------------

func _process(delta: float):
	if game_over:
		return

	elapsed += delta
	var remaining: float = TOTAL_TIME - elapsed
	timer_label.text = "0:%02d" % int(ceil(remaining))

	var t: float = clamp(elapsed / TOTAL_TIME, 0.0, 1.0)
	spawn_timer.wait_time = lerp(SPAWN_INTERVAL_START, SPAWN_INTERVAL_END, t)

	if remaining <= 10.0 and not send_unlocked:
		_unlock_send()

	if remaining <= 10.0:
		timer_label.modulate = Color(1, 0.15, 0.15) if int(elapsed * 4) % 2 == 0 else Color(1, 1, 1)
		shake_time += delta * 20.0
		timer_label.position.x += sin(shake_time) * 0.5
		midnight_label.text = "MIDNIGHT IS COMING!"
		midnight_label.modulate = Color(1, 0.2, 0.2) if int(elapsed * 3) % 2 == 0 else Color(0.8, 0.1, 0.1)
	elif remaining <= 20.0:
		midnight_label.text = "Hurry up..."
		midnight_label.modulate = Color(1, 0.6, 0.1)

	_process_cursors(delta)
	_tick_tasks(delta)

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
		c.root.global_position = c.pos

		if Input.is_joy_button_pressed(c.device_id, JOY_BUTTON_A):
			_try_click(c)

func _tick_tasks(delta: float):
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

func _try_click(c: Cursor):
	if send_unlocked and not sent:
		var sb_rect := Rect2(send_button.global_position, send_button.size)
		if sb_rect.has_point(c.root.global_position):
			_on_send_pressed()
			return

	for entry in active_tasks:
		var btn_rect := Rect2(entry.button.global_position, entry.button.size)
		if btn_rect.has_point(c.root.global_position):
			_on_task_pressed(entry)
			return

# --------------- TASK EVENTS ---------------

func _on_task_pressed(entry: TaskEntry):
	if game_over:
		return
	completed += 1
	score_label.text = "✓ %d   ✗ %d" % [completed, missed]
	active_tasks.erase(entry)
	entry.button.modulate = Color(0.3, 1.0, 0.4)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(entry.button):
		entry.button.queue_free()

func _expire_task(entry: TaskEntry):
	missed += 1
	score_label.text = "✓ %d   ✗ %d" % [completed, missed]
	active_tasks.erase(entry)
	entry.button.modulate = Color(1.0, 0.2, 0.2)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(entry.button):
		entry.button.queue_free()

# --------------- SEND / FINISH ---------------

func _unlock_send():
	send_unlocked = true
	send_button.show()
	var tween := create_tween().set_loops()
	tween.tween_property(send_button, "modulate", Color(1, 1, 0.2), 0.4)
	tween.tween_property(send_button, "modulate", Color(1, 0.6, 0.0), 0.4)

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

	var result_text: String
	if success:
		result_text = "APPLICATION SENT!\n\n✓ %d completed\n✗ %d missed\n\n" % [completed, missed]
		result_text += "Perfect run!" if missed == 0 else ("Good work." if completed > missed else "Chaotic, but it went out.")
	else:
		result_text = "TIME'S UP!\n\nThe application was never sent...\n\n✓ %d\n✗ %d" % [completed, missed]

	result_label.text = result_text
	result_panel.show()
	GameManager.get_tasks_score(completed, missed, sent)
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://cutscene_5.tscn")
