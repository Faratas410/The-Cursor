extends Node

@warning_ignore("unused_signal")
signal dimension_changed(level: int)

static var BACKGROUND_TEXTURES: Array[Texture2D] = [
	preload("res://assets/backgrounds/bg_village.png"),
	preload("res://assets/backgrounds/bg_town.png"),
	preload("res://assets/backgrounds/bg_city.png"),
	preload("res://assets/backgrounds/bg_metropolis.png"),
	preload("res://assets/backgrounds/bg_planet.png"),
	preload("res://assets/backgrounds/bg_cult_world.png")
]

const AMBIENT_OVERLAY_SCENES: Dictionary = {
	"cult_candle_flicker": preload("res://scenes/ambient_overlays/cult_candle_flicker_01.tscn"),
	"cult_embers_animated": preload("res://scenes/ambient_overlays/cult_embers_animated_01.tscn"),
	"village_smoke_soft_animated": preload("res://scenes/ambient_overlays/village_smoke_soft_animated_01.tscn"),
	"town_lantern_glow_animated": preload("res://scenes/ambient_overlays/town_lantern_glow_animated_01.tscn"),
	"metropolis_rune_pulse_animated": preload("res://scenes/ambient_overlays/metropolis_rune_pulse_animated_01.tscn"),
	"planet_spores_animated": preload("res://scenes/ambient_overlays/planet_spores_animated_01.tscn")
}

@export var game_manager_path: NodePath
@export var background_path: NodePath

var _game_manager: GameManager
var _background: Sprite2D
var _ground_noise_overlay: Sprite2D
var _edge_details_overlay: Sprite2D
var _ambient_overlay_layer: Node2D
var _ambient_overlay_a: Node2D
var _ambient_overlay_b: Node2D
var _ambient_overlay_c: Node2D
var _overlay_view_size: Vector2 = Vector2.ZERO
var _current_dimension_for_overlays: int = 0

var _dimension_thresholds: PackedInt32Array = PackedInt32Array([100, 1000, 10000, 100000, 1000000])
var _world_notice_thresholds: PackedInt32Array = PackedInt32Array([5000, 10000, 50000])
var _shown_world_notice_thresholds: Dictionary = {}
var _last_cult_power: int = -1

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_background = get_node_or_null(background_path) as Sprite2D
	if _background == null:
		_background = _ensure_background_sprite()
	if _game_manager == null:
		return

	_ensure_world_overlays()
	apply_dimension_background(_game_manager.current_dimension)
	_refresh_world_overlays()

func _ensure_background_sprite() -> Sprite2D:
	var systems_root: Node = get_parent()
	if systems_root == null:
		return null

	var main_root: Node = systems_root.get_parent()
	if main_root == null:
		return null

	var world: Node = main_root.get_node_or_null("World")
	if world == null:
		return null

	var existing: Sprite2D = world.get_node_or_null("Background") as Sprite2D
	if existing != null:
		return existing

	var created: Sprite2D = Sprite2D.new()
	created.name = "Background"
	created.centered = false
	created.z_index = -5
	world.add_child(created)
	world.move_child(created, 0)
	return created

func _process(_delta: float) -> void:
	if _game_manager == null:
		return

	_update_world_overlay_if_needed()
	_update_dimension_progression()
	_update_divinity_progression()
	_update_cult_power_effects()
	_check_world_notice_milestones()
	_update_final_phase_flags()

func apply_dimension_background(dimension: int) -> void:
	if _background == null:
		return
	if BACKGROUND_TEXTURES.is_empty():
		return

	var clamped_dimension: int = clamp(dimension, 0, BACKGROUND_TEXTURES.size() - 1)
	_background.texture = BACKGROUND_TEXTURES[clamped_dimension]
	_background.modulate = Color(1, 1, 1, 1)
	_background.centered = false
	_background.z_index = -5
	_current_dimension_for_overlays = clamped_dimension
	_fit_background_to_viewport()
	_apply_ambient_overlays()

func _fit_background_to_viewport() -> void:
	if _background == null or _background.texture == null:
		return

	var texture_size: Vector2 = _background.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var view_size: Vector2 = get_viewport().get_visible_rect().size
	_background.position = Vector2.ZERO
	_background.scale = Vector2(view_size.x / texture_size.x, view_size.y / texture_size.y)

