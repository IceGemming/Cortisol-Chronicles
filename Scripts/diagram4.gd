extends Node2D

var parent: Node

func _draw():
	if not parent:
		return

	var font     := ThemeDB.fallback_font
	var anim     : float = parent.anim_time
	var page     : int   = parent.current_page

	if page == 0 or page == 2:
		# Draw 3 floating task buttons with draining bars
		var tasks := ["Proofread essay", "Attach resume", "Check deadline"]
		for i in 3:
			var bx := -110.0 + i * 80.0
			var by := -20.0 + sin(anim * 1.2 + i) * 6.0
			var bw := 100.0
			var bh := 36.0
			# Button background
			draw_rect(Rect2(bx, by, bw, bh), Color(0.18, 0.18, 0.28, 0.95))
			draw_rect(Rect2(bx, by, bw, bh), Color(0.5, 0.5, 0.8), false, 1.5)
			# Label
			draw_string(font, Vector2(bx + 6, by + bh * 0.6),
						tasks[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1,1,1))
			# Progress bar — each drains at different speed
			var pct : float = clamp(0.5 + 0.5 * sin(anim * (0.4 + i * 0.2)), 0.0, 1.0)
			draw_rect(Rect2(bx, by + bh - 6, bw, 6), Color(0.1, 0.1, 0.1))
			draw_rect(Rect2(bx, by + bh - 6, bw * pct, 6), Color(1.0 - pct, pct, 0.0))

	elif page == 1:
		# Draw 5 colored cursors with labels
		var colors := [
			Color(1,0.3,0.3), Color(0.3,0.8,1),
			Color(0.3,1,0.4), Color(1,1,0.3), Color(1,0.4,1)
		]
		var names := ["P1","P2","P3","P4","P5"]
		for i in 5:
			var cx := -100.0 + i * 50.0
			var cy := sin(anim * 1.5 + i * 1.2) * 20.0
			var col: Color = colors[i]
			draw_line(Vector2(cx - 10, cy), Vector2(cx + 10, cy), col, 2.0)
			draw_line(Vector2(cx, cy - 10), Vector2(cx, cy + 10), col, 2.0)
			draw_circle(Vector2(cx, cy), 3.0, col)
			draw_string(font, Vector2(cx + 6, cy - 4), names[i],
						HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col)

	elif page == 3:
		# Draw a pulsing send button
		var pulse := 0.7 + 0.3 * sin(anim * 4.0)
		var send_color := Color(1.0, 0.8 * pulse, 0.0)
		draw_rect(Rect2(-70, -20, 140, 44), Color(0.15, 0.15, 0.1))
		draw_rect(Rect2(-70, -20, 140, 44), send_color, false, 2.5)
		draw_string(font, Vector2(-38, 8), "HIT SEND",
					HORIZONTAL_ALIGNMENT_LEFT, -1, 18, send_color)
		# Cursor approaching
		var cx := -60.0 + sin(anim * 0.8) * 20.0
		var cy := -50.0 + anim * 8.0
		cy = min(cy, -25.0)
		if cy >= -25.0:
			cy = -25.0
		draw_line(Vector2(cx - 8, cy), Vector2(cx + 8, cy), Color(0.3,1,0.4), 2.0)
		draw_line(Vector2(cx, cy - 8), Vector2(cx, cy + 8), Color(0.3,1,0.4), 2.0)
		draw_circle(Vector2(cx, cy), 3.0, Color(0.3,1,0.4))
