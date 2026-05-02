extends Node

# ═══════════════════════════════════════════════════════════════════════
#  DialogueCutscene.gd  –  Shared base for all cutscenes
#
#  Features:
#   • Character sprites displayed in the top 390px stage
#   • Active speaker highlighted; others dimmed (modulate + shader)
#   • Per-cutscene animated SVG-style background drawn on a SubViewport
#   • Typewriter text effect (characters revealed one at a time)
#   • Skip-to-end-of-line on first press; advance on second press
#   • Fade-in at scene start, fade-out before loading the minigame
# ═══════════════════════════════════════════════════════════════════════

# ── Override these in each subclass ────────────────────────────────────
var NEXT_SCENE    : String = ""
var YEAR_LABEL    : String = ""
var YEAR_SUBTITLE : String = ""
var CHAPTER_NUM   : String = "1"
var BG_COLOR      : Color  = Color(0.04, 0.06, 0.18, 1.0)
var PANEL_COLOR   : Color  = Color(0.06, 0.08, 0.24, 1.0)
var ACCENT_COLOR  : Color  = Color(0.35, 0.50, 1.00, 1.0)

var BADGE_BG_COLOR   : Color = Color(0.12, 0.16, 0.42, 1.0)
var YEAR_TEXT_COLOR  : Color = Color(0.92, 0.92, 1.00)
var SUB_TEXT_COLOR   : Color = Color(0.60, 0.65, 0.88)
var CHAPTER_COLOR    : Color = Color(0.40, 0.42, 0.60)
var COUNTER_COLOR    : Color = Color(0.45, 0.48, 0.65)
var HINT_COLOR       : Color = Color(0.55, 0.60, 0.80)

# Override in subclass with one of: "school_hallway","classroom","rooftop","library","field"
var BG_TYPE : String = "school_hallway"

var FORCE_FORWARD_FACING : bool = false
var AUTO_ADVANCE_ENABLED : bool = false
var AUTO_ADVANCE_HOLD_SECONDS : float = 1.15
var MANUAL_ADVANCE_HINT_TEXT : String = "▶  Space / Enter / X  to continue"
var AUTO_ADVANCE_HINT_TEXT   : String = ""

var DIALOGUE : Array = []

const CHARACTER_COLORS := {
	"Nikunj" : Color(1.00, 0.85, 0.20),
	"Sai"    : Color(0.40, 0.90, 1.00),
	"Anish"  : Color(0.45, 1.00, 0.55),
	"Nilesh" : Color(1.00, 0.60, 0.30),
}

# Sprite paths – adjust if your Assets folder is elsewhere
const SPRITE_PATHS := {
	"Nikunj" : "res://Assets/boy1.png",
	"Sai"    : "res://Assets/girl2.png",
	"Anish"  : "res://Assets/boy2.png",
	"Nilesh" : "res://Assets/boy3.png",
}

const SPRITE_REGIONS := {
	"left": Rect2(0, 288, 144, 144),
	"right": Rect2(144, 0, 144, 144),
	"forward": Rect2(288, 144, 144, 144),
}

const SPRITE_DISPLAY_SIZE := Vector2(250.0, 250.0)
const SPRITE_FLOOR_Y := 352.0
const SPRITE_STAGE_POSITIONS := {
	"Nikunj": 156.0,
	"Sai": 414.0,
	"Anish": 738.0,
	"Nilesh": 996.0,
}
const SPRITE_FACING := {
	"Nikunj": "right",
	"Sai": "right",
	"Anish": "left",
	"Nilesh": "left",
}

# Dim modulate applied to inactive speakers
const INACTIVE_MODULATE : Color = Color(0.28, 0.28, 0.32, 0.72)
const NEUTRAL_MODULATE  : Color = Color(0.96, 0.97, 1.00, 0.96)
const ACTIVE_SCALE       : float = 1.06   # subtle scale-up for active speaker

# ── Typewriter settings ─────────────────────────────────────────────────
const CHARS_PER_SEC : float = 50.0

# ── Fade settings ───────────────────────────────────────────────────────
const FADE_DURATION : float = 0.45

# ── Canvas size ─────────────────────────────────────────────────────────
const W : float = 1152.0
const H : float = 648.0
const STAGE_H : float = 390.0   # sprite area height
const PANEL_Y : float = 390.0

# ── Node refs ───────────────────────────────────────────────────────────
var _canvas        : CanvasLayer
var _name_label    : Label
var _dialogue_label: Label
var _line_counter  : Label
var _hint_label    : Label
var _fade_rect     : ColorRect