func _ensure_world_overlays() -> void:
	if _background == null:
		return

	var world: Node = _background.get_parent()
	if world == null:
		return

	_ground_noise_overlay = world.get_node_or_null("GroundNoiseOverlay") as Sprite2D
	if _ground_noise_overlay == null:
		_ground_noise_overlay = Sprite2D.new()
		_ground_noise_overlay.name = "GroundNoiseOverlay"
		world.add_child(_ground_noise_overlay)

	_edge_details_overlay = world.get_node_or_null("EdgeDetailsOverlay") as Sprite2D
	if _edge_details_overlay == null:
		_edge_details_overlay = Sprite2D.new()
		_edge_details_overlay.name = "EdgeDetailsOverlay"
		world.add_child(_edge_details_overlay)

	_ground_noise_overlay.centered = false
	_ground_noise_overlay.position = Vector2.ZERO
	_ground_noise_overlay.z_index = -4

	_edge_details_overlay.centered = false
	_edge_details_overlay.position = Vector2.ZERO
	_edge_details_overlay.z_index = -3

	_ambient_overlay_layer = world.get_node_or_null("AmbientOverlayLayer") as Node2D
	if _ambient_overlay_layer == null:
		_ambient_overlay_layer = Node2D.new()
		_ambient_overlay_layer.name = "AmbientOverlayLayer"
		world.add_child(_ambient_overlay_layer)

	_ambient_overlay_a = _ambient_overlay_layer.get_node_or_null("AmbientOverlayA") as Node2D
	if _ambient_overlay_a == null:
		_ambient_overlay_a = Node2D.new()
		_ambient_overlay_a.name = "AmbientOverlayA"
		_ambient_overlay_layer.add_child(_ambient_overlay_a)

	_ambient_overlay_b = _ambient_overlay_layer.get_node_or_null("AmbientOverlayB") as Node2D
	if _ambient_overlay_b == null:
		_ambient_overlay_b = Node2D.new()
		_ambient_overlay_b.name = "AmbientOverlayB"
		_ambient_overlay_layer.add_child(_ambient_overlay_b)

	_ambient_overlay_c = _ambient_overlay_layer.get_node_or_null("AmbientOverlayC") as Node2D
	if _ambient_overlay_c == null:
		_ambient_overlay_c = Node2D.new()
		_ambient_overlay_c.name = "AmbientOverlayC"
		_ambient_overlay_layer.add_child(_ambient_overlay_c)

	_configure_ambient_overlay_slot(_ambient_overlay_a, -2)
	_configure_ambient_overlay_slot(_ambient_overlay_b, -2)
	_configure_ambient_overlay_slot(_ambient_overlay_c, -2)

func _update_world_overlay_if_needed() -> void:
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	if view_size == _overlay_view_size:
		return
	_refresh_world_overlays()

func _refresh_world_overlays() -> void:
	if _ground_noise_overlay == null or _edge_details_overlay == null:
		return

	var view_size: Vector2 = get_viewport().get_visible_rect().size
	if view_size.x <= 1.0 or view_size.y <= 1.0:
		return

	_overlay_view_size = view_size
	var image_size: Vector2i = Vector2i(int(view_size.x), int(view_size.y))
	_ground_noise_overlay.texture = _build_ground_noise_texture(image_size)
	_edge_details_overlay.texture = _build_edge_details_texture(image_size)
	_apply_ambient_overlays()

func _configure_ambient_overlay_slot(slot: Node2D, z_index_value: int) -> void:
	slot.z_index = z_index_value

func _clear_ambient_overlay_slot(slot: Node2D) -> void:
	for child: Node in slot.get_children():
		slot.remove_child(child)
		child.queue_free()

