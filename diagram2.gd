extends Node2D

var parent: Node 

func _draw() -> void:
	if not parent:
		return

	var state: String = parent.diagram_state
	var btn_text: String = parent.active_button
	var btn_color: Color = parent.button_color
	var t_scale: float = parent.timer_scale
	var font := ThemeDB.fallback_font

	if state == "prompt":
		# Draw Thought Bubble
		draw_circle(Vector2(0, -40), 25, Color(1, 1, 1))
		var bubble_pts = PackedVector2Array([Vector2(-10, -20), Vector2(10, -20), Vector2(0, 0)])
		draw_colored_polygon(bubble_pts, Color(1, 1, 1))
		
		# Draw Button Prompt
		draw_circle(Vector2(0, -40), 16, btn_color)
		draw_string(font, Vector2(-6, -34), btn_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(0, 0, 0))
		
		# Draw Shrinking Timer Bar
		draw_rect(Rect2(-40, 70, 80, 8), Color(0.2, 0.2, 0.2))
		draw_rect(Rect2(-40, 70, 80 * t_scale, 8), Color(1.0, 0.8, 0.2))
		
	elif state == "correct":
		draw_string(font, Vector2(-40, -30), "Correct!", HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color(0.2, 0.9, 0.3))
		draw_string(font, Vector2(-20, -10), "0.85s", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1, 1, 1))
		
	elif state == "slow":
		draw_string(font, Vector2(-50, -30), "Too Slow!", HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color(0.9, 0.2, 0.2))
		draw_string(font, Vector2(-20, -10), "2.95s", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0.9, 0.2, 0.2))
