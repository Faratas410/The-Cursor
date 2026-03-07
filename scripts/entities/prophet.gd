extends CharacterBody2D
class_name Prophet

static var PROPHET_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/characters/prophets/prophet_01.png"),
	preload("res://assets/sprites/characters/prophets/prophet_02.png"),
	preload("res://assets/sprites/characters/prophets/prophet_03.png")
]

@export var speed: float = 42.0

var _cursor: CursorEntity
var _game_manager: GameManager
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_cursor = get_tree().get_first_node_in_group("cursor") as CursorEntity
	_game_manager = get_tree().get_first_node_in_group("game_manager") as GameManager
	_apply_random_prophet_texture()

func _apply_random_prophet_texture() -> void:
	var sprite: Sprite2D = $Sprite2D as Sprite2D
	if sprite == null:
		return
	if PROPHET_TEXTURES.is_empty():
		return
	var index: int = _rng.randi_range(0, PROPHET_TEXTURES.size() - 1)
	sprite.texture = PROPHET_TEXTURES[index]

func _physics_process(_delta: float) -> void:
	if _game_manager != null and _game_manager.are_npcs_paused():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _cursor == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_cursor: Vector2 = _cursor.global_position - global_position
	var stop_distance: float = 56.0
	var speed_multiplier: float = 1.0
	if _game_manager != null and _game_manager.final_gathering_active:
		stop_distance = 12.0
		speed_multiplier = 0.6

	if to_cursor.length() <= stop_distance:
		velocity = Vector2.ZERO
	else:
		velocity = to_cursor.normalized() * speed * speed_multiplier
	move_and_slide()