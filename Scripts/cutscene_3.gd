extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 3 · Junior Year
#  Runs before Mini-Game 3 (The Egg Drop)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://tutorial_game_3.tscn"
	YEAR_LABEL    = "Junior Year"
	YEAR_SUBTITLE = "AP Physics 1 (The Egg Drop)"
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
			"text": "Hey, are you guys ready for the egg drop today?"
		},
		{
			"name": "Nikunj",
			"text": "Kinda, I'm just praying my crumple zone works. If it doesn't, I am cooked."
		},
		{
			"name": "Sai",
			"text": "I literally just wrapped mine in a whole roll of duct tape and straws."
		},
		{
			"name": "Nilesh",
			"text": "Mine looks terrible, not gonna lie. The egg is probably breaking before my vehicle touches the ground."
		},
		{
			"name": "Anish",
			"text": "I tried to make mine as light as possible. I just hope the wind doesn't knock it over."
		},
		{
			"name": "Sai",
			"text": "Why are we doing the egg drop on a windy day anyways? Whatever, Let's just go to the bleachers and see what happens"
		},
	]

	super._ready()