# Sprite nodes keyed by character name
var _sprite_nodes  : Dictionary = {}   # name -> TextureRect
var _sprite_base_x : Dictionary = {}   # name -> float (rest x-center)

# Background drawing node
var _bg_draw       : Node2D

# ── State ───────────────────────────────────────────────────────────────
var _current_line  : int   = 0
var _is_typing     : bool  = false
var _can_advance   : bool  = false
var _full_text     : String = ""
var _typed_chars   : int   = 0
var _type_timer    : float = 0.0
var _bg_time       : float = 0.0
var _active_speaker: String = ""
var _line_token    : int   = 0


# ═══════════════════════════════════════════════════════════════════════
func _ready() -> void:
	_build_ui()
	await _fade(1.0, 0.0)
	_can_advance = true
	_start_line(0)


# ═══════════════════════════════════════════════════════════════════════
#  UI Construction
# ═══════════════════════════════════════════════════════════════════════
func _build_ui() -> void:
	_canvas = CanvasLayer.new()
	add_child(_canvas)

	# ── Background colour fill ─────────────────────────────────────────
	var bg := ColorRect.new()
	bg.color    = BG_COLOR
	bg.position = Vector2.ZERO
	bg.size     = Vector2(W, H)
	_canvas.add_child(bg)

	# ── Animated background drawings (drawn by _BgDrawer) ─────────────
	_bg_draw = _BgDrawer.new(BG_TYPE, ACCENT_COLOR)
	_bg_draw.z_index = 1
	_canvas.add_child(_bg_draw)

	# ── Sprite stage ──────────────────────────────────────────────────
	_build_sprite_stage()

	# ── Year badge ────────────────────────────────────────────────────
	var badge := ColorRect.new()
	badge.color    = BADGE_BG_COLOR
	badge.position = Vector2(30, 22)
	badge.size     = Vector2(540, 80)
	badge.z_index  = 10
	_canvas.add_child(badge)

	var badge_accent := ColorRect.new()
	badge_accent.color    = ACCENT_COLOR
	badge_accent.position = Vector2(30, 22)
	badge_accent.size     = Vector2(6, 80)
	badge_accent.z_index  = 11
	_canvas.add_child(badge_accent)

	var year_lbl := Label.new()
	year_lbl.text     = YEAR_LABEL
	year_lbl.position = Vector2(46, 27)
	year_lbl.size     = Vector2(500, 40)
	year_lbl.add_theme_font_size_override("font_size", 28)
	year_lbl.add_theme_color_override("font_color", YEAR_TEXT_COLOR)
	year_lbl.z_index  = 12
	_canvas.add_child(year_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text     = YEAR_SUBTITLE
	sub_lbl.position = Vector2(46, 68)
	sub_lbl.size     = Vector2(620, 26)
	sub_lbl.add_theme_font_size_override("font_size", 14)
	sub_lbl.add_theme_color_override("font_color", SUB_TEXT_COLOR)
	sub_lbl.z_index  = 12
	_canvas.add_child(sub_lbl)

	# ── Chapter marker ────────────────────────────────────────────────
	var flavour := Label.new()
	flavour.text     = "Cortisol Chronicles  ·  Chapter " + CHAPTER_NUM
	flavour.position = Vector2(W - 340, 30)
	flavour.size     = Vector2(320, 26)
	flavour.add_theme_font_size_override("font_size", 13)
	flavour.add_theme_color_override("font_color", CHAPTER_COLOR)
	flavour.z_index  = 10
	_canvas.add_child(flavour)

	# ── Dialogue panel ────────────────────────────────────────────────
	var panel_h := H - PANEL_Y

	var panel := ColorRect.new()
	panel.color    = PANEL_COLOR
	panel.position = Vector2(0, PANEL_Y)
	panel.size     = Vector2(W, panel_h)
	panel.z_index  = 15
	_canvas.add_child(panel)

	var accent_bar := ColorRect.new()
	accent_bar.color    = ACCENT_COLOR
	accent_bar.position = Vector2(0, PANEL_Y)
	accent_bar.size     = Vector2(W, 4)
	accent_bar.z_index  = 16
	_canvas.add_child(accent_bar)

	_name_label          = Label.new()
	_name_label.position = Vector2(40, PANEL_Y + 14)
	_name_label.size     = Vector2(500, 38)
	_name_label.add_theme_font_size_override("font_size", 24)
	_name_label.z_index  = 17
	_canvas.add_child(_name_label)

	_dialogue_label               = Label.new()
	_dialogue_label.position      = Vector2(40, PANEL_Y + 56)
	_dialogue_label.size          = Vector2(W - 80, panel_h - 80)
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override("font_size", 20)
	_dialogue_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.96))
	_dialogue_label.z_index = 17
	_canvas.add_child(_dialogue_label)

	_line_counter          = Label.new()
	_line_counter.position = Vector2(40, H - 30)
	_line_counter.size     = Vector2(200, 24)
	_line_counter.add_theme_font_size_override("font_size", 13)
	_line_counter.add_theme_color_override("font_color", COUNTER_COLOR)
	_line_counter.z_index  = 17
	_canvas.add_child(_line_counter)

	_hint_label          = Label.new()
	_hint_label.text     = _hint_text_for_current_mode()
	_hint_label.position = Vector2(W - 370, H - 30)
	_hint_label.size     = Vector2(360, 26)
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.add_theme_color_override("font_color", HINT_COLOR)
	_hint_label.modulate.a = 0.0
	_hint_label.z_index    = 17
	_hint_label.visible    = not _hint_label.text.is_empty()
	_canvas.add_child(_hint_label)

	# ── Fade overlay ──────────────────────────────────────────────────
	_fade_rect          = ColorRect.new()
	_fade_rect.color    = Color(0, 0, 0, 1)
	_fade_rect.position = Vector2.ZERO
	_fade_rect.size     = Vector2(W, H)
	_fade_rect.z_index  = 50
	_canvas.add_child(_fade_rect)


