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

const CONVERSION_GLYPH_TEXTURE: Texture2D = preload("res://assets/vfx/conversion/conversion_glyph.png")
const CONVERSION_FLASH_TEXTURE: Texture2D = preload("res://assets/ui/effects/divine_pulse.png")
const CONVERSION_SMOKE_TEXTURE: Texture2D = preload("res://assets/vfx/cursor/cursor_trail.png")
@export var speed: float = 60.0
@export var crowd_reaction_radius: float = 120.0
@export var crowd_reaction_cooldown_min: float = 1.5
@export var crowd_reaction_cooldown_max: float = 3.0
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
var _conversion_spectacle_played: bool = false
var _idle_breath_tween: Tween
var _idle_wander_tween: Tween
var _idle_look_tween: Tween
var _idle_shift_tween: Tween
var _idle_wander_timer: float = 0.0
var _idle_look_timer: float = 0.0
var _idle_shift_timer: float = 0.0
var _idle_visual_offset: Vector2 = Vector2.ZERO
var _idle_shift_offset_x: float = 0.0
var _idle_look_angle: float = 0.0
var _idle_base_scale: Vector2 = Vector2.ONE
var _crowd_reaction_timer: float = 0.0
var _crowd_reaction_tween: Tween
var _crowd_orbit_angle: float = 0.0

func _ready() -> void:
	_rng.randomize()
	_pick_new_direction()
	_cursor = get_tree().get_first_node_in_group("cursor") as CursorEntity
	_game_manager = get_tree().get_first_node_in_group("game_manager") as GameManager
	_sprite = $Sprite2D as Sprite2D
	if _sprite != null:
		_idle_base_scale = _sprite.scale
	_reset_idle_timers()
	if not converted:
		_apply_random_civilian_texture()
	_reset_worship_timer()
	_reset_chant_timer()
	_reset_crowd_reaction_timer()

func apply_converted_visual() -> void:
	converted = true
	_stop_idle_life()
	if _sprite == null:
		return
	if CULTIST_TEXTURES.is_empty():
		return
	var index: int = _rng.randi_range(0, CULTIST_TEXTURES.size() - 1)
	_sprite.texture = CULTIST_TEXTURES[index]
	if not _conversion_spectacle_played:
		_conversion_spectacle_played = true
		_play_conversion_spectacle()

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
		_stop_idle_life()
		return

	if _is_worshipping:
		velocity = Vector2.ZERO
		_stop_idle_life()
		return

	if _game_manager != null and _game_manager.final_gathering_active:
		_process_final_gathering()
		move_and_slide()
		_update_gaze(delta)
		_stop_idle_life()
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
	_update_idle_life(delta)
	_update_crowd_reaction(delta)

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
	_reset_crowd_reaction_timer()

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
	var radius: float = 120.0 + (floor(float(index) / 20.0) * 18.0)
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
	var side_step: float = floor(float(row + 1) / 2.0)
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
	_reset_crowd_reaction_timer()
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
		var fallback_angle: float = _idle_look_angle if _is_idle_life_allowed() else 0.0
		_sprite.rotation = lerp_angle(_sprite.rotation, fallback_angle, clamp(delta * 6.0, 0.0, 1.0))

func _update_idle_life(delta: float) -> void:
	if _sprite == null:
		return
	if not _is_idle_life_allowed():
		_stop_idle_life()
		return

	_ensure_idle_breath()

	_idle_wander_timer -= delta
	if _idle_wander_timer <= 0.0:
		_idle_wander_timer = _rng.randf_range(3.0, 7.0)
		_trigger_idle_micro_wander()

	_idle_look_timer -= delta
	if _idle_look_timer <= 0.0:
		_idle_look_timer = _rng.randf_range(5.0, 10.0)
		_trigger_idle_look_around()

	_idle_shift_timer -= delta
	if _idle_shift_timer <= 0.0:
		_idle_shift_timer = _rng.randf_range(3.0, 6.0)
		_trigger_idle_shift()

	_sprite.position = Vector2(_idle_shift_offset_x + _idle_visual_offset.x, _idle_visual_offset.y)

