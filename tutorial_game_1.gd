extends Node2D

# Pages for the Robot Repair tutorial - Updated text
const PAGES := [
	[
		"Robot Repair — The Goal",
		"Your team's robot is falling apart! You have 3 rounds (30 seconds each) to fix it.\n\nPlayers are divided into two competing teams: Left vs Right.\n\nRobot sprites are located at the edges of the map."
	],
	[
		"Collect the Parts",
		"Mechanical parts will fall from the sky throughout the round.\n\nRun to a part and press X to pick it up.\n\nYou can only carry one part at a time!"
	],
	[
		"Repair the Robot",
		"Carry the part to your team's robot at the edge of the map.\n\nTouch the robot sprite to attach the part automatically.\n\nThe team with the most parts attached when time runs out wins the round!"
	],
]

var current_page := 0

@onready var title_label: Label        = $Canvas/Panel/Title
@onready var body_label: Label         = $Canvas/Panel/Body
@onready var continue_label: Label     = $Canvas/Panel/ContinueLabel
@onready var page_label: Label         = $Canvas/Panel/PageLabel
@onready var diagram: Node2D           = $Canvas/Diagram
@onready var anim_timer: Timer         = $AnimTimer
@onready var animated_sprite: AnimatedSprite2D = $Canvas/Diagram/AnimatedSprite2D

# Animation variables for the robot/parts diagram
var part_y := -100.0
var player_x := -100.0
var has_part := false
var is_catching := false
var anim_time := 0.0

# Sprites (pre-loaded)
var robot_sprite = preload("res://Assets/Robot_Idle.png")
var screw_sprite = preload("res://Assets/Screw.png")
var player_sprite = preload("res://Assets/Player_Run.png") # Or use a run animation

var any_pressed := false

func _ready():
	$Canvas/Diagram.parent = self
	# Pass the preloaded sprites into the diagram so it can draw them
	$Canvas/Diagram.robot_sprite  = robot_sprite
	$Canvas/Diagram.screw_sprite  = screw_sprite
	$Canvas/Diagram.player_sprite = player_sprite
	_show_page(0)
	
	# SLOWED DOWN: The original timer was too fast.
	# Now 0.033 seconds per frame (30 FPS, vs 60 FPS before).
	anim_timer.wait_time = 0.033
	anim_timer.timeout.connect(_animate)
	anim_timer.start()

func _show_page(index: int):
	title_label.text    = PAGES[index][0]
	body_label.text     = PAGES[index][1]
	page_label.text     = "%d / %d" % [index + 1, PAGES.size()]
	continue_label.text = "Press X to continue →" if index < PAGES.size() - 1 else "Press A to start!"
	any_pressed         = false

func _process(_delta: float):
	for i in 5:
		if Input.is_joy_button_pressed(i, JOY_BUTTON_A):
			if not any_pressed:
				any_pressed = true
				_advance()
			return
	any_pressed = false

	if Input.is_action_just_pressed("ui_accept"):
		_advance()

func _advance():
	current_page += 1
	if current_page >= PAGES.size():
		get_tree().change_scene_to_file("res://game_1.tscn")
	else:
		_show_page(current_page)

func _animate():
	anim_time += 0.033
	diagram.queue_redraw()

	# --- Loop Animation ---
	
	# Phase 1: Part falls from sky
	if not has_part and not is_catching:
		# SLOWED DOWN: Now falls at 1px/frame (was 2px/frame).
		part_y += 1.0 
		
		# Start player running much earlier so they arrive as the part lands
		if part_y >= -50.0:
			player_x += 1.0 
			
			# Trigger catch when player is close to the screw's x position
			if player_x >= -5.0:
				is_catching = true
	
	# Phase 2: Catching state. 
	# A slight pause to show player catching the part before running away.
	elif is_catching:
		player_x = 0.0
		# Give a few frames for the catch look
		if int(anim_time * 10) % 5 == 0: 
			has_part = true
			is_catching = false
	
	# Phase 3: Run to the Robot
	elif has_part:
		player_x += 1.5 # Run speed
		
		# SLOWED DOWN/ FIXED: Make sure the sprite touches the robot sprite.
		if player_x >= 75.0: 
			player_x = -100.0
			part_y = -100.0
			has_part = false
