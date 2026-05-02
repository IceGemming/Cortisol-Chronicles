extends Node2D

# Pages of the tutorial, each entry is [title, body_text]
const PAGES := [
	[
		"Egg Drop",
        "You and your team are dropping fragile science projects from a great height.\n\nFor the first 50 seconds your projects float in mid-air while the wind tries to knock them over.\n\nIn the final 10 seconds, they fall toward the landing zone below."
	],
	[
		"Watch the Wind",
        "Every few seconds a gust of wind will blow LEFT or RIGHT.\n\nThe wind will push your project and make it tilt.\n\nIf your project tilts past 40 degrees, it topples and you're out!\n\nWatch the wind indicator at the top of the screen."
	],
	[
		"Use Your Joystick",
        "Each player uses their own controller.\n\nMove the LEFT STICK in the OPPOSITE direction of the wind to keep your project upright.\n\nWind blowing RIGHT?  Push your stick LEFT.\nWind blowing LEFT?  Push your stick RIGHT.\n\nStay balanced for the full minute to survive!"
	],
	[
		"The Landing",
        "When the last 10 seconds begin, your project starts to fall.\n\nThe ground will rise up to meet you.\n\nLand inside the GREEN ZONE to survive.\n\nTip over and your egg is scrambled.\n\nGood luck!"
	],
]

var current_page := 0

@onready var title_label: Label        = $Canvas/Panel/Title
@onready var body_label: Label         = $Canvas/Panel/Body
@onready var continue_label: Label     = $Canvas/Panel/ContinueLabel
@onready var page_label: Label         = $Canvas/Panel/PageLabel
@onready var diagram: Node2D           = $Canvas/Diagram
@onready var anim_timer: Timer         = $AnimTimer

# Diagram animation
var wind_x := 0.0
var wind_dir := 1.0
var project_tilt := 0.0
var arrow_alpha := 1.0
var anim_time := 0.0

# Any button on any controller advances
var any_pressed := false

func _ready():
	$Canvas/Diagram.parent = self   # give diagram access to anim vars
	_show_page(0)
	anim_timer.wait_time = 0.016
	anim_timer.timeout.connect(_animate)
	anim_timer.start()

func _show_page(index: int):
	title_label.text    = PAGES[index][0]
	body_label.text     = PAGES[index][1]
	page_label.text     = "%d / %d" % [index + 1, PAGES.size()]
	continue_label.text = "Press X to continue →" if index < PAGES.size() - 1 else "Press A to start!"
	any_pressed         = false

func _process(_delta: float):
	# Also allow keyboard for testing
	if Input.is_action_just_pressed("ui_accept"):
		_advance()

func _advance():
	current_page += 1
	if current_page >= PAGES.size():
		get_tree().change_scene_to_file("res://game_3.tscn")
	else:
		_show_page(current_page)

func _retreat():
	if current_page <= 0:
		current_page = 0
	current_page -= 1
	_show_page(current_page)

func _animate():
	anim_time += 0.016

	# Diagram shows a tilting box being pushed by wind arrows
	diagram.queue_redraw()

	# Oscillate wind every 2 seconds
	if int(anim_time) % 4 < 2:
		wind_dir = 1.0
	else:
		wind_dir = -1.0

	project_tilt = lerp(project_tilt, wind_dir * 20.0, 0.05)
	arrow_alpha  = abs(sin(anim_time * 2.0))
	

func _draw_diagram(draw: Node2D):
	pass  # handled below via Diagram node's _draw
