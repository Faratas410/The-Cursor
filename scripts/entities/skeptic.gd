extends CharacterBody2D
class_name Skeptic

@export var speed: float = 58.0
@export var flee_speed_multiplier: float = 1.35
@export var flee_radius: float = 120.0
@export var influence_radius: float = 80.0

var _direction: Vector2 = Vector2.RIGHT
var _direction_timer: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _cursor: CursorEntity
var _game_manager: GameManager

func _ready() -> void:
	_rng.randomize()
	_pick_new_direction()
	_cursor = get_tree().get_first_node_in_group("cursor") as CursorEntity
	_game_manager = get_tree().get_first_node_in_group("game_manager") as GameManager

func _physics_process(delta: float) -> void:
	if _game_manager != null and _game_manager.are_npcs_paused():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _cursor != null and _game_manager != null and _game_manager.final_gathering_active:
		var to_cursor: Vector2 = _cursor.global_position - global_position
		if to_cursor.length() <= 16.0:
			velocity = Vector2.ZERO
		else:
			velocity = to_cursor.normalized() * speed * 0.6
		move_and_slide()
		return

	if _cursor != null and global_position.distance_to(_cursor.global_position) <= flee_radius:
		var away: Vector2 = (global_position - _cursor.global_position).normalized()
		if away == Vector2.ZERO:
			away = _direction
		velocity = away * speed * flee_speed_multiplier
	else:
		_direction_timer -= delta
		if _direction_timer <= 0.0:
			_pick_new_direction()
		velocity = _direction * speed

	move_and_slide()
	_bounce_at_edges()

func _pick_new_direction() -> void:
	_direction = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)).normalized()
	if _direction == Vector2.ZERO:
		_direction = Vector2.RIGHT
	_direction_timer = _rng.randf_range(0.8, 1.8)

func _bounce_at_edges() -> void:
	var view_size: Vector2 = get_viewport_rect().size
	var bounced: bool = false

	if global_position.x < 0.0:
		global_position.x = 0.0
		_direction.x = abs(_direction.x)
		bounced = true
	elif global_position.x > view_size.x:
		global_position.x = view_size.x
		_direction.x = -abs(_direction.x)
		bounced = true

	if global_position.y < 0.0:
		global_position.y = 0.0
		_direction.y = abs(_direction.y)
		bounced = true
	elif global_position.y > view_size.y:
		global_position.y = view_size.y
		_direction.y = -abs(_direction.y)
		bounced = true

	if bounced:
		_direction = _direction.normalized()
		_direction_timer = _rng.randf_range(0.6, 1.2)