func _apply_ambient_overlays() -> void:
	if _ambient_overlay_a == null or _ambient_overlay_b == null or _ambient_overlay_c == null:
		return

	var view_size: Vector2 = get_viewport().get_visible_rect().size
	if view_size.x <= 1.0 or view_size.y <= 1.0:
		return

	_clear_ambient_overlay_slot(_ambient_overlay_a)
	_clear_ambient_overlay_slot(_ambient_overlay_b)
	_clear_ambient_overlay_slot(_ambient_overlay_c)

	var layouts: Array[Dictionary] = _build_ambient_layout(_current_dimension_for_overlays, view_size)
	for i: int in range(min(layouts.size(), 3)):
		var slot: Node2D = _ambient_overlay_a
		if i == 1:
			slot = _ambient_overlay_b
		elif i == 2:
			slot = _ambient_overlay_c
		_assign_ambient_overlay(slot, layouts[i])

func _assign_ambient_overlay(slot: Node2D, layout: Dictionary) -> void:
	var key: String = String(layout.get("key", ""))
	if not AMBIENT_OVERLAY_SCENES.has(key):
		return

	var scene: PackedScene = AMBIENT_OVERLAY_SCENES[key] as PackedScene
	if scene == null:
		return

	var overlay_instance: Node2D = scene.instantiate() as Node2D
	if overlay_instance == null:
		return

	overlay_instance.position = Vector2.ZERO
	overlay_instance.scale = layout.get("scale", Vector2.ONE)
	overlay_instance.modulate = Color(1, 1, 1, float(layout.get("alpha", 0.75)))
	slot.position = layout.get("pos", Vector2.ZERO)
	slot.add_child(overlay_instance)

func _build_ambient_layout(dimension: int, view_size: Vector2) -> Array[Dictionary]:
	var layouts: Array[Dictionary] = []
	var w: float = view_size.x
	var h: float = view_size.y

	match dimension:
		0:
			layouts.append({
				"key": "village_smoke_soft_animated",
				"pos": Vector2(w * 0.88, h * 0.16),
				"scale": Vector2(0.30, 0.30),
				"alpha": 0.65
			})
		1:
			layouts.append({
				"key": "town_lantern_glow_animated",
				"pos": Vector2(w * 0.90, h * 0.18),
				"scale": Vector2(0.28, 0.28),
				"alpha": 0.78
			})
		2:
			layouts.append({
				"key": "town_lantern_glow_animated",
				"pos": Vector2(w * 0.90, h * 0.16),
				"scale": Vector2(0.27, 0.27),
				"alpha": 0.70
			})
			layouts.append({
				"key": "cult_embers_animated",
				"pos": Vector2(w * 0.12, h * 0.84),
				"scale": Vector2(0.30, 0.30),
				"alpha": 0.55
			})
		3:
			layouts.append({
				"key": "metropolis_rune_pulse_animated",
				"pos": Vector2(w * 0.88, h * 0.84),
				"scale": Vector2(0.29, 0.29),
				"alpha": 0.76
			})
		4:
			layouts.append({
				"key": "planet_spores_animated",
				"pos": Vector2(w * 0.90, h * 0.82),
				"scale": Vector2(0.31, 0.31),
				"alpha": 0.70
			})
		_:
			layouts.append({
				"key": "cult_candle_flicker",
				"pos": Vector2(w * 0.10, h * 0.14),
				"scale": Vector2(0.30, 0.30),
				"alpha": 0.82
			})
			layouts.append({
				"key": "cult_embers_animated",
				"pos": Vector2(w * 0.90, h * 0.82),
				"scale": Vector2(0.30, 0.30),
				"alpha": 0.62
			})

	return layouts

func _build_ground_noise_texture(size: Vector2i) -> Texture2D:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 119911

	var center: Vector2 = Vector2(float(size.x) * 0.5, float(size.y) * 0.5)
	var max_radius: float = center.length()
	var mark_count: int = int((float(size.x) * float(size.y)) / 14500.0)

	for i: int in range(mark_count):
		var x: int = rng.randi_range(0, size.x - 1)
		var y: int = rng.randi_range(0, size.y - 1)
		var pos: Vector2 = Vector2(float(x), float(y))
		var dist_ratio: float = center.distance_to(pos) / max_radius
		var edge_bias: float = clamp((dist_ratio - 0.25) / 0.75, 0.0, 1.0)
		if rng.randf() > edge_bias:
			continue

		var radius: int = rng.randi_range(1, 2)
		var alpha: float = 0.03 + (rng.randf() * 0.04)
		_stamp_soft_dot(image, Vector2i(x, y), radius, Color(0.17, 0.15, 0.12, alpha))

	return ImageTexture.create_from_image(image)

