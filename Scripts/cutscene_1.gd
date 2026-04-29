extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 1 · Freshman Year
#  Runs before Mini-Game 1 (Robotics Challenge)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://game_1.tscn"
	YEAR_LABEL    = "Freshman Year"
	YEAR_SUBTITLE = "The Robotics Club"
	CHAPTER_NUM   = "1"
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
			"text": "Yo, does this schedule even make sense? I have no idea where the robotics room is."
		},
		{
			"name": "Sai",
			"text": "Dude, you're holding my schedule."
		},
		{
			"name": "Nikunj",
			"text": "Oh, my bad. I'm Nikunj."
		},
		{
			"name": "Anish",
			"text": "Wait, you guys are going to robotics too? I'm Anish, completely lost right now."
		},
		{
			"name": "Nilesh",
			"text": "Same. I've been looking at this map on my phone for like 10 minutes. This building isn't real, trust me."
		},
		{
			"name": "Nikunj",
			"text": "Give me the map, let me figure it out. I don't want to be too late, I remember them talking about some fun intro challenge today in the intrest meeting."
		},
		{
			"name": "Anish",
			"text": "Wait, they split us into teams for this, right?"
		},
		{
			"name": "Sai",
			"text": "Yeah, think so, let's just go there and figure it out."
		},
	]

	super._ready()
