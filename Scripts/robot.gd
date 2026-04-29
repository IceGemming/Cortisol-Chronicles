extends Node2D

# ─────────────────────────────────────────────
#  Robot – receives parts, notifies game manager
# ─────────────────────────────────────────────
@export var team: String = "A"

const ROBOT_TEXTURE_PATH: String = "res://Assets/robot.png"

var score: int = 0
var part_sprites: Array = []

@onready var sprite: Sprite2D   = $Sprite2D
@onready var zone:   Area2D     = $DeliveryZone
@onready var game_manager: Node = get_node("/root/Main/GameManager")

func _ready() -> void:
	add_to_group("robot_" + team)

	var tex = load(ROBOT_TEXTURE_PATH)
	if tex:
		sprite.texture = tex
	else:
		push_warning("Robot: could not load " + ROBOT_TEXTURE_PATH)

	if team == "B":
		sprite.flip_h = true

	zone.body_entered.connect(_on_body_entered)
	zone.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("players") and body.team == team:
		body.enter_robot_zone()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("players") and body.team == team:
		body.exit_robot_zone()

func receive_part(player: Node) -> void:
	if player.carried_part == null:
		return
	if player.team != team:
		return

	player.carried_part.destroy()
	player.carried_part = null

	score += 1
	_show_assembly_progress()
	# Just notify game_manager of a +1 delivery — it tracks the round score
	game_manager.update_score(team, score)

func reset_round() -> void:
	# Called between rounds to reset robot's local score and visuals
	score = 0
	for chip in part_sprites:
		chip.queue_free()
	part_sprites.clear()
	sprite.scale = Vector2(1.0, 1.0)

func _show_assembly_progress() -> void:
	var grow_factor := 1.0 + (score * 0.025)
	sprite.scale = Vector2(grow_factor, grow_factor)

	if score % 3 == 0:
		var chip := Sprite2D.new()
		add_child(chip)

		var tex = load(ROBOT_TEXTURE_PATH)
		if tex:
			chip.texture = tex

		chip.scale    = Vector2(0.12, 0.12)
		chip.modulate = Color(0.4, 1.0, 0.8, 0.9)

		var idx: int = part_sprites.size()
		chip.position = Vector2(randf_range(-20, 20), -90 - (idx * 20))
		part_sprites.append(chip)
