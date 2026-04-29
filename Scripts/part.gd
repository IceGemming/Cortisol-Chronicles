extends RigidBody2D

# ─────────────────────────────────────────────
#  Part – falls from the sky, gets picked up
# ─────────────────────────────────────────────

var is_carried: bool = false
var carrier: Node = null

const GROUND_Y: float = 560
const PART_TEXTURE_PATH: String = "res://Assets/part1.png"

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("parts")

	# Load part texture automatically
	var tex = load(PART_TEXTURE_PATH)
	if tex:
		sprite.texture = tex
	else:
		push_warning("Part: could not load " + PART_TEXTURE_PATH)

	# Gentle spin while falling
	angular_velocity = randf_range(-1.5, 1.5)
	gravity_scale = 1.2

func _physics_process(_delta: float) -> void:
	# Stop at ground level
	if position.y >= GROUND_Y and not is_carried:
		linear_velocity  = Vector2.ZERO
		angular_velocity = 0.0
		position.y       = GROUND_Y
		freeze           = true

func pick_up(player: Node) -> void:
	is_carried          = true
	carrier             = player
	freeze              = true
	collision.disabled  = true
	linear_velocity     = Vector2.ZERO
	angular_velocity    = 0.0
	rotation            = 0.0

func drop(drop_position: Vector2) -> void:
	is_carried          = false
	carrier             = null
	freeze              = false
	collision.disabled  = false
	position            = drop_position
	linear_velocity     = Vector2(randf_range(-30, 30), 50)

func destroy() -> void:
	queue_free()
