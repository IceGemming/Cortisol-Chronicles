extends Node

var target_button: int = -1
var responses: Dictionary = {}
var is_active: bool = false
var active_players: int = 5
var player_scores: Dictionary = {}
var game_over: bool = false
var match_history: Array = []
var can_proceed: bool = false

var continue_label: Label
var warning_label: Label
var has_crossed_3: bool = false
var has_crossed_2: bool = false

@onready var timer: Timer = $Timer
@onready var game_timer: Timer = $GameTimer
@onready var winner_label: Label = $CanvasLayer/WinnerLabel
var possible_buttons: Array[int] = [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y]

func _ready() -> void:
	for i in range(active_players):
		player_scores[i] = 0
		
	_setup_ui_labels()
		
	game_timer.start()
	await get_tree().create_timer(2.0).timeout
	start_round()

func _setup_ui_labels() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var custom_font = load("res://Assets/Kenney Fonts/Fonts/Kenney Future Narrow.ttf")
	
	# Common label settings template
	var base_settings = LabelSettings.new()
	base_settings.font = custom_font
	base_settings.font_size = 48
	base_settings.outline_size = 8
	base_settings.outline_color = Color.BLACK
	base_settings.shadow_size = 4
	base_settings.shadow_color = Color(0, 0, 0, 0.8)
	
	continue_label = Label.new()
	continue_label.text = "Press X to continue"
	continue_label.label_settings = base_settings.duplicate()
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.size = Vector2(screen_size.x, 100)
	continue_label.position = Vector2(0, screen_size.y - 180)
	continue_label.modulate = Color(1.0, 1.0, 1.0)
	continue_label.hide()
	$CanvasLayer.add_child(continue_label)
	
	warning_label = Label.new()
	warning_label.text = "You are running out of time, faster!"
	warning_label.label_settings = base_settings.duplicate()
	warning_label.label_settings.font_color = Color(1, 0.2, 0.2) # Bright Red
	warning_label.label_settings.font_size = 46
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.size = Vector2(screen_size.x, 100)
	warning_label.position = Vector2(0, 150)
	warning_label.hide()
	$CanvasLayer.add_child(warning_label)
	
	# Apply font to winner label if it doesn't have it
	if winner_label.label_settings:
		winner_label.label_settings.font = custom_font

func _process(_delta: float) -> void:
	if can_proceed:
		var pressed_x := false
		if Input.is_physical_key_pressed(KEY_X):
			pressed_x = true
		for i in 5:
			if Input.is_joy_button_pressed(i, JOY_BUTTON_X) or Input.is_joy_button_pressed(i, JOY_BUTTON_A):
				pressed_x = true
				
		if pressed_x:
			get_tree().change_scene_to_file("res://cutscene_3.tscn")

func start_round() -> void:
	if game_over:
		return
		
	responses.clear()
	target_button = possible_buttons[randi() % possible_buttons.size()]
	is_active = true
	
	get_tree().call_group("players", "show_thought_bubble", target_button)
	
	var current_limit = 1.0 + (4.0 * (game_timer.time_left / 60.0))
	
	if current_limit <= 3.0 and not has_crossed_3:
		has_crossed_3 = true
		_flash_warning()
	elif current_limit <= 2.0 and not has_crossed_2:
		has_crossed_2 = true
		_flash_warning()
		
	timer.start(current_limit)

func _flash_warning() -> void:
	warning_label.show()
	var tween = create_tween().set_loops(6)
	tween.tween_property(warning_label, "modulate:a", 0.0, 0.15)
	tween.tween_property(warning_label, "modulate:a", 1.0, 0.15)
	await get_tree().create_timer(1.8).timeout
	if is_instance_valid(tween):
		tween.kill()
	warning_label.hide()

func register_input(device_id: int, button_pressed: int) -> void:
	if not is_active or responses.has(device_id):
		return
		
	var is_correct = (button_pressed == target_button)
	var time_taken = timer.wait_time - timer.time_left
	
	responses[device_id] = {"correct": is_correct, "time": time_taken}
	
	var is_last_player = (responses.size() == active_players)
	
	if is_last_player:
		end_round()
	else:
		# Immediate feedback for individual players
		var players = get_tree().get_nodes_in_group("players")
		for player in players:
			if player.device_id == device_id:
				var state_string = "correct" if is_correct else "wrong"
				player.show_feedback(state_string, time_taken)
				break

func end_round() -> void:
	is_active = false
	timer.stop()
	get_tree().call_group("players", "hide_thought_bubble")
	
	var slowest_id: int = -1
	var max_time: float = -1.0
	var correct_count: int = 0
	
	for id in responses:
		if responses[id]["correct"]:
			correct_count += 1
			if responses[id]["time"] > max_time:
				max_time = responses[id]["time"]
				slowest_id = id
				
	if correct_count < active_players:
		slowest_id = -1
			
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		var p_id = player.device_id
		
		if not responses.has(p_id):
			player.show_feedback("wrong")
		elif p_id == slowest_id:
			player.show_feedback("slow", responses[p_id]["time"])
		else:
			if responses.has(p_id) and responses[p_id]["correct"]:
				player_scores[p_id] += 1
			
	var round_record := {}
	for i in range(active_players):
		if not responses.has(i):
			round_record[i] = {"status": "no_input", "time": 0.0}
		elif i == slowest_id:
			round_record[i] = {"status": "too_slow", "time": responses[i]["time"]}
		elif responses[i]["correct"]:
			round_record[i] = {"status": "correct", "time": responses[i]["time"]}
		else:
			round_record[i] = {"status": "wrong_button", "time": responses[i]["time"]}
			
	match_history.append(round_record)
	await get_tree().create_timer(3.0).timeout
	start_round()

func _on_timer_timeout() -> void:
	end_round()

func _on_game_timer_timeout() -> void:
	game_over = true
	GameManager.minigame_2_history = match_history
	is_active = false
	timer.stop()
	get_tree().call_group("players", "hide_thought_bubble")
	
	var highest_score = -1
	var winners = []
	
	for id in player_scores:
		if player_scores[id] > highest_score:
			highest_score = player_scores[id]
			winners.clear()
			winners.append(id)
		elif player_scores[id] == highest_score:
			winners.append(id)
			
	if winners.size() == 1:
		winner_label.text = "Player " + str(winners[0] + 1) + " Wins!\nScore: " + str(highest_score)
	else:
		var tie_string = "Tie: "
		for w in winners:
			tie_string += "P" + str(w + 1) + " "
		winner_label.text = tie_string + "\nScore: " + str(highest_score)
		
	winner_label.modulate = Color(1.0, 0.9, 0.2)
	winner_label.visible = true
	$CPUParticles2D.emitting = true
	
	GameManager.get_quiz_score(player_scores)
	
	await get_tree().create_timer(2.0).timeout
	continue_label.show()
	can_proceed = true