func _build_sprite_stage() -> void:
	var chars := ["Nikunj", "Sai", "Anish", "Nilesh"]

	for i in chars.size():
		var name  : String = chars[i]
		var cx    : float  = SPRITE_STAGE_POSITIONS.get(name, W * 0.5)

		var tr := TextureRect.new()
		tr.texture        = _make_pose_texture(SPRITE_PATHS[name], _sprite_pose_for(name))
		tr.expand_mode    = TextureRect.EXPAND_FIT_HEIGHT
		tr.stretch_mode   = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = SPRITE_DISPLAY_SIZE
		tr.size           = SPRITE_DISPLAY_SIZE
		tr.position       = _stage_position(cx)
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.z_index  = 5

		_canvas.add_child(tr)
		_sprite_nodes[name]  = tr
		_sprite_base_x[name] = cx

	# Start with all dimmed
	_set_all_inactive()


func _sprite_pose_for(name: String) -> String:
	if FORCE_FORWARD_FACING:
		return "forward"
	return SPRITE_FACING.get(name, "right")


func _make_pose_texture(texture_path: String, facing: String) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(texture_path) as Texture2D
	atlas.region = SPRITE_REGIONS.get(facing, SPRITE_REGIONS["right"])
	return atlas


func _stage_position(center_x: float, scale_value: float = 1.0, lift: float = 0.0) -> Vector2:
	var scaled_size := SPRITE_DISPLAY_SIZE * scale_value
	return Vector2(center_x - scaled_size.x * 0.5, SPRITE_FLOOR_Y - scaled_size.y - lift)


func _set_speaker(speaker: String) -> void:
	_active_speaker = speaker
	if speaker.is_empty() or not _sprite_nodes.has(speaker):
		_set_all_neutral()
		return

	for name in _sprite_nodes:
		var tr : TextureRect = _sprite_nodes[name]
		var target_scale := 1.0
		var target_modulate := INACTIVE_MODULATE
		var target_lift := 0.0
		tr.z_index = 5

		if name == speaker:
			target_scale = ACTIVE_SCALE
			target_modulate = Color(1.05, 1.02, 1.05, 1.0)
			target_lift = 12.0
			tr.z_index = 8

		var target_position := _stage_position(_sprite_base_x.get(name, W * 0.5), target_scale, target_lift)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(tr, "modulate", target_modulate, 0.3)
		tw.tween_property(tr, "scale", Vector2(target_scale, target_scale), 0.3)
		tw.tween_property(tr, "position", target_position, 0.3)


func _set_all_inactive() -> void:
	for name in _sprite_nodes:
		var tr : TextureRect = _sprite_nodes[name]
		tr.modulate = INACTIVE_MODULATE
		tr.scale    = Vector2(1.0, 1.0)
		tr.position = _stage_position(_sprite_base_x.get(name, W * 0.5))
		tr.z_index  = 5


