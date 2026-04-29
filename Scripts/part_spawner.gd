extends Node2D

# ─────────────────────────────────────────────
#  Part Spawner – drops one screw on each side
#  every 2 seconds, no randomness in timing.
# ─────────────────────────────────────────────
@export var spawn_interval: float = 2.0
@export var max_active_parts: int = 10

const PART_SCENE_PATH: String = "res://Part.tscn"

const SCREEN_LEFT:  float = 60.0
const SCREEN_RIGHT: float = 1220.0
const CENTER_LINE:  float = 640.0

@onready var game_manager: Node = get_node("/root/Main/GameManager")

var _timer: float = 0.0
var _part_scene: PackedScene = null

func _ready() -> void:
	_part_scene = load(PART_SCENE_PATH)
	if _part_scene == null:
		push_error("PartSpawner: could not load " + PART_SCENE_PATH)

func _process(delta: float) -> void:
	if game_manager and game_manager.game_over:
		return

	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_on_side(true)   # Team A side
		_spawn_on_side(false)  # Team B side

func _spawn_on_side(left: bool) -> void:
	if _part_scene == null:
		return

	# Count parts already on this side to avoid overcrowding
	var active := get_tree().get_nodes_in_group("parts")
	var side_count := 0
	for p in active:
		if left and p.position.x < CENTER_LINE:
			side_count += 1
		elif not left and p.position.x >= CENTER_LINE:
			side_count += 1

	if side_count >= max_active_parts / 2:
		return

	var part: Node = _part_scene.instantiate()
	get_tree().current_scene.add_child(part)

	if left:
		part.position = Vector2(randf_range(SCREEN_LEFT, CENTER_LINE - 30.0), -30.0)
	else:
		part.position = Vector2(randf_range(CENTER_LINE + 30.0, SCREEN_RIGHT), -30.0)
