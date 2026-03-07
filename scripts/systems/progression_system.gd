extends Node

signal dimension_changed(level: int)

@export var game_manager_path: NodePath
@export var background_path: NodePath

var _game_manager: GameManager
var _background: Sprite2D

var _dimension_thresholds: PackedInt32Array = PackedInt32Array([100, 1000, 10000, 100000, 1000000])
var _world_notice_thresholds: PackedInt32Array = PackedInt32Array([5000, 10000, 50000])
var _shown_world_notice_thresholds: Dictionary = {}
var _last_cult_power: int = -1
var _dimension_colors: Array[Color] = [
	Color(0.18, 0.26, 0.42),
	Color(0.25, 0.40, 0.30),
	Color(0.45, 0.35, 0.22),
	Color(0.36, 0.26, 0.36),
	Color(0.50, 0.45, 0.20)
]

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_background = get_node_or_null(background_path) as Sprite2D
	if _game_manager == null:
		return

	_ensure_background_texture()
	_update_background_color(_game_manager.current_dimension)

func _process(_delta: float) -> void:
	if _game_manager == null:
		return

	_update_dimension_progression()
	_update_divinity_progression()
	_update_cult_power_effects()
	_check_world_notice_milestones()
	_update_final_phase_flags()

func _update_final_phase_flags() -> void:
	if _game_manager.followers > 500000:
		_game_manager.activate_global_devotion()

	if _game_manager.followers > 750000:
		if not _game_manager.world_transformed_active:
			_game_manager.activate_world_transformation()
			_game_manager.world_message_requested.emit("The world has become your reflection.")
		_update_world_transform_background()

	if _game_manager.followers > 950000:
		_game_manager.activate_final_gathering()

	if _game_manager.followers >= 1000000 and not _game_manager.final_sequence_active:
		_game_manager.start_final_sequence()

func _update_dimension_progression() -> void:
	if _game_manager.final_sequence_active:
		return

	var new_dimension: int = _calculate_level(_game_manager.followers, _dimension_thresholds)
	if new_dimension == _game_manager.current_dimension:
		return

	_game_manager.current_dimension = new_dimension
	_update_background_color(new_dimension)
	dimension_changed.emit(new_dimension)
	_game_manager.dimension_changed.emit(new_dimension)
	_game_manager.state_changed.emit()

func _update_divinity_progression() -> void:
	if _game_manager.final_sequence_active:
		return

	var new_divinity_level: int = _calculate_level(_game_manager.followers, _dimension_thresholds)
	if new_divinity_level == _game_manager.divinity_level:
		return

	_game_manager.divinity_level = new_divinity_level
	_apply_divinity_effects(new_divinity_level)
	_game_manager.divinity_level_changed.emit(new_divinity_level)

	var cursor: CursorEntity = get_tree().get_first_node_in_group("cursor") as CursorEntity
	if cursor != null:
		_game_manager.divine_pulse_requested.emit(cursor.global_position)

	if new_divinity_level == 3:
		_game_manager.set_npc_pause(1.0)
		get_tree().call_group("followers", "trigger_worship_now")

	_game_manager.state_changed.emit()

func _apply_divinity_effects(level: int) -> void:
	var radius_by_level: Array = [60.0, 90.0, 130.0, 170.0, 220.0, 280.0]
	var follower_limit_by_level: PackedInt32Array = PackedInt32Array([30, 36, 44, 54, 66, 80])
	var cluster_min_by_level: PackedInt32Array = PackedInt32Array([3, 3, 4, 4, 5, 6])
	var cluster_max_by_level: PackedInt32Array = PackedInt32Array([6, 7, 8, 9, 10, 12])
	var index: int = clamp(level, 0, 5)

	_game_manager.attraction_radius = max(_game_manager.attraction_radius, float(radius_by_level[index]))
	_game_manager.max_followers_near_cursor = max(_game_manager.max_followers_near_cursor, follower_limit_by_level[index])
	_game_manager.spawn_cluster_min = max(_game_manager.spawn_cluster_min, cluster_min_by_level[index])
	_game_manager.spawn_cluster_max = max(_game_manager.spawn_cluster_max, cluster_max_by_level[index])

func _update_cult_power_effects() -> void:
	var prophet_count: int = get_tree().get_nodes_in_group("prophet").size()
	_game_manager.cult_power = _game_manager.followers + (prophet_count * 50)

	var radius_bonus: float = float(_game_manager.cult_power / 5000) * 5.0
	var cluster_bonus: int = int(_game_manager.cult_power / 15000)
	_game_manager.attraction_radius_bonus = min(80.0, radius_bonus)
	_game_manager.spawn_cluster_bonus = min(4, cluster_bonus)

	if _game_manager.cult_power != _last_cult_power:
		_last_cult_power = _game_manager.cult_power
		_game_manager.state_changed.emit()

func _check_world_notice_milestones() -> void:
	if _game_manager.final_sequence_active:
		return

	for threshold: int in _world_notice_thresholds:
		if _game_manager.followers < threshold:
			continue
		if _shown_world_notice_thresholds.has(threshold):
			continue

		_shown_world_notice_thresholds[threshold] = true
		_game_manager.world_message_requested.emit("The world begins to notice.")
		_game_manager.set_npc_pause(1.0)
		break

func _calculate_level(value: int, thresholds: PackedInt32Array) -> int:
	var level: int = 0
	for i: int in range(thresholds.size()):
		if value >= thresholds[i]:
			level = i + 1
	return level

func _ensure_background_texture() -> void:
	if _background == null:
		return
	if _background.texture != null:
		return

	var image: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_background.texture = texture
	_background.centered = false
	_background.scale = get_viewport_rect().size

func _update_background_color(level: int) -> void:
	if _background == null:
		return
	var index: int = clamp(level, 0, _dimension_colors.size() - 1)
	_background.modulate = _dimension_colors[index]

func _update_world_transform_background() -> void:
	if _background == null:
		return
	_background.modulate = Color(0.85, 0.72, 0.38)