extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 2 · Sophomore Year
#  Runs before Mini-Game 2 (Pre-Calc Exam)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://tutorial_game_2.tscn"
	YEAR_LABEL    = "Sophomore Year"
	YEAR_SUBTITLE = "Pre-Calculus (The Trignometry Test)"
	CHAPTER_NUM   = "3"
	
	# Leave this empty to disable the AI image background
	BG_TYPE       = ""

	# Set the alpha (4th value) to 1.0 for a solid dark background
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
			"text": "Sophomore year, let's go. So there's no way Pre-Calc is that bad, right?"
		},
		{
			"name": "Nikunj",
			"text": "I mean it's not like we took geometry last year and aren't skipping math levels."
		},
		{
			"name": "Sai",
			"text": "Wait... is she literally handing out a pop quiz right now? Out of nowhere?"
		},
		{
			"name": "Anish",
			"text": "No warning? No study time?"
		},
		{
			"name": "Nilesh",
			"text": "Stop acting like you would have used the time to study Anish"
		},
		{
			"name": "Nikunj",
			"text": "Alright, focus up. Just answer as fast as you can."
		},
	]

	super._ready()
