extends Node2D

const PAGES := [
	[
		"How It Works",
		"A visual prompt will appear above your character showing a specific controller button.\n\nYou must press that exact button as fast as you can!"
	],
	[
		"Don't Be Last",
		"Accuracy and speed are critical.\n\nIf you press the WRONG button, you fail the round.\n\nIf you press the right button, but you are the SLOWEST player to do so, you also fail!"
	],
	[
		"Scoring Points",
		"Everyone who presses the correct button (except if you are the slowest person) gets a point.\n\nThe response time limit shrinks as the game goes on, from 3 seconds down to 1 second.\n\nThe player with the most points when the game ends wins!"
	]
]

var current_page := 0

@onready var title_label: Label        = $Canvas/Panel/Title
@onready var body_label: Label         = $Canvas/Panel/Body
@onready var continue_label: Label     = $Canvas/Panel/ContinueLabel
@onready var page_label: Label         = $Canvas/Panel/PageLabel
@onready var diagram: Node2D           = $Canvas/Diagram
@onready var anim_timer: Timer         = $AnimTimer

var anim_time := 0.0
var diagram_state := "prompt" 
var active_button := "A"
var button_color := Color(0.2, 0.8, 0.2)
var timer_scale := 1.0

var any_pressed := false

func _ready() -> void:
	$Canvas/Diagram.parent = self  
	_show_page(0)
	anim_timer.wait_time = 0.016
	anim_timer.timeout.connect(_animate)
	anim_timer.start()

func _show_page(index: int) -> void:
	title_label.text    = PAGES[index][0]
	body_label.text     = PAGES[index][1]
	page_label.text     = "%d / %d" % [index + 1, PAGES.size()]
	continue_label.text = "Press A to continue →" if index < PAGES.size() - 1 else "Press A to start!"
	any_pressed         = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_advance()

func _advance() -> void:
	current_page += 1
	if current_page >= PAGES.size():
		get_tree().change_scene_to_file("res://mini_game_2.tscn")
	else:
		_show_page(current_page)

func _retreat():
	if current_page <= 0:
		current_page = 0
	current_page -= 1
	_show_page(current_page)

func _animate() -> void:
	anim_time += 0.016
	diagram.queue_redraw()

	var full_loop = fmod(anim_time, 8.0)
	
	if full_loop < 2.0:
		# Example 1: Prompt leading to Correct
		diagram_state = "prompt"
		timer_scale = 1.0 - (full_loop / 2.0)
		active_button = "A"
		button_color = Color(0.2, 0.8, 0.2)
	elif full_loop < 4.0:
		# Example 1: Result
		diagram_state = "correct"
		timer_scale = 0.0
	elif full_loop < 6.0:
		# Example 2: Prompt leading to Slow
		diagram_state = "prompt"
		timer_scale = 1.0 - ((full_loop - 4.0) / 2.0)
		active_button = "B"
		button_color = Color(0.8, 0.2, 0.2)
	else:
		# Example 2: Result
		diagram_state = "slow"
		timer_scale = 0.0
