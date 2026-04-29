extends Node2D

const PAGES := [
	[
		"College Apps — How It Works",
        "It's midnight before your deadlines and everyone is scrambling.\n\nTasks will appear as buttons scattered all over the screen.\n\nYou have 60 seconds to complete as many as possible before time runs out."
	],
	[
		"Move Your Cursor",
        "Each player controls their own colored crosshair cursor.\n\nUse the LEFT STICK on your controller to move it around the screen.\n\nYour cursor color:\n  P1 — Red\n  P2 — Blue\n  P3 — Green\n  P4 — Yellow\n  P5 — Purple"
	],
	[
		"Click Tasks Before They Expire",
        "Each task is timed.\n\nWhen the timer hits zero the task disappears and counts as MISSED.\n\nMove your cursor over a task and press X to complete it!"
	],
	[
		"Hit Send Before Midnight!",
        "With 10 seconds left a glowing SEND button appears at the bottom of the screen.\n\nAt least one player must move their cursor to it and press X to submit the application.\n\nIf nobody hits SEND before time runs out, the application is lost!\n\nWork together to complete tasks AND make sure someone hits Send!"
	],
]

var current_page := 0
var any_pressed  := false
var anim_time    := 0.0

@onready var title_label:    Label = $Canvas/Panel/Title
@onready var body_label:     Label = $Canvas/Panel/Body
@onready var continue_label: Label = $Canvas/Panel/ContinueLabel
@onready var page_label:     Label = $Canvas/Panel/PageLabel
@onready var anim_timer:     Timer = $AnimTimer

func _ready():
	$Canvas/Diagram.parent = self
	_show_page(0)
	anim_timer.wait_time = 0.016
	anim_timer.timeout.connect(_animate)
	anim_timer.start()

func _show_page(index: int):
	title_label.text    = PAGES[index][0]
	body_label.text     = PAGES[index][1]
	page_label.text     = "%d / %d" % [index + 1, PAGES.size()]
	continue_label.text = "Press A to continue →" if index < PAGES.size() - 1 else "Press A to start!"
	any_pressed         = false

func _process(_delta: float):
	if Input.is_action_just_pressed("ui_accept"):
		_advance()

func _advance():
	current_page += 1
	if current_page >= PAGES.size():
		get_tree().change_scene_to_file("res://game_4.tscn")
	else:
		_show_page(current_page)

func _retreat():
	if current_page <= 0:
		current_page = 0
	current_page -= 1
	_show_page(current_page)

func _animate():
	anim_time += 0.016
	$Canvas/Diagram.queue_redraw()
