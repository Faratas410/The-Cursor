extends CharacterBody2D
class_name NPC

@export var speed: float = 60.0
var converted: bool = false

var _direction: Vector2 = Vector2.RIGHT
var _direction_timer: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_pick_new_direction()

func _physics_process(delta: float) -> void:
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
	_direction_timer = _rng.randf_range(0.6, 1.8)

func _bounce_at_edges() -> void:
	var view_size: Vector2 = get_viewport_rect().size
	var did_bounce: bool = false

	if global_position.x < 0.0:
		global_position.x = 0.0
		_direction.x = abs(_direction.x)
		did_bounce = true
	elif global_position.x > view_size.x:
		global_position.x = view_size.x
		_direction.x = -abs(_direction.x)
		did_bounce = true

	if global_position.y < 0.0:
		global_position.y = 0.0
		_direction.y = abs(_direction.y)
		did_bounce = true
	elif global_position.y > view_size.y:
		global_position.y = view_size.y
		_direction.y = -abs(_direction.y)
		did_bounce = true

	if did_bounce:
		_direction = _direction.normalized()
		_direction_timer = _rng.randf_range(0.6, 1.2)