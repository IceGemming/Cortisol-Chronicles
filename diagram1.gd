# Diagram_RobotRepair.gd
extends Node2D

var parent: Node 

# Sprites passed in from the parent (tutorial_game_1.gd)
var robot_sprite: Texture2D
var screw_sprite: Texture2D
var player_sprite: Texture2D

func _draw():
	if not parent:
		return

	# Explicitly cast to float to resolve the Parser Error
	var py: float = parent.get("part_y")
	var px: float = parent.get("player_x")
	var carrying: bool = parent.get("has_part")

	# Draw Ground
	draw_line(Vector2(-120, 60), Vector2(120, 60), Color(0.3, 0.3, 0.3), 4)

	# Draw Robot (The Goal) — replaces the two blue draw_rect calls
	if robot_sprite:
		# Centre the sprite over the same position the rectangles occupied
		# Original body: Rect2(80, 10, 30, 50)  →  top-left (80, 10), size 30×50
		var robot_size := Vector2(60, 80)
		draw_texture_rect(robot_sprite, Rect2(Vector2(70, -20), robot_size), false)
	else:
		# Fallback: original primitive drawing
		var robot_col := Color(0.2, 0.6, 1.0)
		draw_rect(Rect2(80, 10, 30, 50), robot_col)
		draw_rect(Rect2(90, -5, 10, 15), robot_col)

	# Draw Falling Part — replaces the yellow draw_rect
	if not carrying:
		if screw_sprite:
			draw_texture_rect(screw_sprite, Rect2(Vector2(-15, py), Vector2(30, 30)), false)
		else:
			draw_rect(Rect2(-5, py, 10, 10), Color(1, 0.8, 0.2))

	# Draw Player — replaces the draw_circle
	if player_sprite:
		# Centre the sprite on the same position the circle occupied
		# Original circle: centre (px, 45), radius 10  →  bounding box 20×20
		var player_size := Vector2(40, 40)
		draw_texture_rect(player_sprite, Rect2(Vector2(px - 20, 20), player_size), false)
	else:
		draw_circle(Vector2(px, 45), 10, Color(0.9, 0.9, 0.9))

	# If carrying, draw the part above the player's head
	if carrying:
		if screw_sprite:
			draw_texture_rect(screw_sprite, Rect2(Vector2(px - 15, -5), Vector2(30, 30)), false)
		else:
			draw_rect(Rect2(px - 5, 25, 10, 10), Color(1, 0.8, 0.2))

	# Draw Input Prompt
	if not carrying and py >= 40:
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(px - 20, 20), "Press [X]", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)
