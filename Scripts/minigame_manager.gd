extends Node

var target_button: int = -1
var responses: Dictionary = {}
var is_active: bool = false
var active_players: int = 5
var player_scores: Dictionary = {}
var game_over: bool = false
var match_history: Array = []

@onready var timer: Timer = $Timer
@onready var game_timer: Timer = $GameTimer
@onready var winner_label: Label = $CanvasLayer/WinnerLabel
var possible_buttons: Array[int] = [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y]

func _ready() -> void:
	for i in range(active_players):
		player_scores[i] = 0
		
	game_timer.start()
	await get_tree().create_timer(2.0).timeout
	start_round()

func start_round() -> void:
	if game_over:
		return
		
	responses.clear()
	target_button = possible_buttons[randi() % possible_buttons.size()]
	is_active = true
	
	get_tree().call_group("players", "show_thought_bubble", target_button)
	
	var current_limit = 1.0 + (4.0 * (game_timer.time_left / 60.0))
	timer.start(current_limit)

func register_input(device_id: int, button_pressed: int) -> void:
	if not is_active or responses.has(device_id):
		return
		
	var is_correct = (button_pressed == target_button)
	var time_taken = timer.wait_time - timer.time_left
	
	responses[device_id] = {"correct": is_correct, "time": time_taken}
	
	var is_last_player = (responses.size() == active_players)
	var all_correct = true
	
	if is_last_player:
		for id in responses:
			if not responses[id]["correct"]:
				all_correct = false
				
	var suppress_immediate = (is_last_player and all_correct and is_correct)
	
	if not suppress_immediate:
		var players = get_tree().get_nodes_in_group("players")
		for player in players:
			if player.device_id == device_id:
				var state_string = "correct" if is_correct else "wrong"
				player.show_feedback(state_string, time_taken)
				break
	
	if is_last_player:
		end_round()

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
	print("ending")
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
		winner_label.text = "Player " + str(winners[0]) + " Wins!\nScore: " + str(highest_score)
	else:
		var tie_string = "Tie: "
		for w in winners:
			tie_string += "P" + str(w) + " "
		winner_label.text = tie_string + "\nScore: " + str(highest_score)
		
	if winners.size() > 0:
		# Example: Make the first winner in the list (or all of them) jump
		var winning_id = winners[0] 
		
		var players = get_tree().get_nodes_in_group("players")
		for player in players:
			if player.device_id == winning_id:
				var initial_y = player.position.y
				var p_tween = create_tween()
				
				# Jump up, then fall down
				p_tween.tween_property(player, "position:y", initial_y - 40.0, 0.25).set_ease(Tween.EASE_OUT)
				p_tween.tween_property(player, "position:y", initial_y, 0.25).set_ease(Tween.EASE_IN)
				# Make the winner spin or play a victory animation here instead
				break
		
	winner_label.visible = true
	$CPUParticles2D.emitting = true
