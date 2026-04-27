# GameManager.gd
# Add this as an Autoload in Project → Project Settings → Autoload
# Name it "GameManager" so all scripts can access it globally.

extends Node

# --- Mini-Game 1: Wire It Up ---
var wire_score := 0          # how many wires connected before time ran out

# --- Mini-Game 2: Function Frenzy ---
var exam_score := 0          # number of correct answers
var exam_total := 0          # total questions asked

# --- Mini-Game 3: Egg Drop ---
# Keyed by player_index (0–4) → "survived" or "failed"
var egg_drop_results: Dictionary = {}

# --- Mini-Game 4: Hit Send ---
var tasks_completed := 0     # how many tasks tapped in time
var tasks_missed := 0        # how many expired
var sent := false            # whether the send button was hit

# --- Scene progression ---
var current_scene_index := 0
const SCENES := [
	"res://cutscene_1.tscn",
	"res://game_1.tscn",
	"res://cutscene_2.tscn",
	"res://game_2.tscn",
	"res://cutscene_3.tscn",
	"res://game_3.tscn",
	"res://cutscene_4.tscn",
	"res://game_4.tscn",
	"res://scenes/Ending.tscn",
]

func go_to_next_scene():
	current_scene_index += 1
	if current_scene_index < SCENES.size():
		get_tree().change_scene_to_file(SCENES[current_scene_index])
	else:
		get_tree().change_scene_to_file("res://scenes/Ending.tscn")

# --- Helpers ---
func reset_all():
	wire_score = 0
	exam_score = 0
	exam_total = 0
	egg_drop_results = {}
	tasks_completed = 0
	tasks_missed = 0
	sent = false
	current_scene_index = 0

func get_egg_survivors() -> int:
	var count := 0
	for key in egg_drop_results:
		if egg_drop_results[key] == "survived":
			count += 1
	return count

func get_summary() -> String:
	return """
    Wires connected: %d
    Exam score: %d / %d
    Eggs survived: %d / 5
    Tasks completed: %d | Missed: %d | Sent: %s
	""" % [
		wire_score,
		exam_score, exam_total,
		get_egg_survivors(),
		tasks_completed, tasks_missed, str(sent)
	]
