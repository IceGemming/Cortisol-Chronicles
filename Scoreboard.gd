extends Node2D

@onready var canvas: CanvasLayer = $Canvas
@onready var rows_container: VBoxContainer = $Canvas/Panel/VBox/Rows

# Call this after the scene is ready, passing your scores dictionary
func display_scores(scores: Dictionary) -> void:
	# Clear any existing rows first
	for child in rows_container.get_children():
		child.queue_free()

	# Sort by score descending
	var sorted_players := scores.keys()
	sorted_players.sort_custom(func(a, b): return scores[a] > scores[b])

	for i in sorted_players.size():
		var player = sorted_players[i]
		var score  = scores[player]

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 0)

		# Rank label
		var rank_lbl := Label.new()
		rank_lbl.text = "#%d" % (i + 1)
		rank_lbl.custom_minimum_size = Vector2(50, 0)
		rank_lbl.add_theme_font_size_override("font_size", 22)
		rank_lbl.add_theme_color_override("font_color", _rank_color(i))
		rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(rank_lbl)

		# Spacer
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(16, 0)
		row.add_child(spacer)

		# Player name label
		var name_lbl := Label.new()
		name_lbl.text = str(player)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 22)
		name_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		row.add_child(name_lbl)

		# Score label
		var score_lbl := Label.new()
		score_lbl.text = str(score)
		score_lbl.custom_minimum_size = Vector2(80, 0)
		score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		score_lbl.add_theme_font_size_override("font_size", 22)
		score_lbl.add_theme_color_override("font_color", Color(0.8, 1.0, 0.4))
		row.add_child(score_lbl)

		# Highlight top row
		if i == 0:
			var bg := ColorRect.new()
			bg.color = Color(1.0, 0.85, 0.0, 0.15)
			bg.size  = Vector2(10, 10)   # will stretch via container
			row.add_child(bg)
			row.move_child(bg, 0)

		rows_container.add_child(row)

		# Animate each row sliding in with a delay
		row.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_interval(i * 0.12)
		tween.tween_property(row, "modulate:a", 1.0, 0.25)

func _rank_color(rank: int) -> Color:
	match rank:
		0: return Color(1.0, 0.85, 0.0)   # gold
		1: return Color(0.8, 0.8, 0.85)   # silver
		2: return Color(0.8, 0.5, 0.25)   # bronze
		_: return Color(0.7, 0.7, 0.7)    # grey

func _ready():
	display_scores(GameManager.indv_scores)
