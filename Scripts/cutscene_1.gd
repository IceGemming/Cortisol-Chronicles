extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 1 · Freshman Year
#  Runs before Mini-Game 1 (Robotics Challenge)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://game_1.tscn"
	YEAR_LABEL    = "Freshman Year"
	YEAR_SUBTITLE = "The Orientation & Robotics Club"
	CHAPTER_NUM   = "1"

	BG_COLOR     = Color(0.04, 0.06, 0.18, 1.0)
	PANEL_COLOR  = Color(0.06, 0.08, 0.24, 1.0)
	ACCENT_COLOR = Color(0.35, 0.50, 1.00, 1.0)

	BADGE_BG_COLOR  = Color(0.12, 0.16, 0.42, 1.0)
	YEAR_TEXT_COLOR = Color(0.92, 0.92, 1.00)
	SUB_TEXT_COLOR  = Color(0.60, 0.65, 0.88)
	CHAPTER_COLOR   = Color(0.40, 0.42, 0.60)
	COUNTER_COLOR   = Color(0.45, 0.48, 0.65)
	HINT_COLOR      = Color(0.55, 0.60, 0.80)

	DIALOGUE = [
		{
			"name": "Nikunj",
			"text": "Does this schedule actually make sense to anyone? I feel like I was just dropped into the middle of a movie without the script."
		},
		{
			"name": "Sai",
			"text": "I think you're holding the script for my life, actually. That's my schedule."
		},
		{
			"name": "Nikunj",
			"text": "Oh! My bad. I'm Nikunj."
		},
		{
			"name": "Anish",
			"text": "Did I hear someone say Period 2 Geometry? I'm Anish. I'm already lost."
		},
		{
			"name": "Nilesh",
			"text": "Join the club. I've been staring at this map for ten minutes and I'm pretty sure this building doesn't exist."
		},
		{
			"name": "Nikunj",
			"text": "Well, at least we're lost together. Look, there's a club fair today. Should we just... go?"
		},
		{
			"name": "Anish",
			"text": "Look at that robot. \"Monta Vista Robotics Team.\" We have no idea what we're doing, right?"
		},
		{
			"name": "Sai",
			"text": "None at all. Let's do it."
		},
	]

	super._ready()