func _is_idle_life_allowed() -> bool:
	if _game_manager == null:
		return false
	if _game_manager.final_sequence_active or _game_manager.final_gathering_active:
		return false
	if _game_manager.are_npcs_paused():
		return false
	if _is_worshipping or _is_kneeling:
		return false
	if state != STATE_WANDER:
		return false
	if Time.get_ticks_msec() < _forced_attracted_until_msec:
		return false
	if _cursor != null and global_position.distance_to(_cursor.global_position) <= _cursor.attraction_radius:
		return false
	return true

func _ensure_idle_breath() -> void:
	if _idle_breath_tween != null and _idle_breath_tween.is_running():
		return
	if _sprite == null:
		return
	_sprite.scale = _idle_base_scale
	_idle_breath_tween = create_tween()
	_idle_breath_tween.set_loops()
	_idle_breath_tween.tween_property(_sprite, "scale", _idle_base_scale * 1.02, 0.8)
	_idle_breath_tween.tween_property(_sprite, "scale", _idle_base_scale, 0.8)

func _trigger_idle_micro_wander() -> void:
	if _idle_wander_tween != null and _idle_wander_tween.is_running():
		_idle_wander_tween.kill()
	var target_offset: Vector2 = Vector2(_rng.randf_range(-6.0, 6.0), _rng.randf_range(-4.0, 4.0))
	_idle_wander_tween = create_tween()
	_idle_wander_tween.tween_property(self, "_idle_visual_offset", target_offset, 0.45)
	_idle_wander_tween.tween_property(self, "_idle_visual_offset", Vector2.ZERO, 0.55)

func _trigger_idle_look_around() -> void:
	if _idle_look_tween != null and _idle_look_tween.is_running():
		_idle_look_tween.kill()
	var target_angle: float = deg_to_rad(_rng.randf_range(-10.0, 10.0))
	_idle_look_tween = create_tween()
	_idle_look_tween.tween_property(self, "_idle_look_angle", target_angle, 0.4)
	_idle_look_tween.tween_property(self, "_idle_look_angle", 0.0, 0.4)

func _trigger_idle_shift() -> void:
	if _idle_shift_tween != null and _idle_shift_tween.is_running():
		_idle_shift_tween.kill()
	var target_x: float = _rng.randf_range(-3.0, 3.0)
	_idle_shift_tween = create_tween()
	_idle_shift_tween.tween_property(self, "_idle_shift_offset_x", target_x, 0.5)
	_idle_shift_tween.tween_property(self, "_idle_shift_offset_x", 0.0, 0.5)

func _reset_idle_timers() -> void:
	_idle_wander_timer = _rng.randf_range(3.0, 7.0)
	_idle_look_timer = _rng.randf_range(5.0, 10.0)
	_idle_shift_timer = _rng.randf_range(3.0, 6.0)

func _stop_idle_life() -> void:
	if _idle_breath_tween != null and _idle_breath_tween.is_running():
		_idle_breath_tween.kill()
	if _idle_wander_tween != null and _idle_wander_tween.is_running():
		_idle_wander_tween.kill()
	if _idle_look_tween != null and _idle_look_tween.is_running():
		_idle_look_tween.kill()
	if _idle_shift_tween != null and _idle_shift_tween.is_running():
		_idle_shift_tween.kill()

	_idle_breath_tween = null
	_idle_wander_tween = null
	_idle_look_tween = null
	_idle_shift_tween = null
	_idle_visual_offset = Vector2.ZERO
	_idle_shift_offset_x = 0.0
	_idle_look_angle = 0.0

	if _sprite != null:
		_sprite.scale = _idle_base_scale
		_sprite.position = Vector2.ZERO

