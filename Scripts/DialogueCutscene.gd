extends Node

# ═══════════════════════════════════════════════════════════════════════
#  DialogueCutscene.gd  –  Shared base for all four cutscenes
#
#  Features:
#   • Typewriter text effect (characters revealed one at a time)
#   • Skip-to-end-of-line on first press; advance on second press
#   • Fade-in at scene start, fade-out before loading the minigame
#   • All per-cutscene data lives in the four thin subclass scripts
# ═══════════════════════════════════════════════════════════════════════

# ── Override these in each subclass ────────────────────────────────────
var NEXT_SCENE    : String = ""
var YEAR_LABEL    : String = ""
var YEAR_SUBTITLE : String = ""
var CHAPTER_NUM   : String = "1"
var BG_COLOR      : Color  = Color(0.04, 0.06, 0.18, 1.0)
var PANEL_COLOR   : Color  = Color(0.06, 0.08, 0.24, 1.0)
var ACCENT_COLOR  : Color  = Color(0.35, 0.50, 1.00, 1.0)

# Per-cutscene colours for the year badge / subtitle / tints
var BADGE_BG_COLOR   : Color = Color(0.12, 0.16, 0.42, 1.0)
var YEAR_TEXT_COLOR  : Color = Color(0.92, 0.92, 1.00)
var SUB_TEXT_COLOR   : Color = Color(0.60, 0.65, 0.88)
var CHAPTER_COLOR    : Color = Color(0.40, 0.42, 0.60)
var COUNTER_COLOR    : Color = Color(0.45, 0.48, 0.65)
var HINT_COLOR       : Color = Color(0.55, 0.60, 0.80)

var DIALOGUE : Array = []

const CHARACTER_COLORS := {
	"Nikunj" : Color(1.00, 0.85, 0.20),
	"Sai"    : Color(0.40, 0.90, 1.00),
	"Anish"  : Color(0.45, 1.00, 0.55),
	"Nilesh" : Color(1.00, 0.60, 0.30),
}

# ── Typewriter settings ─────────────────────────────────────────────────
const CHARS_PER_SEC : float = 50.0   # characters revealed per second

# ── Fade settings ───────────────────────────────────────────────────────
const FADE_DURATION : float = 0.45   # seconds for fade in / out

# ── Node refs ───────────────────────────────────────────────────────────
var _name_label     : Label
var _dialogue_label : Label
var _line_counter   : Label
var _hint_label     : Label
var _fade_rect      : ColorRect   # black overlay for transitions

# ── State ───────────────────────────────────────────────────────────────
var _current_line   : int   = 0
var _is_typing      : bool  = false   # true while typewriter is running
var _can_advance    : bool  = false   # gated until fade-in completes
var _full_text      : String = ""     # current line's complete text
var _typed_chars    : int   = 0       # how many chars have been revealed
var _type_timer     : float = 0.0


# ═══════════════════════════════════════════════════════════════════════
func _ready() -> void:
	_build_ui()
	# Fade in from black, then show first line
	await _fade(1.0, 0.0)   # black → transparent
	_can_advance = true
	_start_line(0)


