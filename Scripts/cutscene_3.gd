extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 3 · Junior Year
#  Runs before Mini-Game 3 (The Egg Drop)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://game_3.tscn"
	YEAR_LABEL    = "Junior Year"
	YEAR_SUBTITLE = "Physics & The Egg Drop Project"
	CHAPTER_NUM   = "3"
	BG_TYPE       = "rooftop"

	BG_COLOR     = Color(0.10, 0.06, 0.03, 1.0)
	PANEL_COLOR  = Color(0.14, 0.08, 0.04, 1.0)
	ACCENT_COLOR = Color(1.00, 0.65, 0.10, 1.0)

	BADGE_BG_COLOR  = Color(0.25, 0.15, 0.03, 1.0)
	YEAR_TEXT_COLOR = Color(1.00, 0.95, 0.80)
	SUB_TEXT_COLOR  = Color(0.78, 0.60, 0.30)
	CHAPTER_COLOR   = Color(0.45, 0.35, 0.18)
	COUNTER_COLOR   = Color(0.50, 0.38, 0.20)
	HINT_COLOR      = Color(0.70, 0.52, 0.25)

	DIALOGUE = [
		{
			"name": "Anish",
			"text": "Okay, junior year. Physics. This is the big one: The Egg Drop."
		},
		{
			"name": "Nikunj",
			"text": "I'm going bold. High-impact absorption. If it doesn't bounce, it's over."
		},
		{
			"name": "Sai",
			"text": "I'm sticking to stability. If the structure is sound, the egg stays safe."
		},
		{
			"name": "Nilesh",
			"text": "I went a little... unconventional. It's either going to be a genius move or a giant omelet on the pavement."
		},
		{
			"name": "Anish",
			"text": "I've optimized the weight-to-protection ratio. All we can do now is let go."
		},
		{
			"name": "Sai",
			"text": "Three... two... one... drop!"
		},
	]

	super._ready()
