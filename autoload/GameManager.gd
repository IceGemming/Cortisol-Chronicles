# GameManager.gd
# Add this as an Autoload in Project → Project Settings → Autoload
# Name it "GameManager" so all scripts can access it globally.

extends Node

var indv_scores = {0:0,1:0,2:0,3:0,4:0}

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
	egg_drop_results = {}
	indv_scores = {0:0,1:0,2:0,3:0,4:0}
	tasks_completed = 0
	tasks_missed = 0
	sent = false

func get_egg_score():
	for i in egg_drop_results:
		if egg_drop_results[i] == "survived":
			indv_scores[i] += 10

func get_tasks_score(completed, missed, sent):
	for key in indv_scores:
		indv_scores[key] += completed - missed
		if sent == false:
			indv_scores[key] = 0
	
	for i in range(5):
		indv_scores["P"+str(i+1)] = indv_scores[i]
		indv_scores.erase(i)
	
func get_quiz_score(player_scores):
	var n = 0
	for i in player_scores:
		indv_scores[n] += player_scores[i]
		n+=1
	
