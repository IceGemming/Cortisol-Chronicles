extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 4 · Senior Year
#  Runs before Mini-Game 4 (College Apps)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://tutorial_game_4.tscn"
	YEAR_LABEL    = "Senior Year"
	YEAR_SUBTITLE = "College Applications & The Finish Line"
	CHAPTER_NUM   = "4"
	BG_TYPE       = "library"

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
			"text": "I've rewritten this college essay six times. I don't even know who I am anymore."
		},
		{
			"name": "Sai",
			"text": "I just spent three hours researching programs. What if I pick the wrong one?"
		},
		{
			"name": "Anish",
			"text": "We aren't competing against each other... but it feels like we're all racing the clock."
		},
		{
			"name": "Nilesh",
			"text": "Hey, pass me your draft. I'll edit yours if you check my deadlines. We've been doing this for four years — we aren't stopping the teamwork now."
		},
		{
			"name": "Nikunj",
			"text": "You're right. One last push. Let's hit \"send\"."
		},
		{
			"name": "Sai",
			"text": "We're standing right where we met in the gym. Everything looks the same."
		},
		{
			"name": "Nilesh",
			"text": "The gym hasn't changed. But we definitely have."
		},
	]

	super._ready()