# ═══════════════════════════════════════════════════════════════════════
#  UI Construction
# ═══════════════════════════════════════════════════════════════════════
func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var W := 1152.0
	var H := 648.0

	# ── Full-screen background ─────────────────────────────────────────
	var bg := ColorRect.new()
	bg.color    = BG_COLOR
	bg.position = Vector2.ZERO
	bg.size     = Vector2(W, H)
	canvas.add_child(bg)

	# ── Year badge (top-left card) ─────────────────────────────────────
	var badge := ColorRect.new()
	badge.color    = BADGE_BG_COLOR
	badge.position = Vector2(30, 22)
	badge.size     = Vector2(540, 80)
	canvas.add_child(badge)

	var badge_accent := ColorRect.new()
	badge_accent.color    = ACCENT_COLOR
	badge_accent.position = Vector2(30, 22)
	badge_accent.size     = Vector2(6, 80)
	canvas.add_child(badge_accent)

	var year_lbl := Label.new()
	year_lbl.text     = YEAR_LABEL
	year_lbl.position = Vector2(46, 27)
	year_lbl.size     = Vector2(500, 40)
	year_lbl.add_theme_font_size_override("font_size", 28)
	year_lbl.add_theme_color_override("font_color", YEAR_TEXT_COLOR)
	canvas.add_child(year_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text     = YEAR_SUBTITLE
	sub_lbl.position = Vector2(46, 68)
	sub_lbl.size     = Vector2(620, 26)
	sub_lbl.add_theme_font_size_override("font_size", 14)
	sub_lbl.add_theme_color_override("font_color", SUB_TEXT_COLOR)
	canvas.add_child(sub_lbl)

	# ── Chapter marker (top-right) ─────────────────────────────────────
	var flavour := Label.new()
	flavour.text     = "Cortisol Chronicles  ·  Chapter " + CHAPTER_NUM
	flavour.position = Vector2(W - 340, 30)
	flavour.size     = Vector2(320, 26)
	flavour.add_theme_font_size_override("font_size", 13)
	flavour.add_theme_color_override("font_color", CHAPTER_COLOR)
	canvas.add_child(flavour)

	# ── Dialogue panel ─────────────────────────────────────────────────
	var panel_y := 390.0
	var panel_h := H - panel_y

	var panel := ColorRect.new()
	panel.color    = PANEL_COLOR
	panel.position = Vector2(0, panel_y)
	panel.size     = Vector2(W, panel_h)
	canvas.add_child(panel)

	var accent_bar := ColorRect.new()
	accent_bar.color    = ACCENT_COLOR
	accent_bar.position = Vector2(0, panel_y)
	accent_bar.size     = Vector2(W, 4)
	canvas.add_child(accent_bar)

	# ── Character name ─────────────────────────────────────────────────
	_name_label          = Label.new()
	_name_label.position = Vector2(40, panel_y + 14)
	_name_label.size     = Vector2(500, 38)
	_name_label.add_theme_font_size_override("font_size", 24)
	canvas.add_child(_name_label)

	# ── Dialogue text ──────────────────────────────────────────────────
	_dialogue_label               = Label.new()
	_dialogue_label.position      = Vector2(40, panel_y + 56)
	_dialogue_label.size          = Vector2(W - 80, panel_h - 80)
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override("font_size", 20)
	_dialogue_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.96))
	canvas.add_child(_dialogue_label)

	# ── Line counter ───────────────────────────────────────────────────
	_line_counter          = Label.new()
	_line_counter.position = Vector2(40, H - 30)
	_line_counter.size     = Vector2(200, 24)
	_line_counter.add_theme_font_size_override("font_size", 13)
	_line_counter.add_theme_color_override("font_color", COUNTER_COLOR)
	canvas.add_child(_line_counter)

	# ── Continue hint ──────────────────────────────────────────────────
	_hint_label          = Label.new()
	_hint_label.text     = "▶  Space / Enter / X  to continue"
	_hint_label.position = Vector2(W - 370, H - 30)
	_hint_label.size     = Vector2(360, 26)
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.add_theme_color_override("font_color", HINT_COLOR)
	_hint_label.modulate.a = 0.0   # hidden until typing finishes
	canvas.add_child(_hint_label)

	# ── Fade overlay (sits on top of everything) ───────────────────────
	_fade_rect          = ColorRect.new()
	_fade_rect.color    = Color(0, 0, 0, 1)   # start fully black
	_fade_rect.position = Vector2.ZERO
	_fade_rect.size     = Vector2(W, H)
	canvas.add_child(_fade_rect)


# ═══════════════════════════════════════════════════════════════════════
#  Typewriter
# ═══════════════════════════════════════════════════════════════════════
func _start_line(index: int) -> void:
	if index >= DIALOGUE.size():
		# All lines done → fade to black → load next scene
		_can_advance = false
		await _fade(0.0, 1.0)   # transparent → black
		get_tree().change_scene_to_file(NEXT_SCENE)
		return

	var entry : Dictionary = DIALOGUE[index]

	# Name label
	_name_label.text = entry["name"]
	var col : Color = CHARACTER_COLORS.get(entry["name"], Color.WHITE)
	_name_label.add_theme_color_override("font_color", col)

	# Line counter
	_line_counter.text = "%d / %d" % [index + 1, DIALOGUE.size()]

	# Kick off typewriter
	_full_text    = entry["text"]
	_typed_chars  = 0
	_type_timer   = 0.0
	_is_typing    = true
	_hint_label.modulate.a = 0.0
	_dialogue_label.text   = ""
	set_process(true)


func _process(delta: float) -> void:
	if not _is_typing:
		return
	_type_timer += delta
	var chars_to_show := int(_type_timer * CHARS_PER_SEC)
	if chars_to_show > _full_text.length():
		chars_to_show = _full_text.length()

	if chars_to_show != _typed_chars:
		_typed_chars = chars_to_show
		_dialogue_label.text = _full_text.substr(0, _typed_chars)

	if _typed_chars >= _full_text.length():
		_finish_typing()


func _finish_typing() -> void:
	_is_typing = false
	_dialogue_label.text   = _full_text
	_hint_label.modulate.a = 1.0
	set_process(false)


# ═══════════════════════════════════════════════════════════════════════
#  Input
# ═══════════════════════════════════════════════════════════════════════
func _unhandled_input(event: InputEvent) -> void:
	if not _can_advance:
		return
	if not (event.is_action_pressed("ui_accept") or event.is_action_pressed("x-ps5")):
		return

	if _is_typing:
		# First press while typing → skip to end of this line
		_finish_typing()
	else:
		# Second press (or first if typing already done) → advance
		_can_advance = false
		_current_line += 1
		_start_line(_current_line)
		# Brief debounce so a held key doesn't skip two lines
		await get_tree().create_timer(0.12).timeout
		_can_advance = true


# ═══════════════════════════════════════════════════════════════════════
#  Fade helper  (from_alpha → to_alpha over FADE_DURATION seconds)
# ═══════════════════════════════════════════════════════════════════════
func _fade(from_alpha: float, to_alpha: float) -> void:
	_fade_rect.modulate.a = from_alpha
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", to_alpha, FADE_DURATION)
	await tween.finished
