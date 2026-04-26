class_name GameScene
extends Node2D

const DEFAULT_SPAWN_POSITIONS: Array[Vector2] = [
	Vector2(-240, 0),
	Vector2(-120, 40),
	Vector2(0, 80),
	Vector2(120, 40),
	Vector2(240, 0),
]

@export var player_count: int = 5
@export var spawn_positions: Array[Vector2] = DEFAULT_SPAWN_POSITIONS.duplicate()

@onready var player_template: PlayerCharacter = $PlayerTemplate
var players: Array[PlayerCharacter] = []

func _ready() -> void:
	_spawn_players()

func _spawn_players() -> void:
	if player_template == null:
		push_error("Player template missing, cannot spawn characters.")
		return

	var positions_count: int = spawn_positions.size()
	if positions_count == 0:
		spawn_positions = DEFAULT_SPAWN_POSITIONS
		positions_count = spawn_positions.size()

	var active_player_count: int = max(1, player_count)
	players.clear()

	player_template.position = spawn_positions[0]
	player_template.name = "Player0"
	players.append(player_template)
	var n = 0
	for player_index in range(1, active_player_count):
		player_template.device_id = n
		n+=1
		var clone: PlayerCharacter = player_template.duplicate() as PlayerCharacter
		if clone == null:
			continue

		clone.position = spawn_positions[player_index % positions_count]
		clone.device_id = player_index
		clone.name = "Player%d" % player_index
		add_child(clone)
		players.append(clone)
