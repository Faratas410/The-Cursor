extends CharacterBody2D
class_name NPC

const STATE_WANDER: int = 0
const STATE_ATTRACTED: int = 1
const STATE_FOLLOW: int = 2

static var CIVILIAN_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/characters/civilians/civilian_01.png"),
	preload("res://assets/sprites/characters/civilians/civilian_02.png"),
	preload("res://assets/sprites/characters/civilians/civilian_03.png")
]

static var CULTIST_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/characters/cultists/cultist_01.png"),
	preload("res://assets/sprites/characters/cultists/cultist_02.png"),
	preload("res://assets/sprites/characters/cultists/cultist_03.png")
]

@export var speed: float = 60.0
var converted: bool = false
var state: int = STATE_WANDER

var _direction: Vector2 = Vector2.RIGHT
var _direction_timer: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _cursor: CursorEntity
var _game_manager: GameManager
var _sprite: Sprite2D

var _follow_angle: float = 0.0
var _follow_distance: float = 48.0
var _worship_timer: float = 0.0
var _chant_timer: float = 0.0
var _is_worshipping: bool = false
var _forced_attracted_until_msec: int = 0
var _is_kneeling: bool = false

func _ready() -> void:
	_rng.randomize()
	_pick_new_direction()
	_cursor = get_tree().get_first_node_in_group("cursor") as CursorEntity
	_game_manager = get_tree().get_first_node_in_group("game_manager") as GameManager
	_sprite = $Sprite2D as Sprite2D
	if not converted:
		_apply_random_civilian_texture()
	_reset_worship_timer()
	_reset_chant_timer()

func apply_converted_visual() -> void:
	converted = true
	if _sprite == null:
		return
	if CULTIST_TEXTURES.is_empty():
		return
	var index: int = _rng.randi_range(0, CULTIST_TEXTURES.size() - 1)
	_sprite.texture = CULTIST_TEXTURES[index]

func _apply_random_civilian_texture() -> void:
	if _sprite == null:
		return
	if CIVILIAN_TEXTURES.is_empty():
		return
	var index: int = _rng.randi_range(0, CIVILIAN_TEXTURES.size() - 1)
	_sprite.texture = CIVILIAN_TEXTURES[index]

func _physics_process(delta: float) -> void:
	if _game_manager != null and _game_manager.cursor_locked and not _is_kneeling and state == STATE_FOLLOW:
		perform_kneel()

	if _game_manager != null and _game_manager.are_npcs_paused():
		velocity = Vector2.ZERO
		return

	if _is_worshipping:
		velocity = Vector2.ZERO
		return

	if _game_manager != null and _game_manager.final_gathering_active:
		_process_final_gathering()
		move_and_slide()
		_update_gaze(delta)
		return

	if state == STATE_FOLLOW:
		_follow_cursor(delta)
		_update_worship(delta)
		_update_chant(delta)
	else:
		_update_state_from_cursor()
		if state == STATE_ATTRACTED:
			_move_toward_cursor()
		else:
			_wander(delta)

	move_and_slide()
	_bounce_at_edges()
	_update_gaze(delta)

func become_follower(angle: float, distance: float) -> void:
	apply_converted_visual()
	state = STATE_FOLLOW
	_follow_angle = angle
	_follow_distance = distance
	if is_in_group("wild_npc"):
		remove_from_group("wild_npc")
	if not is_in_group("followers"):
		add_to_group("followers")
	_reset_worship_timer()
	_reset_chant_timer()

func trigger_worship_now() -> void:
	if not is_inside_tree():
		return
	_start_worship_animation()
	_reset_worship_timer()

func set_forced_attracted(duration_seconds: float) -> void:
	_forced_attracted_until_msec = Time.get_ticks_msec() + int(duration_seconds * 1000.0)

func perform_kneel() -> void:
	if _is_kneeling:
		return
	_is_kneeling = true

	var target_scale: Vector2 = Vector2(scale.x * 0.9, scale.y * 0.62)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 1.1)

func _process_final_gathering() -> void:
	if _cursor == null:
		velocity = Vector2.ZERO
		return

	if state == STATE_FOLLOW:
		var target_circle: Vector2 = _get_final_circle_target()
		var to_circle: Vector2 = target_circle - global_position
		if to_circle.length() <= 5.0:
			velocity = Vector2.ZERO
		else:
			velocity = to_circle.normalized() * speed * 0.6
	else:
		var to_cursor: Vector2 = _cursor.global_position - global_position
		if to_cursor.length() <= 22.0:
			velocity = Vector2.ZERO
		else:
			velocity = to_cursor.normalized() * speed * 0.55

func _get_final_circle_target() -> Vector2:
	if _cursor == null:
		return global_position

	var followers: Array = get_tree().get_nodes_in_group("followers")
	var my_id: int = get_instance_id()
	var index: int = 0
	for node: Node in followers:
		if node.get_instance_id() < my_id:
			index += 1

	var count: int = max(1, followers.size())
	var angle: float = (TAU * float(index)) / float(count)
	var radius: float = 120.0 + (float(int(index / 20)) * 18.0)
	return _cursor.global_position + Vector2.RIGHT.rotated(angle) * radius

