# GameManager.gd
# Add this as an Autoload in Project → Project Settings → Autoload
# Name it "GameManager" so all scripts can access it globally.

extends Node

var indv_scores : Dictionary = {}

# --- Mini-Game 1: Wire It Up ---
var wire_score := 0          # how many wires connected before time ran out

# --- Mini-Game 2: Function Frenzy ---
var minigame_2_history: Array = [] # Stores array of round dictionaries

# --- Mini-Game 3: Egg Drop ---
# Keyed by player_index (0–4) → "survived" or "failed"
var egg_drop_results: Dictionary = {}

# --- Mini-Game 4: Hit Send ---
var tasks_completed := 0     # how many tasks tapped in time
var tasks_missed := 0        # how many expired
var sent := false            # whether the send button was hit

# --- Helpers ---
func reset_all():
	wire_score = 0
	egg_drop_results = {}
	indv_scores = {}
	tasks_completed = 0
	tasks_missed = 0
	sent = false

func get_egg_score():
	for key in egg_drop_results:
		if egg_drop_results[key] == "survived":
			indv_scores[key] += 10
	print(indv_scores)

func get_tasks_score(completed, missed, sent):
	for key in indv_scores:
		indv_scores[key] += completed - missed
		if sent == false:
			indv_scores[key] = 0
	
func get_quiz_score(player_scores):
	for key in player_scores:
		if indv_scores.has(key):
			indv_scores[key] += player_scores[key]

func print_scores() -> void:
	print("┌─────────────────────────┐")
	print("│       SCOREBOARD        │")
	print("├──────────────┬──────────┤")
	for player in indv_scores:
		var line := "│ %-12s │ %8s │" % [player, str(indv_scores[player])]
		print(line)
	print("└──────────────┴──────────┘")
	