func _set_all_neutral() -> void:
	for name in _sprite_nodes:
		var tr : TextureRect = _sprite_nodes[name]
		tr.modulate = NEUTRAL_MODULATE
		tr.scale    = Vector2(1.0, 1.0)
		tr.position = _stage_position(_sprite_base_x.get(name, W * 0.5))
		tr.z_index  = 6


func _set_dialogue_layout(show_name: bool) -> void:
	_name_label.visible = show_name
	if show_name:
		_dialogue_label.position.y = PANEL_Y + 56
		_dialogue_label.size.y = H - (PANEL_Y + 80)
	else:
		_dialogue_label.position.y = PANEL_Y + 24
		_dialogue_label.size.y = H - (PANEL_Y + 48)


func _hint_text_for_current_mode() -> String:
	if AUTO_ADVANCE_ENABLED:
		return AUTO_ADVANCE_HINT_TEXT
	return MANUAL_ADVANCE_HINT_TEXT


# ═══════════════════════════════════════════════════════════════════════
#  Typewriter
# ═══════════════════════════════════════════════════════════════════════
func _start_line(index: int) -> void:
	if index >= DIALOGUE.size():
		await _finish_cutscene()
		return

	_current_line = index
	_line_token += 1
	var entry : Dictionary = DIALOGUE[index]
	var speaker_name := String(entry.get("name", ""))

	_name_label.text = speaker_name
	_set_dialogue_layout(not speaker_name.is_empty())
	var col : Color  = CHARACTER_COLORS.get(speaker_name, Color(0.95, 0.95, 0.96))
	_name_label.add_theme_color_override("font_color", col)

	_line_counter.text = "%d / %d" % [index + 1, DIALOGUE.size()]

	# Highlight active speaker
	_set_speaker(speaker_name)

	_full_text    = String(entry.get("text", ""))
	_typed_chars  = 0
	_type_timer   = 0.0
	_is_typing    = true
	_hint_label.text = _hint_text_for_current_mode()
	_hint_label.visible = not _hint_label.text.is_empty()
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
	_hint_label.text = _hint_text_for_current_mode()
	_hint_label.visible = not _hint_label.text.is_empty()
	_hint_label.modulate.a = 1.0 if _hint_label.visible else 0.0
	set_process(false)

	if AUTO_ADVANCE_ENABLED:
		_schedule_auto_advance(_line_token)


func _schedule_auto_advance(line_token: int) -> void:
	await get_tree().create_timer(AUTO_ADVANCE_HOLD_SECONDS).timeout
	if line_token != _line_token or _is_typing or not _can_advance or not is_inside_tree():
		return
	await _advance_line()


func _advance_line() -> void:
	if not _can_advance:
		return

	_can_advance = false
	var next_index := _current_line + 1
	_start_line(next_index)
	if next_index < DIALOGUE.size():
		await get_tree().create_timer(0.12).timeout
		_can_advance = true


# ═══════════════════════════════════════════════════════════════════════
#  Input
# ═══════════════════════════════════════════════════════════════════════
func _unhandled_input(event: InputEvent) -> void:
	if not _can_advance:
		return

	if not (event.is_action_pressed("ui_accept") or event.is_action_pressed("x-ps5")):
		return

	# Ignore input while text is typing
	if _is_typing:
		return

	await _advance_line()


# ═══════════════════════════════════════════════════════════════════════
#  Fade helper
# ═══════════════════════════════════════════════════════════════════════
func _fade(from_alpha: float, to_alpha: float) -> void:
	_fade_rect.modulate.a = from_alpha
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", to_alpha, FADE_DURATION)
	await tween.finished


func _finish_cutscene() -> void:
	_can_advance = false
	await _fade(0.0, 1.0)
	if NEXT_SCENE.is_empty():
		return
	get_tree().change_scene_to_file(NEXT_SCENE)


