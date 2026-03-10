extends CharacterBody2D
class_name Skeptic

static var SKEPTIC_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/characters/skeptics/skeptic_01.png"),
	preload("res://assets/sprites/characters/skeptics/skeptic_02.png"),
	preload("res://assets/sprites/characters/skeptics/skeptic_03.png")
]

@export var speed: float = 58.0
@export var flee_speed_multiplier: float = 1.35
@export var flee_radius: float = 120.0
@export var influence_radius: float = 80.0
@export var reaction_radius: float = 120.0
@export var reaction_cooldown_min: float = 1.5
@export var reaction_cooldown_max: float = 3.0

var _direction: Vector2 = Vector2.RIGHT
var _direction_timer: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _cursor: CursorEntity
var _game_manager: GameManager
var _reaction_timer: float = 0.0
var _reaction_tween: Tween

func _ready() -> void:
	_rng.randomize()
	_pick_new_direction()
	_cursor = get_tree().get_first_node_in_group("cursor") as CursorEntity
	_game_manager = get_tree().get_first_node_in_group("game_manager") as GameManager
	_apply_random_skeptic_texture()
	_reset_reaction_timer()

func _apply_random_skeptic_texture() -> void:
	var sprite: Sprite2D = $Sprite2D as Sprite2D
	if sprite == null:
		return
	if SKEPTIC_TEXTURES.is_empty():
		return
	var index: int = _rng.randi_range(0, SKEPTIC_TEXTURES.size() - 1)
	sprite.texture = SKEPTIC_TEXTURES[index]

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

	_direction_timer -= delta
	if _direction_timer <= 0.0:
		_pick_new_direction()
	velocity = _direction * speed

	_update_fear_reaction(delta)

	move_and_slide()
	_bounce_at_edges()

func _update_fear_reaction(delta: float) -> void:
	if _game_manager == null or _cursor == null:
		return
	if _game_manager.final_sequence_active or _game_manager.final_gathering_active:
		return
	if _game_manager.are_npcs_paused():
		return

	_reaction_timer -= delta
	if _reaction_timer > 0.0:
		return
	_reset_reaction_timer()

	var distance_to_cursor: float = global_position.distance_to(_cursor.global_position)
	var effective_reaction_radius: float = max(reaction_radius, _cursor.outer_awareness_radius)
	if distance_to_cursor > effective_reaction_radius:
		return

	var influence_strength: int = _cursor.get_influence_strength_for_position(global_position)
	if influence_strength == CursorEntity.InfluenceStrength.NONE:
		return

	var away: Vector2 = (global_position - _cursor.global_position).normalized()
	if away == Vector2.ZERO:
		away = _direction

	var pressure_modifier: float = _cursor.get_skeptic_pressure_modifier()
	var movement_distance: float = 0.0
	var move_duration: float = _rng.randf_range(0.45, 0.8)
	match influence_strength:
		CursorEntity.InfluenceStrength.WEAK:
			movement_distance = _rng.randf_range(8.0, 12.0) * pressure_modifier
		CursorEntity.InfluenceStrength.MEDIUM:
			movement_distance = _rng.randf_range(18.0, 24.0) * pressure_modifier
		CursorEntity.InfluenceStrength.STRONG:
			movement_distance = _rng.randf_range(35.0, 40.0) * pressure_modifier
			move_duration = _rng.randf_range(0.28, 0.45)
		_:
			return
	move_duration = max(0.2, move_duration / pressure_modifier)

	var target_position: Vector2 = global_position + away * movement_distance
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	target_position.x = clamp(target_position.x, 0.0, view_size.x)
	target_position.y = clamp(target_position.y, 0.0, view_size.y)

	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()
	_reaction_tween = create_tween()
	_reaction_tween.tween_property(self, "global_position", target_position, move_duration)

func _reset_reaction_timer() -> void:
	var min_cd: float = min(reaction_cooldown_min, reaction_cooldown_max)
	var max_cd: float = max(reaction_cooldown_min, reaction_cooldown_max)
	var pressure_modifier: float = 1.0
	if _cursor != null:
		pressure_modifier = _cursor.get_skeptic_pressure_modifier()
	_reaction_timer = _rng.randf_range(min_cd, max_cd) / pressure_modifier

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


