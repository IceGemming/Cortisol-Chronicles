# Diagram_EggDrop.gd
extends Node2D

var parent: Node  # set by Tutorial_EggDrop after _ready

func _draw():
	if not parent:
		return

	var cx := 0.0
	var cy := 0.0
	var tilt: float = parent.project_tilt
	var dir: float  = parent.wind_dir
	var alpha: float = parent.arrow_alpha

	# Ground line
	draw_line(Vector2(-100, 60), Vector2(100, 60), Color(0.4, 0.8, 0.3), 3)

	# Green zone
	draw_rect(Rect2(-30, 54, 60, 12), Color(0.2, 0.9, 0.3, 0.5))

	# Project box (rotated)
	var box_points: PackedVector2Array = []
	var hw := 18.0
	var hh := 28.0
	var corners := [
		Vector2(-hw, -hh), Vector2(hw, -hh),
		Vector2(hw, hh),   Vector2(-hw, hh)
	]
	for corner in corners:
		box_points.append(Vector2(
			cx + corner.x * cos(deg_to_rad(tilt)) - corner.y * sin(deg_to_rad(tilt)),
			cy - 20 + corner.x * sin(deg_to_rad(tilt)) + corner.y * cos(deg_to_rad(tilt))
		))
	draw_colored_polygon(box_points, Color(0.3, 0.5, 0.9, 0.9))
	box_points.append(box_points[0])
	draw_polyline(box_points, Color(0.6, 0.8, 1.0), 2.0)

	# Wind arrows
	var arrow_color := Color(1.0, 0.8, 0.2, alpha)
	var ax_start := -dir * 90.0
	for i in 3:
		var ay := -30.0 + i * 20.0
		var ax := ax_start + i * dir * 8.0
		draw_line(Vector2(ax, ay), Vector2(ax + dir * 40.0, ay), arrow_color, 3.0)
		# Arrowhead
		draw_line(
			Vector2(ax + dir * 40.0, ay),
			Vector2(ax + dir * 28.0, ay - 8.0),
			arrow_color, 2.5
		)
		draw_line(
			Vector2(ax + dir * 40.0, ay),
			Vector2(ax + dir * 28.0, ay + 8.0),
			arrow_color, 2.5
		)

	# Wind label
	var font := ThemeDB.fallback_font
	var wind_text := "WIND →" if dir > 0 else "← WIND"
	draw_string(font, Vector2(-30, -55), wind_text,
				HORIZONTAL_ALIGNMENT_CENTER, -1, 14,
				Color(1.0, 0.8, 0.2, alpha))

	# Tilt angle arc label
	draw_string(font, Vector2(-50, 10), "%.0f°" % abs(tilt),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 0.4, 0.4))
