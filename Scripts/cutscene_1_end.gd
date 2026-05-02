extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 1 · Freshman Year
#  Runs before Mini-Game 1 (Robotics Challenge)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://cutscene_2.tscn"
	YEAR_LABEL    = "Freshman Year"
	YEAR_SUBTITLE = "After Robotics Club"
	CHAPTER_NUM   = "2"
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
			"name": "Nikunj",
			"text": "That was actually pretty close! While it was fun, I don't think robotics is for me."
		},
		{
			"name": "Anish",
			"text": "I am kinda iffy on it too but the challenge was exciting. My team was struggling at first, but we pulled through."
		},
		{
			"name": "Nilesh",
			"text": "Freshman year is already bassicly gone. If this is how fun high school is, I'm down."
		},
		{
			"name": "Sai",
			"text": "Don't get too comfortable, It is only harder from here."
		},
		{
			"name": "Nikunj",
			"text": "True, Sophomore year is right around the corner, and I heard Pre-Calc Honours is a nightmare."
		},
		{
			"name": "Nilesh",
			"text": "Wait you are taking it? So am I am!"
		},
		{
			"name": "Sai",
			"text": "What a conincidence! I am also taking it. "
		},
		{
			"name": "Anish",
			"text": "Me too, Hopefully we are in the same class. "
		},
	]
	
	super._ready()
