extends "res://Scripts/DialogueCutscene.gd"

# ─────────────────────────────────────────────
#  CUTSCENE 5 · Epilogue
#  Runs after the final minigame
# ─────────────────────────────────────────────

func _ready() -> void:
	NEXT_SCENE    = ""
	YEAR_LABEL    = "Epilogue"
	YEAR_SUBTITLE = "The Last Day & Moving Forward"
	CHAPTER_NUM   = "5"
	BG_TYPE       = "field"

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
			"text": "Each step felt like progress—finishing an essay, submitting an application, hitting “send” after weeks of work."
		},
		{
			"text": "It wasn’t one big moment, but a series of small ones that built toward something bigger. And when they finally submitted their last applications, there was a quiet sense of relief. Not because everything was guaranteed, but because they had done everything they could."
		},
		{
			"text": "On their last day, they passed by the same gym where it had all started. Nothing about the space had changed, but everything about them had."
		},
		{
			"text": "What began as a small mistake—a wrong schedule—had turned into four years of shared challenges, late nights, small wins, setbacks, and growth. Now, instead of worrying about where they belonged, they were ready to move forward, wherever that might be."
		},
		{
			"text": "Looking back, none of the individual moments mattered as much as the fact that they went through all of it together. And even as they stepped into something new, that was the one thing they knew would stay with them."
		},
	]

	super._ready()