func _update_crowd_reaction(delta: float) -> void:
	if not _can_run_crowd_reaction():
		return

	_crowd_reaction_timer -= delta
	if _crowd_reaction_timer > 0.0:
		return

	_reset_crowd_reaction_timer()
	if _cursor == null:
		return

	var distance_to_cursor: float = global_position.distance_to(_cursor.global_position)
	var effective_reaction_radius: float = max(crowd_reaction_radius, _cursor.outer_awareness_radius)
	if distance_to_cursor > effective_reaction_radius:
		return

	var influence_strength: int = _cursor.get_influence_strength_for_position(global_position)
	if influence_strength == CursorEntity.InfluenceStrength.NONE:
		return

	var reaction_direction: Vector2 = Vector2.ZERO
	var movement_distance: float = 0.0
	var move_duration: float = _rng.randf_range(0.45, 0.8)
	var civilian_modifier: float = _cursor.get_civilian_pressure_modifier()
	var cultist_tightening: float = _cursor.get_cultist_tightening_modifier()
	var pressure_ratio: float = _cursor.get_pressure_ratio()

	if state == STATE_WANDER and not converted:
		reaction_direction = (_cursor.global_position - global_position).normalized()
		match influence_strength:
			CursorEntity.InfluenceStrength.WEAK:
				var weak_curiosity_chance: float = 0.55 * civilian_modifier
				if _rng.randf() > weak_curiosity_chance:
					return
				movement_distance = _rng.randf_range(0.0, 5.0) * civilian_modifier
			CursorEntity.InfluenceStrength.MEDIUM:
				movement_distance = _rng.randf_range(10.0, 15.0) * civilian_modifier
			CursorEntity.InfluenceStrength.STRONG:
				movement_distance = _rng.randf_range(18.0, 22.0) * civilian_modifier
				move_duration = _rng.randf_range(0.28, 0.45)
			_:
				return
		movement_distance = max(0.0, movement_distance)
	elif state == STATE_FOLLOW and converted:
		match influence_strength:
			CursorEntity.InfluenceStrength.WEAK:
				reaction_direction = (_cursor.global_position - global_position).normalized()
				movement_distance = _rng.randf_range(5.0, 8.0) * cultist_tightening
			CursorEntity.InfluenceStrength.MEDIUM:
				reaction_direction = (_cursor.global_position - global_position).normalized()
				movement_distance = _rng.randf_range(10.0, 20.0) * cultist_tightening
			CursorEntity.InfluenceStrength.STRONG:
				_crowd_orbit_angle += _rng.randf_range(0.35, 0.85)
				var orbit_radius: float = _rng.randf_range(20.0, 30.0) * cultist_tightening
				var orbit_target: Vector2 = _cursor.global_position + Vector2.RIGHT.rotated(_crowd_orbit_angle) * orbit_radius
				var view_size_orbit: Vector2 = get_viewport().get_visible_rect().size
				orbit_target.x = clamp(orbit_target.x, 0.0, view_size_orbit.x)
				orbit_target.y = clamp(orbit_target.y, 0.0, view_size_orbit.y)
				if _crowd_reaction_tween != null and _crowd_reaction_tween.is_running():
					_crowd_reaction_tween.kill()
				_crowd_reaction_tween = create_tween()
				var orbit_duration: float = _rng.randf_range(0.32, 0.5) + (pressure_ratio * 0.08)
				_crowd_reaction_tween.tween_property(self, "global_position", orbit_target, orbit_duration)
				return
			_:
				return
	else:
		return

	if reaction_direction == Vector2.ZERO:
		return

	var target_position: Vector2 = global_position + (reaction_direction * movement_distance)
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	target_position.x = clamp(target_position.x, 0.0, view_size.x)
	target_position.y = clamp(target_position.y, 0.0, view_size.y)

	if _crowd_reaction_tween != null and _crowd_reaction_tween.is_running():
		_crowd_reaction_tween.kill()
	_crowd_reaction_tween = create_tween()
	_crowd_reaction_tween.tween_property(self, "global_position", target_position, move_duration)

