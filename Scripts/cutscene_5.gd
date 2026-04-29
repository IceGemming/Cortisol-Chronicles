extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 5 · Epilogue
#  Runs after the final minigame
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = "res://ending.tscn"
	YEAR_LABEL    = "Epilogue"
	YEAR_SUBTITLE = "The End"
	CHAPTER_NUM   = "5"
	BG_TYPE       = ""

	FORCE_FORWARD_FACING = true
	AUTO_ADVANCE_ENABLED = true
	AUTO_ADVANCE_HOLD_SECONDS = 1.2
	AUTO_ADVANCE_HINT_TEXT = ""

	BG_COLOR     = Color(0.12, 0.18, 0.22, 1.0)
	PANEL_COLOR  = Color(0.09, 0.12, 0.11, 1.0)
	ACCENT_COLOR = Color(0.90, 0.74, 0.42, 1.0)

	BADGE_BG_COLOR  = Color(0.18, 0.22, 0.18, 1.0)
	YEAR_TEXT_COLOR = Color(0.98, 0.95, 0.88)
	SUB_TEXT_COLOR  = Color(0.79, 0.84, 0.73)
	CHAPTER_COLOR   = Color(0.56, 0.58, 0.46)
	COUNTER_COLOR   = Color(0.64, 0.68, 0.58)
	HINT_COLOR      = Color(0.72, 0.78, 0.66)

	DIALOGUE = [
		{
			"name": "Nikunj",
			"text": "Honestly, hitting submit on that last app was the biggest relief ever."
		},
		{
			"name": "Sai",
			"text": "Yes, I am just happy knowing we were finally done."
		},
		{
			"name": "Anish",
			"text": "Crazy to think it all started with us bumping into each other in geometry back in freshman year."
		},
		{
			"name": "Nilesh",
			"text": "Four years of stressing over grades and pulling all-nighters."
		},
		{
			"name": "Nikunj",
			"text": "Wherever we go next, at least we have 4 years of experiences together to look back on."
		},
		{
			"name": "Anish",
			"text": "Enough with the corny stuff, lets just leave this school"
		},
	]

	super._ready()
