extends Node

const ROUND_DURATION: float = 45.0
const ROUND_PAUSE:    float = 4.0

var round_score_a: int   = 0
var round_score_b: int   = 0
var wins_a:        int   = 0
var wins_b:        int   = 0
var round_num:     int   = 1
var time_left:     float = ROUND_DURATION
var game_over:     bool  = false
var _round_ended:  bool  = false

@onready var label_a:   Label = get_node("/root/Main/UI/LabelA")
@onready var label_b:   Label = get_node("/root/Main/UI/LabelB")
@onready var win_label: Label = get_node("/root/Main/UI/WinLabel")

func _ready() -> void:
	win_label.visible = false
	_refresh_ui()

func _process(delta: float) -> void:
	if game_over or _round_ended:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left    = 0.0
		_round_ended = true
		_end_round()
		return
	_refresh_ui()

func update_score(team: String, _ignored: int = 0) -> void:
	if game_over or _round_ended:
		return
	if team == "A":
		round_score_a += 1
	else:
		round_score_b += 1
	_refresh_ui()

func _refresh_ui() -> void:
	var secs := int(ceil(time_left))
	label_a.text = "Team A: %d  |  Wins: %d  |  %02d s" % [round_score_a, wins_a, secs]
	label_b.text = "Team B: %d  |  Wins: %d  |  %02d s" % [round_score_b, wins_b, secs]

func _end_round() -> void:
	var result: String
	if round_score_a > round_score_b:
		wins_a += 1
		result = "TEAM A wins Round %d!  ( %d - %d )" % [round_num, round_score_a, round_score_b]
	elif round_score_b > round_score_a:
		wins_b += 1
		result = "TEAM B wins Round %d!  ( %d - %d )" % [round_num, round_score_a, round_score_b]
	else:
		result = "Round %d DRAW!  ( %d - %d )" % [round_num, round_score_a, round_score_b]

	if wins_a >= 2:
		_declare_match_winner("TEAM A", result)
		return
	elif wins_b >= 2:
		_declare_match_winner("TEAM B", result)
		return

	win_label.text    = result + "\nNext round in %d s..." % [int(ROUND_PAUSE)]
	win_label.visible = true
	get_tree().paused = true
	var t := get_tree().create_timer(ROUND_PAUSE, true, false, true)
	t.timeout.connect(_on_round_pause_done)

func _on_round_pause_done() -> void:
	get_tree().paused = false
	win_label.visible = false
	round_num     += 1
	round_score_a  = 0
	round_score_b  = 0
	time_left      = ROUND_DURATION
	_round_ended   = false
	for part in get_tree().get_nodes_in_group("parts"):
		part.queue_free()
	for player in get_tree().get_nodes_in_group("players"):
		player.carried_part = null
	for robot in get_tree().get_nodes_in_group("robot_A") + get_tree().get_nodes_in_group("robot_B"):
		robot.reset_round()
	_refresh_ui()

func _declare_match_winner(team_name: String, last_round: String) -> void:
	game_over         = true
	win_label.text    = last_round + "\n\n%s WINS THE MATCH!  ( %d - %d )" % [team_name, wins_a, wins_b]
	win_label.visible = true
	GameManager.get_robot_score(wins_a, wins_b)
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://cutscene_1_end.tscn")