func _can_run_crowd_reaction() -> bool:
	if _game_manager == null or _cursor == null:
		return false
	if _game_manager.final_sequence_active or _game_manager.final_gathering_active:
		return false
	if _game_manager.are_npcs_paused():
		return false
	if _is_worshipping or _is_kneeling:
		return false
	if Time.get_ticks_msec() < _forced_attracted_until_msec:
		return false
	return true

func _reset_crowd_reaction_timer() -> void:
	var min_cd: float = min(crowd_reaction_cooldown_min, crowd_reaction_cooldown_max)
	var max_cd: float = max(crowd_reaction_cooldown_min, crowd_reaction_cooldown_max)
	_crowd_reaction_timer = _rng.randf_range(min_cd, max_cd)

func _play_conversion_spectacle() -> void:
	if not is_inside_tree():
		return
	if _sprite != null:
		var lock_tween: Tween = create_tween()
		lock_tween.tween_property(_sprite, "modulate", Color(1.08, 0.95, 1.0, 1.0), 0.05)
		lock_tween.tween_property(_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.05)

	var vfx_layer: Node2D = _ensure_conversion_vfx_layer()
	if vfx_layer == null:
		return

	_spawn_conversion_fx(vfx_layer, CONVERSION_GLYPH_TEXTURE, Color(0.86, 0.72, 1.0, 0.8), Vector2(0.7, 0.7), Vector2(1.2, 1.2), 0.15, 0.8, 0.0, 0.0, 0.0)
	_spawn_conversion_fx(vfx_layer, CONVERSION_FLASH_TEXTURE, Color(1.0, 0.92, 0.62, 1.0), Vector2(0.8, 0.8), Vector2(1.4, 1.4), 0.1, 1.0, 0.0, 0.0, 0.0)
	_spawn_conversion_fx(vfx_layer, CONVERSION_SMOKE_TEXTURE, Color(0.78, 0.67, 0.92, 0.55), Vector2(0.85, 0.85), Vector2(1.35, 1.35), 0.2, 0.55, 0.0, -0.2, 0.75)

	if _cursor != null:
		_cursor.spawn_conversion_ripple(global_position)

func _ensure_conversion_vfx_layer() -> Node2D:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return null
	var existing: Node = parent_node.get_node_or_null("ConversionVFXLayer")
	if existing is Node2D:
		return existing as Node2D
	var layer: Node2D = Node2D.new()
	layer.name = "ConversionVFXLayer"
	layer.z_index = -1
	parent_node.call_deferred("add_child", layer)
	return layer

func _spawn_conversion_fx(
	vfx_layer: Node2D,
	texture: Texture2D,
	base_color: Color,
	start_scale: Vector2,
	end_scale: Vector2,
	duration: float,
	start_alpha: float,
	end_alpha: float,
	start_rotation: float,
	end_rotation: float
) -> void:
	if vfx_layer == null or texture == null:
		return
	var fx: Sprite2D = Sprite2D.new()
	fx.texture = texture
	fx.global_position = global_position
	fx.scale = start_scale
	fx.rotation = start_rotation
	fx.modulate = Color(base_color.r, base_color.g, base_color.b, start_alpha)
	fx.z_index = 0
	vfx_layer.add_child(fx)
	var tween: Tween = fx.create_tween()
	tween.tween_property(fx, "scale", end_scale, duration)
	tween.parallel().tween_property(fx, "rotation", end_rotation, duration)
	tween.parallel().tween_property(fx, "modulate:a", end_alpha, duration)
	tween.finished.connect(_queue_free_if_valid.bind(fx))

func _queue_free_if_valid(node: Node) -> void:
	if node != null and is_instance_valid(node):
		node.queue_free()

func _pick_new_direction() -> void:
	_direction = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)).normalized()
	if _direction == Vector2.ZERO:
		_direction = Vector2.RIGHT
	_direction_timer = _rng.randf_range(0.6, 1.8)

func _bounce_at_edges() -> void:
	var view_size: Vector2 = get_viewport().get_visible_rect().size
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



























