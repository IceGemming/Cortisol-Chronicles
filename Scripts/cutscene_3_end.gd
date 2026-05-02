extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 1 · Freshman Year
#  Runs before Mini-Game 1 (Robotics Challenge)
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://cutscene_4.tscn"
	YEAR_LABEL    = "AP Physics 1"
	YEAR_SUBTITLE = "After Egg Drop"
	CHAPTER_NUM   = "6"
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
			"text": "That egg drop was not fair, Wind just sent my thing straight into the bleachers. How am I supposed to account for that!"
		},
		{
			"name": "Nikunj",
			"text": "Mine wasn't any better, It was way too small and the winds just tilted it was upside down before it even got close to the ground."
		},
		{
			"name": "Anish",
			"text": "I honestly don't know how mine survived. I guess the big styrofoam plates really carried."
		},
		{
			"name": "Sai",
			"text": "I don't think we should have done this on a windy day, But atleast most of the grade is the lab report so we are fine."
		},
		{
			"name": "Nikunj",
			"text": "True. Summer is almost year are you guys going to be locked in on College apps? We’re bassicly Seniors now."
		},
		{
			"name": "Nilesh",
			"text": "Wait, college apps already? I feel like we just got here."
		},
	]
	
	
	super._ready()