func _update_state_from_cursor() -> void:
	if Time.get_ticks_msec() < _forced_attracted_until_msec:
		state = STATE_ATTRACTED
		return

	if _cursor == null:
		state = STATE_WANDER
		return

	var distance_to_cursor: float = global_position.distance_to(_cursor.global_position)
	if distance_to_cursor <= _cursor.attraction_radius:
		state = STATE_ATTRACTED
	else:
		state = STATE_WANDER

func _wander(delta: float) -> void:
	_direction_timer -= delta
	if _direction_timer <= 0.0:
		_pick_new_direction()
	velocity = _direction * speed

func _move_toward_cursor() -> void:
	if _cursor == null:
		velocity = _direction * speed
		return

	var desired: Vector2 = (_cursor.global_position - global_position).normalized()
	if desired == Vector2.ZERO:
		desired = _direction
	_direction = desired
	velocity = _direction * speed * 1.25

func _follow_cursor(_delta: float) -> void:
	if _cursor == null:
		velocity = Vector2.ZERO
		return

	var target_position: Vector2
	if _is_procession_active():
		target_position = _get_procession_target()
	else:
		target_position = _cursor.global_position + Vector2.RIGHT.rotated(_follow_angle) * _follow_distance

	var to_target: Vector2 = target_position - global_position
	var distance: float = to_target.length()
	if distance <= 6.0:
		velocity = Vector2.ZERO
		return

	velocity = to_target.normalized() * speed * 0.7

func _is_procession_active() -> bool:
	if _cursor == null:
		return false
	var followers: Array = get_tree().get_nodes_in_group("followers")
	var near_count: int = 0
	for node: Node in followers:
		var follower: NPC = node as NPC
		if follower == null:
			continue
		if follower.global_position.distance_to(_cursor.global_position) <= 220.0:
			near_count += 1
	return near_count >= 10

func _get_procession_target() -> Vector2:
	if _cursor == null:
		return global_position

	var followers: Array = get_tree().get_nodes_in_group("followers")
	var my_id: int = get_instance_id()
	var index: int = 0
	for node: Node in followers:
		if node.get_instance_id() < my_id:
			index += 1

	var forward: Vector2 = _cursor.movement_direction
	if forward == Vector2.ZERO:
		forward = Vector2.UP
	var behind: Vector2 = -forward
	var lateral: Vector2 = behind.orthogonal().normalized()

	var row: int = index
	var spacing_back: float = 18.0
	var spacing_side: float = 10.0
	var side_sign: float = -1.0 if row % 2 == 0 else 1.0
	var side_step: float = float((row + 1) / 2)
	var offset: Vector2 = behind * (28.0 + float(row) * spacing_back) + lateral * side_sign * side_step * spacing_side
	return _cursor.global_position + offset

func _update_worship(delta: float) -> void:
	_worship_timer -= delta
	if _worship_timer <= 0.0:
		_start_worship_animation()
		_reset_worship_timer()

func _start_worship_animation() -> void:
	if _is_worshipping:
		return

	_is_worshipping = true
	var start_scale: Vector2 = scale
	var base_y: float = position.y
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", start_scale * 1.12, 0.18)
	tween.parallel().tween_property(self, "position:y", base_y - 8.0, 0.18)
	tween.tween_property(self, "scale", start_scale, 0.18)
	tween.parallel().tween_property(self, "position:y", base_y, 0.18)
	tween.finished.connect(_on_worship_finished)

func _on_worship_finished() -> void:
	_is_worshipping = false

func _update_chant(delta: float) -> void:
	_chant_timer -= delta
	if _chant_timer > 0.0:
		return

	_reset_chant_timer()
	if _rng.randf() > 0.35:
		return

	var start_scale: Vector2 = scale
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", start_scale * 1.06, 0.12)
	tween.tween_property(self, "scale", start_scale, 0.16)

func _reset_worship_timer() -> void:
	_worship_timer = _rng.randf_range(3.0, 6.0)

func _reset_chant_timer() -> void:
	_chant_timer = _rng.randf_range(2.5, 5.5)

func _update_gaze(delta: float) -> void:
	if _sprite == null or _cursor == null:
		return

	if state == STATE_ATTRACTED or state == STATE_FOLLOW or (_game_manager != null and _game_manager.final_gathering_active):
		var target_angle: float = (_cursor.global_position - global_position).angle()
		_sprite.rotation = lerp_angle(_sprite.rotation, target_angle, clamp(delta * 8.0, 0.0, 1.0))
	else:
		_sprite.rotation = lerp_angle(_sprite.rotation, 0.0, clamp(delta * 6.0, 0.0, 1.0))

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

