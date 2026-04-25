extends Camera2D

@export var min_zoom: float = 0.5
@export var max_zoom: float = 1.0
@export var margin: float = 150.0
@export var zoom_speed: float = 5.0

#calculates the center point between all players to move the camera, 
#and calculates the distance between the furthest players to dynamically zoom in and out, 
#keeping everyone on screen
func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() == 0:
		return
		
	var target_position = Vector2.ZERO
	var min_pos = players[0].global_position
	var max_pos = players[0].global_position
	
	# Find center point and bounding box of all players
	for player in players:
		target_position += player.global_position
		min_pos.x = min(min_pos.x, player.global_position.x)
		min_pos.y = min(min_pos.y, player.global_position.y)
		max_pos.x = max(max_pos.x, player.global_position.x)
		max_pos.y = max(max_pos.y, player.global_position.y)
		
	# Average position
	target_position /= players.size()
	global_position = target_position
	
	# Calculate required zoom to fit the bounding box
	var screen_size = get_viewport_rect().size
	var rect_size = max_pos - min_pos
	rect_size += Vector2(margin, margin) # Add padding
	
	var zoom_x = screen_size.x / rect_size.x if rect_size.x > 0 else max_zoom
	var zoom_y = screen_size.y / rect_size.y if rect_size.y > 0 else max_zoom
	
	# Pick the smaller zoom factor to ensure all players fit, clamped to min/max
	var target_zoom_val = clamp(min(zoom_x, zoom_y), min_zoom, max_zoom)
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	
	# Interpolate for smooth camera movement
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
	
