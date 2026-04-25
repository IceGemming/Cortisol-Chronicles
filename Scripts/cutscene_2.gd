extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 2 · Sophomore Year
#  Runs before Mini-Game 2 (Pre-Calc Exam)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://game_2.tscn"
	YEAR_LABEL    = "Sophomore Year"
	YEAR_SUBTITLE = "Pre-Calculus & The Surprise Diagnostic"
	CHAPTER_NUM   = "2"

	BG_COLOR     = Color(0.04, 0.10, 0.10, 1.0)
	PANEL_COLOR  = Color(0.05, 0.13, 0.14, 1.0)
	ACCENT_COLOR = Color(0.20, 0.85, 0.75, 1.0)

	BADGE_BG_COLOR  = Color(0.05, 0.22, 0.20, 1.0)
	YEAR_TEXT_COLOR = Color(0.88, 1.00, 0.96)
	SUB_TEXT_COLOR  = Color(0.45, 0.72, 0.68)
	CHAPTER_COLOR   = Color(0.30, 0.48, 0.46)
	COUNTER_COLOR   = Color(0.30, 0.52, 0.50)
	HINT_COLOR      = Color(0.40, 0.65, 0.62)

	DIALOGUE = [
		{
			"name": "Nilesh",
			"text": "Sophomore year! We survived the robots. Surely Pre-Calculus can't be that much harder."
		},
		{
			"name": "Nikunj",
			"text": "Don't jinx it, Nilesh."
		},
		{
			"name": "Sai",
			"text": "Wait... is she handing out a test? On day one?"
		},
		{
			"name": "Anish",
			"text": "No review? No notes? It's just us and the functions."
		},
		{
			"name": "Nilesh",
			"text": "I'm looking at question one and it's looking back at me like I've never seen a number before."
		},
		{
			"name": "Nikunj",
			"text": "Focus. If we fail this, we fail it together. But let's try not to fail."
		},
	]

	super._ready()