# ═══════════════════════════════════════════════════════════════════════
#  _BgDrawer – inner class that draws the animated scene background
# ═══════════════════════════════════════════════════════════════════════
class _BgDrawer extends Node2D:
	var bg_type : String
	var accent  : Color
	var t       : float = 0.0

	func _init(type: String, ac: Color) -> void:
		bg_type = type
		accent  = ac

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		match bg_type:
			"school_hallway": _draw_hallway()
			"classroom":      _draw_classroom()
			"rooftop":        _draw_rooftop()
			"library":        _draw_library()
			"field":          _draw_field()

	# ── Hallway: lockers + club fair staging ──────────────────────────
	func _draw_hallway() -> void:
		var a := accent

		# Ceiling strip
		draw_rect(Rect2(0, 0, 1152, 55),
			Color(a.r, a.g, a.b, 0.10 + 0.02 * sin(t * 0.8)))

		# Locker columns
		for i in 9:
			var x := float(i) * 130.0 + 5.0
			draw_rect(Rect2(x, 55, 120, 285), Color(a.r, a.g, a.b, 0.06))
			draw_rect(Rect2(x, 55, 120, 285), Color(a.r, a.g, a.b, 0.18),
				false, 1.0)   # outline
			# Handle
			draw_rect(Rect2(x + 102, 190, 8, 22), Color(a.r, a.g, a.b, 0.5))

		# Robotics club fair banner and display table
		draw_rect(Rect2(392, 76, 368, 54), Color(a.r, a.g, a.b, 0.10))
		draw_rect(Rect2(392, 76, 368, 54), Color(a.r, a.g, a.b, 0.28), false, 2.0)
		draw_line(Vector2(392, 76), Vector2(368, 58), Color(a.r, a.g, a.b, 0.22), 1.5)
		draw_line(Vector2(760, 76), Vector2(784, 58), Color(a.r, a.g, a.b, 0.22), 1.5)
		draw_rect(Rect2(484, 275, 184, 12), Color(a.r, a.g, a.b, 0.12))
		draw_rect(Rect2(496, 286, 12, 48), Color(a.r, a.g, a.b, 0.11))
		draw_rect(Rect2(644, 286, 12, 48), Color(a.r, a.g, a.b, 0.11))
		draw_rect(Rect2(545, 228, 56, 36), Color(a.r, a.g, a.b, 0.10))
		draw_rect(Rect2(555, 214, 36, 14), Color(a.r, a.g, a.b, 0.08))
		draw_line(Vector2(573, 214), Vector2(573, 194), Color(a.r, a.g, a.b, 0.20), 2.0)
		draw_circle(Vector2(573, 191), 4.0, Color(a.r, a.g, a.b, 0.28))
		draw_circle(Vector2(557, 266), 12.0, Color(a.r, a.g, a.b, 0.18))
		draw_circle(Vector2(589, 266), 12.0, Color(a.r, a.g, a.b, 0.18))

		# Perspective guide lines
		for i in 9:
			var pt := Vector2(i * 144.0, 390.0)
			draw_line(Vector2(576, 180), pt, Color(a.r, a.g, a.b, 0.05), 1.0)

		# Floor gradient strip
		draw_rect(Rect2(0, 330, 1152, 60), Color(a.r, a.g, a.b, 0.08))

		# Floating paper scraps (deterministic animation via sin offsets)
		for i in 16:
			var fx := fmod(float(i) * 73.1 + t * (30.0 + float(i) * 4.0), 1152.0)
			var fy := fmod(float(i) * 41.7 + t * (18.0 + float(i) * 2.5), 310.0) + 20.0
			var angle := sin(t * 0.5 + float(i)) * 0.4
			var w2 := 5.0 + float(i % 5) * 2.0
			var h2 := 7.0 + float(i % 4) * 3.0
			# Rotate manually (2-point draw approximation)
			draw_rect(Rect2(fx - w2 * 0.5, fy - h2 * 0.5, w2, h2),
				Color(a.r, a.g, a.b, 0.14 + sin(t + float(i)) * 0.06))

	# ── Classroom: board + test-day props ─────────────────────────────
	func _draw_classroom() -> void:
		var a := accent

		# Whiteboard / chalkboard
		draw_rect(Rect2(155, 35, 840, 210), Color(a.r, a.g, a.b, 0.09))
		draw_rect(Rect2(155, 35, 840, 210), Color(a.r, a.g, a.b, 0.35),
			false, 1.5)

		# Ruled lines on board
		for row in 4:
			var y := 85.0 + row * 38.0
			draw_line(Vector2(180, y), Vector2(920, y),
				Color(a.r, a.g, a.b, 0.12), 1.0)

		# Clock and graph sketches
		draw_circle(Vector2(1015, 76), 24.0, Color(a.r, a.g, a.b, 0.10))
		draw_arc(Vector2(1015, 76), 24.0, 0.0, TAU, 24, Color(a.r, a.g, a.b, 0.34), 2.0)
		draw_line(Vector2(1015, 76), Vector2(1015, 63), Color(a.r, a.g, a.b, 0.24), 2.0)
		draw_line(Vector2(1015, 76), Vector2(1026, 81), Color(a.r, a.g, a.b, 0.24), 2.0)
		draw_line(Vector2(278, 196), Vector2(420, 196), Color(a.r, a.g, a.b, 0.20), 1.5)
		draw_line(Vector2(349, 118), Vector2(349, 224), Color(a.r, a.g, a.b, 0.20), 1.5)
		draw_polyline(PackedVector2Array([
			Vector2(292, 214),
			Vector2(316, 205),
			Vector2(340, 190),
			Vector2(364, 168),
			Vector2(388, 140),
			Vector2(412, 126),
		]), Color(a.r, a.g, a.b, 0.30), 2.0)

		# Desk silhouettes
		for row in 2:
			for col in 4:
				draw_rect(Rect2(80.0 + col * 260.0, 295.0 + row * 55.0, 200, 10),
					Color(a.r, a.g, a.b, 0.08))
				draw_rect(Rect2(120.0 + col * 260.0, 272.0 + row * 55.0, 34, 18),
					Color(1.0, 1.0, 1.0, 0.08))

		# Teacher desk up front
		draw_rect(Rect2(832, 260, 220, 14), Color(a.r, a.g, a.b, 0.10))
		draw_rect(Rect2(848, 274, 14, 50), Color(a.r, a.g, a.b, 0.10))
		draw_rect(Rect2(1020, 274, 14, 50), Color(a.r, a.g, a.b, 0.10))
		draw_rect(Rect2(875, 236, 52, 20), Color(1.0, 1.0, 1.0, 0.05))
		draw_rect(Rect2(937, 232, 34, 26), Color(a.r, a.g, a.b, 0.07))

		# Floor
		draw_rect(Rect2(0, 345, 1152, 45), Color(a.r, a.g, a.b, 0.07))

	# ── Rooftop: sky + city silhouette + egg drop setup ───────────────
	func _draw_rooftop() -> void:
		var a := accent

		# Sky glow
		draw_rect(Rect2(0, 0, 1152, 260),
			Color(a.r, a.g, a.b, 0.12 + 0.03 * sin(t * 0.4)))

		# Sun corona
		for ring in 3:
			var alpha := 0.07 - ring * 0.02 + 0.01 * sin(t * 0.6)
			draw_circle(Vector2(900, 55), 60.0 + ring * 35.0,
				Color(a.r, a.g, a.b, alpha))

		# Building silhouettes
		var buildings := [
			[0,   155, 140, 165],
			[155, 195,  85, 125],
			[300, 135, 205, 185],
			[560, 175, 125, 145],
			[730, 145, 165, 175],
			[945, 165, 105, 155],
			[1060,185, 110, 135],
		]
		for b in buildings:
			draw_rect(Rect2(b[0], b[1], b[2], b[3]),
				Color(a.r * 0.5, a.g * 0.5, a.b * 0.5, 0.18))

		# Clouds drifting behind the ledge
		for i in 4:
			var cx := 150.0 + i * 245.0 + sin(t * 0.08 + float(i)) * 16.0
			var cy := 72.0 + float(i % 2) * 26.0 + sin(t * 0.15 + float(i)) * 5.0
			draw_circle(Vector2(cx, cy), 22.0, Color(1.0, 1.0, 1.0, 0.06))
			draw_circle(Vector2(cx + 22.0, cy + 4.0), 18.0, Color(1.0, 1.0, 1.0, 0.05))
			draw_circle(Vector2(cx - 20.0, cy + 5.0), 16.0, Color(1.0, 1.0, 1.0, 0.05))

		# Guard rail and project drop boxes
		draw_line(Vector2(0, 284), Vector2(1152, 284), Color(a.r, a.g, a.b, 0.18), 2.0)
		for i in 9:
			draw_rect(Rect2(48.0 + i * 130.0, 270.0, 6, 36), Color(a.r, a.g, a.b, 0.16))
		draw_rect(Rect2(166, 236, 62, 34), Color(a.r, a.g, a.b, 0.10))
		draw_rect(Rect2(174, 242, 46, 22), Color(1.0, 1.0, 1.0, 0.05))
		draw_rect(Rect2(890, 230, 78, 40), Color(a.r, a.g, a.b, 0.10))
		draw_line(Vector2(902, 238), Vector2(956, 264), Color(a.r, a.g, a.b, 0.18), 2.0)
		draw_line(Vector2(956, 238), Vector2(902, 264), Color(a.r, a.g, a.b, 0.18), 2.0)

		# Rooftop ledge
		draw_rect(Rect2(0, 308, 1152, 32), Color(a.r, a.g, a.b, 0.14))
		draw_rect(Rect2(0, 334, 1152, 10), Color(a.r, a.g, a.b, 0.25))

		# Falling eggs (looping)
		for i in 10:
			var fy := fmod(float(i) * 57.3 + t * (55.0 + float(i) * 8.0), 360.0)
			var fx := float(i) * 112.0 + 40.0 + sin(t * 0.7 + float(i)) * 6.0
			# Simple egg: two overlapping circles
			draw_circle(Vector2(fx, fy), 9.0, Color(1.0, 1.0, 0.86, 0.15))
			draw_arc(Vector2(fx, fy), 9.0, 0, TAU,
				16, Color(a.r, a.g, a.b, 0.25), 1.0)

	# ── Library: bookshelves + application-night study table ──────────
	func _draw_library() -> void:
		var a := accent

		# Left shelf unit
		draw_rect(Rect2(0, 35, 16, 345),  Color(a.r, a.g, a.b, 0.12))
		draw_rect(Rect2(16, 35, 205, 8),  Color(a.r, a.g, a.b, 0.12))
		for shelf in 5:
			var sy := 55.0 + shelf * 60.0
			draw_rect(Rect2(16, sy + 52, 205, 4), Color(a.r, a.g, a.b, 0.10))
			for b in 7:
				var bx := 20.0 + b * 29.0
				var shade := 0.05 + float(b % 3) * 0.04
				draw_rect(Rect2(bx, sy + 6, 23, 44), Color(a.r, a.g, a.b, shade))

		# Right shelf unit
		draw_rect(Rect2(931, 35, 205, 8),  Color(a.r, a.g, a.b, 0.12))
		draw_rect(Rect2(1136, 35, 16, 345), Color(a.r, a.g, a.b, 0.12))
		for shelf in 5:
			var sy := 55.0 + shelf * 60.0
			draw_rect(Rect2(931, sy + 52, 205, 4), Color(a.r, a.g, a.b, 0.10))
			for b in 7:
				var bx := 935.0 + b * 29.0
				var shade := 0.05 + float(b % 3) * 0.04
				draw_rect(Rect2(bx, sy + 6, 23, 44), Color(a.r, a.g, a.b, shade))

		# Warm overhead glow
		draw_rect(Rect2(250, 0, 650, 180), Color(a.r, a.g, a.b, 0.07))
		for i in 3:
			var lx := 360.0 + i * 220.0
			draw_line(Vector2(lx, 0), Vector2(lx, 82), Color(a.r, a.g, a.b, 0.16), 1.0)
			draw_circle(Vector2(lx, 94), 18.0, Color(a.r, a.g, a.b, 0.06))

		# Deadline board and study materials
		draw_rect(Rect2(438, 56, 278, 72), Color(a.r, a.g, a.b, 0.09))
		draw_rect(Rect2(438, 56, 278, 72), Color(a.r, a.g, a.b, 0.20), false, 1.5)
		for i in 4:
			draw_rect(Rect2(462.0 + i * 58.0, 76, 40, 20), Color(1.0, 1.0, 1.0, 0.05))

		# Table surface
		draw_rect(Rect2(200, 310, 755, 14), Color(a.r, a.g, a.b, 0.09))
		for lx in [320.0, 505.0, 690.0]:
			draw_rect(Rect2(lx, 258, 54, 34), Color(a.r, a.g, a.b, 0.08))
			draw_rect(Rect2(lx + 4, 262, 46, 24), Color(a.r, a.g, a.b, 0.15), false, 1.2)
			draw_rect(Rect2(lx - 8, 292, 70, 6), Color(a.r, a.g, a.b, 0.12))
		draw_rect(Rect2(430, 270, 46, 24), Color(1.0, 1.0, 1.0, 0.06))
		draw_rect(Rect2(595, 274, 52, 20), Color(a.r, a.g, a.b, 0.10))

		# Drifting dust motes
		for i in 24:
			var fx := fmod(float(i) * 48.7 + sin(t * 0.3 + float(i)) * 20.0, 1152.0)
			var fy := fmod(float(i) * 31.1 - t * (8.0 + float(i % 4) * 2.0) + 340.0, 320.0)
			var alpha := 0.18 + 0.12 * sin(t * 1.2 + float(i) * 1.1)
			draw_circle(Vector2(fx, fy), 1.5 + float(i % 3) * 0.5,
				Color(a.r, a.g, a.b, alpha))

	# ── Field: horizon + open space for the epilogue ──────────────────
	func _draw_field() -> void:
		var a := accent
		var horizon_y := 214.0 + sin(t * 0.18) * 2.0

		# Open sky and soft sunset glow
		draw_rect(Rect2(0, 0, 1152, 240), Color(a.r, a.g, a.b, 0.08))
		for ring in 4:
			var alpha := 0.08 - ring * 0.015 + 0.01 * sin(t * 0.55)
			draw_circle(Vector2(182, 84), 54.0 + ring * 28.0, Color(a.r, a.g, a.b, alpha))

		# Distant clouds
		for i in 5:
			var cx := 132.0 + i * 212.0 + sin(t * 0.08 + float(i)) * 18.0
			var cy := 72.0 + float(i % 2) * 24.0 + sin(t * 0.13 + float(i)) * 5.0
			draw_circle(Vector2(cx, cy), 24.0, Color(1.0, 1.0, 1.0, 0.06))
			draw_circle(Vector2(cx + 26.0, cy + 6.0), 18.0, Color(1.0, 1.0, 1.0, 0.05))
			draw_circle(Vector2(cx - 22.0, cy + 5.0), 16.0, Color(1.0, 1.0, 1.0, 0.05))

		# Horizon, distant hills, and a small gym silhouette
		draw_line(Vector2(0, horizon_y), Vector2(1152, horizon_y), Color(a.r, a.g, a.b, 0.24), 2.0)
		draw_polyline(PackedVector2Array([
			Vector2(0, horizon_y + 10.0),
			Vector2(120.0, horizon_y - 4.0),
			Vector2(248.0, horizon_y + 12.0),
			Vector2(394.0, horizon_y - 8.0),
			Vector2(548.0, horizon_y + 14.0),
			Vector2(712.0, horizon_y - 2.0),
			Vector2(866.0, horizon_y + 10.0),
			Vector2(1012.0, horizon_y - 6.0),
			Vector2(1152.0, horizon_y + 8.0),
		]), Color(a.r, a.g, a.b, 0.14), 3.0)
		draw_rect(Rect2(804, horizon_y - 42.0, 154.0, 42.0), Color(a.r, a.g, a.b, 0.10))
		draw_rect(Rect2(818, horizon_y - 58.0, 126.0, 16.0), Color(a.r, a.g, a.b, 0.08))
		draw_rect(Rect2(804, horizon_y - 42.0, 154.0, 42.0), Color(a.r, a.g, a.b, 0.18), false, 1.5)

		# Field bands and a simple walkway toward the horizon
		draw_rect(Rect2(0, horizon_y, 1152, 78), Color(a.r * 0.58, a.g * 0.82, a.b * 0.56, 0.14))
		draw_rect(Rect2(0, horizon_y + 78, 1152, 98), Color(a.r * 0.44, a.g * 0.68, a.b * 0.42, 0.18))
		draw_line(Vector2(0, horizon_y + 82.0), Vector2(1152, horizon_y + 82.0), Color(a.r, a.g, a.b, 0.08), 1.0)
		draw_line(Vector2(0, horizon_y + 126.0), Vector2(1152, horizon_y + 126.0), Color(a.r, a.g, a.b, 0.08), 1.0)
		draw_polyline(PackedVector2Array([
			Vector2(500.0, 390.0),
			Vector2(540.0, 320.0),
			Vector2(562.0, 270.0),
			Vector2(576.0, horizon_y + 10.0),
		]), Color(1.0, 1.0, 1.0, 0.08), 26.0)

		# Subtle breeze through the grass
		for i in 22:
			var gx := 28.0 + float(i) * 52.0 + sin(t * 0.45 + float(i) * 0.7) * 8.0
			var gy := horizon_y + 98.0 + float(i % 3) * 22.0
			draw_line(
				Vector2(gx, gy),
				Vector2(gx + 10.0 + sin(t * 0.9 + float(i)) * 4.0, gy - 12.0),
				Color(a.r, a.g, a.b, 0.18),
				1.2
			)
