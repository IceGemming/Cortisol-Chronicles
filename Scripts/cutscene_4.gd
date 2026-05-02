extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 4 · Senior Year
#  Runs before Mini-Game 4 (College Apps)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://tutorial_game_4.tscn"
	YEAR_LABEL    = "Senior Year"
	YEAR_SUBTITLE = "College Applications"
	CHAPTER_NUM   = "7"
	BG_TYPE       = ""

	BG_COLOR     = Color(0.08, 0.04, 0.12, 1.0)
	PANEL_COLOR  = Color(0.11, 0.05, 0.17, 1.0)
	ACCENT_COLOR = Color(0.78, 0.40, 1.00, 1.0)

	BADGE_BG_COLOR  = Color(0.18, 0.08, 0.26, 1.0)
	YEAR_TEXT_COLOR = Color(0.95, 0.88, 1.00)
	SUB_TEXT_COLOR  = Color(0.62, 0.42, 0.80)
	CHAPTER_COLOR   = Color(0.38, 0.22, 0.52)
	COUNTER_COLOR   = Color(0.42, 0.28, 0.55)
	HINT_COLOR      = Color(0.58, 0.40, 0.75)

	DIALOGUE = [
		{
			"name": "Nikunj",
			"text": "I've rewritten this essay like six times. I don't even know what I'm typing anymore."
		},
		{
			"name": "Sai",
			"text": "Bro I just spent three hours staring at the Activities list, The deadline is literally tonight."
		},
		{
			"name": "Anish",
			"text": "We should probably not wait till 11:59 right?"
		},
		{
			"name": "Nilesh",
			"text": "Probably, Let's just finish these tasks and hit submit before that."
		},
		{
			"name": "Nikunj",
			"text": "Yeah lets go."
		},
	]

	super._ready()
