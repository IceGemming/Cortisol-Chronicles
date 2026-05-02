extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 1 · Freshman Year
#  Runs before Mini-Game 1 (Robotics Challenge)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://cutscene_3.tscn"
	YEAR_LABEL    = "Sophomore Year"
	YEAR_SUBTITLE = "After Robotics Club"
	CHAPTER_NUM   = "4"
	BG_TYPE       = ""

	BG_COLOR     = Color(0.04, 0.06, 0.15, 1.0) 
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
			"name": "Nilesh",
			"text": "That quiz actually fried my brain."
		},
		{
			"name": "Nikunj",
			"text": "Tell me about it. I was writing so fast I think I actually created a new language."
		},
		{
			"name": "Anish",
			"text": "I’m just glad we’re all in the same period. I would've lost my mind if I had to suffer through this alone."
		},
		{
			"name": "Nilesh",
			"text": "So Junior year next? Is it just going to be more math?"
		},
		{
			"name": "Nikunj",
			"text": "Worse. Physics so math + conceptual thinking"
		},
		{
			"name": "Anish",
			"text": "Atleast we get to do an egg drop, that will be fun"
		},
	]

	
	super._ready()