func _build_edge_details_texture(size: Vector2i) -> Texture2D:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))

	var cx: float = float(size.x) * 0.5
	var cy: float = float(size.y) * 0.5

	for y: int in range(size.y):
		for x: int in range(size.x):
			var nx: float = abs((float(x) - cx) / cx)
			var ny: float = abs((float(y) - cy) / cy)
			var edge: float = max(nx, ny)
			if edge < 0.74:
				continue
			var alpha: float = clamp((edge - 0.74) / 0.26, 0.0, 1.0) * 0.14
			image.set_pixel(x, y, Color(0.08, 0.07, 0.06, alpha))

	var mid_x: float = float(size.x) * 0.5
	var mid_y: float = float(size.y) * 0.5
	var center_exclusion_x: float = float(size.x) * 0.22
	var center_exclusion_y: float = float(size.y) * 0.20

	for x_mark: int in range(24, size.x - 52, 128):
		if abs(float(x_mark) - mid_x) < center_exclusion_x:
			continue
		_draw_rect_alpha(image, Rect2i(x_mark, 16, 32, 3), Color(0.12, 0.10, 0.08, 0.18))
		_draw_rect_alpha(image, Rect2i(x_mark, size.y - 20, 32, 3), Color(0.12, 0.10, 0.08, 0.18))

	for y_mark: int in range(20, size.y - 56, 112):
		if abs(float(y_mark) - mid_y) < center_exclusion_y:
			continue
		_draw_rect_alpha(image, Rect2i(14, y_mark, 3, 28), Color(0.12, 0.10, 0.08, 0.16))
		_draw_rect_alpha(image, Rect2i(size.x - 18, y_mark, 3, 28), Color(0.12, 0.10, 0.08, 0.16))

	_draw_rect_alpha(image, Rect2i(12, 12, 56, 4), Color(0.15, 0.12, 0.09, 0.2))
	_draw_rect_alpha(image, Rect2i(size.x - 68, 12, 56, 4), Color(0.15, 0.12, 0.09, 0.2))
	_draw_rect_alpha(image, Rect2i(12, size.y - 16, 56, 4), Color(0.15, 0.12, 0.09, 0.2))
	_draw_rect_alpha(image, Rect2i(size.x - 68, size.y - 16, 56, 4), Color(0.15, 0.12, 0.09, 0.2))

	return ImageTexture.create_from_image(image)

func _stamp_soft_dot(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for y: int in range(center.y - radius, center.y + radius + 1):
		if y < 0 or y >= image.get_height():
			continue
		for x: int in range(center.x - radius, center.x + radius + 1):
			if x < 0 or x >= image.get_width():
				continue
			var distance: float = Vector2(float(x - center.x), float(y - center.y)).length()
			if distance > float(radius):
				continue
			var falloff: float = 1.0 - (distance / float(radius + 1))
			var src_alpha: float = color.a * falloff
			var existing: Color = image.get_pixel(x, y)
			if src_alpha <= existing.a:
				continue
			image.set_pixel(x, y, Color(color.r, color.g, color.b, src_alpha))

func _draw_rect_alpha(image: Image, rect: Rect2i, color: Color) -> void:
	var min_x: int = max(0, rect.position.x)
	var min_y: int = max(0, rect.position.y)
	var max_x: int = min(image.get_width(), rect.position.x + rect.size.x)
	var max_y: int = min(image.get_height(), rect.position.y + rect.size.y)

	for y: int in range(min_y, max_y):
		for x: int in range(min_x, max_x):
			var existing: Color = image.get_pixel(x, y)
			if color.a > existing.a:
				image.set_pixel(x, y, color)

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
	apply_dimension_background(new_dimension)
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

	var radius_bonus: float = (float(_game_manager.cult_power) / 5000.0) * 5.0
	var cluster_bonus: int = int(float(_game_manager.cult_power) / 15000.0)
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

func _update_world_transform_background() -> void:
	apply_dimension_background(5)
