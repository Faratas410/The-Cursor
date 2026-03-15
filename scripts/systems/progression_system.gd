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
const TREE_A_TEXTURE: Texture2D = preload("res://assets/environment/tree_a.png")
const TREE_B_TEXTURE: Texture2D = preload("res://assets/environment/tree_b.png")
const TREE_C_TEXTURE: Texture2D = preload("res://assets/environment/tree_c.png")
const HOUSE_SMALL_TEXTURE: Texture2D = preload("res://assets/environment/village_house_small.png")
const HOUSE_MEDIUM_TEXTURE: Texture2D = preload("res://assets/environment/village_house_medium.png")
const WOOD_FENCE_TEXTURE: Texture2D = preload("res://assets/environment/wood_fence.png")
const WOOD_FENCE_SHORT_TEXTURE: Texture2D = preload("res://assets/environment/wood_fence_short.png")
const WELL_TEXTURE: Texture2D = preload("res://assets/environment/well_01.png")
const CART_TEXTURE: Texture2D = preload("res://assets/environment/cart_01.png")
const BARREL_TEXTURE: Texture2D = preload("res://assets/environment/barrel_01.png")
const CRATE_TEXTURE: Texture2D = preload("res://assets/environment/crate_small.png")
const CULT_BANNER_TEXTURE: Texture2D = preload("res://assets/environment/cult_banner.png")

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
var _decor_props_layer: Node2D
var _tree_prop: Sprite2D
var _tree_prop_b: Sprite2D
var _tree_prop_c: Sprite2D
var _house_prop: Sprite2D
var _house_medium_prop: Sprite2D
var _fence_prop: Sprite2D
var _fence_short_prop: Sprite2D
var _well_prop: Sprite2D
var _cart_prop: Sprite2D
var _barrel_prop: Sprite2D
var _crate_prop: Sprite2D
var _banner_prop: Sprite2D
var _tree_base_position: Vector2 = Vector2.ZERO
var _ritual_pressure_overlay: Sprite2D
var _cursor: CursorEntity

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
	_ensure_decor_props()
	apply_dimension_background(_game_manager.current_dimension)
	_refresh_world_overlays()
	_update_decor_motion(0.0)

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

func _process(delta: float) -> void:
	if _game_manager == null:
		return

	_update_world_overlay_if_needed()
	_update_decor_motion(delta)
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
	_update_decor_visibility()

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
	_layout_decor_props(view_size)

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
			if edge < 0.82:
				continue
			var alpha: float = clamp((edge - 0.82) / 0.18, 0.0, 1.0) * 0.08
			image.set_pixel(x, y, Color(0.08, 0.07, 0.06, alpha))

	var mid_x: float = float(size.x) * 0.5
	var mid_y: float = float(size.y) * 0.5
	var center_exclusion_x: float = float(size.x) * 0.22
	var center_exclusion_y: float = float(size.y) * 0.20

	for x_mark: int in range(24, size.x - 52, 220):
		if abs(float(x_mark) - mid_x) < center_exclusion_x:
			continue
		_draw_rect_alpha(image, Rect2i(x_mark, 16, 22, 2), Color(0.12, 0.10, 0.08, 0.10))
		_draw_rect_alpha(image, Rect2i(x_mark, size.y - 20, 22, 2), Color(0.12, 0.10, 0.08, 0.10))

	for y_mark: int in range(20, size.y - 56, 176):
		if abs(float(y_mark) - mid_y) < center_exclusion_y:
			continue
		_draw_rect_alpha(image, Rect2i(14, y_mark, 2, 20), Color(0.12, 0.10, 0.08, 0.10))
		_draw_rect_alpha(image, Rect2i(size.x - 18, y_mark, 2, 20), Color(0.12, 0.10, 0.08, 0.10))

	_draw_rect_alpha(image, Rect2i(12, 12, 40, 2), Color(0.15, 0.12, 0.09, 0.10))
	_draw_rect_alpha(image, Rect2i(size.x - 52, 12, 40, 2), Color(0.15, 0.12, 0.09, 0.10))
	_draw_rect_alpha(image, Rect2i(12, size.y - 14, 40, 2), Color(0.15, 0.12, 0.09, 0.10))
	_draw_rect_alpha(image, Rect2i(size.x - 52, size.y - 14, 40, 2), Color(0.15, 0.12, 0.09, 0.10))

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

func _ensure_decor_props() -> void:
	if _background == null:
		return
	var world: Node = _background.get_parent()
	if world == null:
		return

	_decor_props_layer = world.get_node_or_null("DecorPropsLayer") as Node2D
	if _decor_props_layer == null:
		_decor_props_layer = Node2D.new()
		_decor_props_layer.name = "DecorPropsLayer"
		world.add_child(_decor_props_layer)

	_tree_prop = _ensure_decor_sprite("PropTreeA", TREE_A_TEXTURE, -2, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_tree_prop_b = _ensure_decor_sprite("PropTreeB", TREE_B_TEXTURE, -2, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_tree_prop_c = _ensure_decor_sprite("PropTreeC", TREE_C_TEXTURE, -2, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_house_prop = _ensure_decor_sprite("PropHouseSmall", HOUSE_SMALL_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_house_medium_prop = _ensure_decor_sprite("PropHouseMedium", HOUSE_MEDIUM_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_fence_prop = _ensure_decor_sprite("PropWoodFence", WOOD_FENCE_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.95), Vector2.ONE)
	_fence_short_prop = _ensure_decor_sprite("PropWoodFenceShort", WOOD_FENCE_SHORT_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.95), Vector2.ONE)
	_well_prop = _ensure_decor_sprite("PropWell01", WELL_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_cart_prop = _ensure_decor_sprite("PropCart01", CART_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_barrel_prop = _ensure_decor_sprite("PropBarrel01", BARREL_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_crate_prop = _ensure_decor_sprite("PropCrateSmall", CRATE_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.96), Vector2.ONE)
	_banner_prop = _ensure_decor_sprite("PropBanner", CULT_BANNER_TEXTURE, -1, Color(1.0, 1.0, 1.0, 0.95), Vector2(0.88, 0.88))
	_remove_legacy_prop("PropTree")
	_remove_legacy_prop("PropHouse")
	_remove_legacy_prop("PropTreeLeft")
	_remove_legacy_prop("PropTreeRight")
	_remove_legacy_prop("PropStall")
	_remove_legacy_prop("PropBonfireGlow")
	_remove_legacy_prop("PropBonfireEmbers")
	_remove_legacy_prop("PropCultBanner")

	if _ritual_pressure_overlay == null:
		_ritual_pressure_overlay = Sprite2D.new()
		_ritual_pressure_overlay.name = "RitualPressureOverlay"
		_ritual_pressure_overlay.texture = _build_ritual_pressure_texture(260)
		_ritual_pressure_overlay.z_index = -2
		_ritual_pressure_overlay.modulate = Color(0.12, 0.08, 0.06, 0.0)
		_decor_props_layer.add_child(_ritual_pressure_overlay)
	_update_decor_visibility()

func _remove_legacy_prop(name: String) -> void:
	if _decor_props_layer == null:
		return
	var legacy: Node = _decor_props_layer.get_node_or_null(name)
	if legacy != null:
		legacy.queue_free()

func _ensure_decor_sprite(name: String, texture: Texture2D, z_index_value: int, modulate: Color, scale_value: Vector2) -> Sprite2D:
	if _decor_props_layer == null or texture == null:
		return null
	var sprite: Sprite2D = _decor_props_layer.get_node_or_null(name) as Sprite2D
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = name
		_decor_props_layer.add_child(sprite)
	sprite.texture = texture
	sprite.z_index = z_index_value
	sprite.modulate = modulate
	sprite.scale = scale_value
	return sprite

func _layout_decor_props(view_size: Vector2) -> void:
	if _decor_props_layer == null:
		return
	if _tree_prop != null:
		_tree_base_position = Vector2(view_size.x * 0.18, view_size.y * 0.22)
		_tree_prop.position = _tree_base_position
	if _tree_prop_b != null:
		_tree_prop_b.position = Vector2(view_size.x * 0.88, view_size.y * 0.24)
	if _tree_prop_c != null:
		_tree_prop_c.position = Vector2(view_size.x * 0.12, view_size.y * 0.82)
	if _house_prop != null:
		_house_prop.position = Vector2(view_size.x * 0.82, view_size.y * 0.76)
	if _house_medium_prop != null:
		_house_medium_prop.position = Vector2(view_size.x * 0.91, view_size.y * 0.62)
	if _fence_prop != null:
		_fence_prop.position = Vector2(view_size.x * 0.28, view_size.y * 0.90)
	if _fence_short_prop != null:
		_fence_short_prop.position = Vector2(view_size.x * 0.10, view_size.y * 0.60)
	if _well_prop != null:
		_well_prop.position = Vector2(view_size.x * 0.73, view_size.y * 0.18)
	if _cart_prop != null:
		_cart_prop.position = Vector2(view_size.x * 0.12, view_size.y * 0.16)
	if _barrel_prop != null:
		_barrel_prop.position = Vector2(view_size.x * 0.92, view_size.y * 0.88)
	if _crate_prop != null:
		_crate_prop.position = Vector2(view_size.x * 0.84, view_size.y * 0.16)
	if _banner_prop != null:
		_banner_prop.position = Vector2(view_size.x * 0.72, view_size.y * 0.30)
	if _ritual_pressure_overlay != null:
		_ritual_pressure_overlay.position = view_size * 0.5

func _update_decor_visibility() -> void:
	var village_stage: bool = _current_dimension_for_overlays == 0
	if _tree_prop != null:
		_tree_prop.visible = village_stage
	if _tree_prop_b != null:
		_tree_prop_b.visible = village_stage
	if _tree_prop_c != null:
		_tree_prop_c.visible = village_stage
	if _house_prop != null:
		_house_prop.visible = village_stage
	if _house_medium_prop != null:
		_house_medium_prop.visible = village_stage
	if _fence_prop != null:
		_fence_prop.visible = village_stage
	if _fence_short_prop != null:
		_fence_short_prop.visible = village_stage
	if _well_prop != null:
		_well_prop.visible = village_stage
	if _cart_prop != null:
		_cart_prop.visible = village_stage
	if _barrel_prop != null:
		_barrel_prop.visible = village_stage
	if _crate_prop != null:
		_crate_prop.visible = village_stage
	if _banner_prop != null:
		_banner_prop.visible = not village_stage

func _update_decor_motion(_delta: float) -> void:
	if _game_manager == null:
		return
	if _cursor == null:
		_cursor = get_tree().get_first_node_in_group("cursor") as CursorEntity

	var time_sec: float = float(Time.get_ticks_msec()) * 0.001
	if _tree_prop != null:
		var sway: float = sin(time_sec * 0.9) * 2.0
		_tree_prop.position = Vector2(_tree_base_position.x + sway, _tree_base_position.y)
		_tree_prop.rotation = deg_to_rad(sway * 0.55)
	if _tree_prop_b != null:
		_tree_prop_b.rotation = deg_to_rad(sin((time_sec * 0.8) + 0.4) * -0.9)

	if _banner_prop != null:
		_banner_prop.rotation = deg_to_rad(sin((time_sec * 1.2) + 0.8) * 2.0)

	if _ritual_pressure_overlay != null:
		var pressure_ratio: float = 0.0
		if _cursor != null:
			_ritual_pressure_overlay.position = _cursor.global_position
			pressure_ratio = _cursor.get_pressure_ratio()
		_ritual_pressure_overlay.modulate.a = clamp(pressure_ratio * 0.42, 0.0, 0.42)
		var scale_value: float = 0.86 + (pressure_ratio * 0.36)
		_ritual_pressure_overlay.scale = Vector2.ONE * scale_value

func _build_ritual_pressure_texture(size: int) -> Texture2D:
	var image: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(float(size) * 0.5, float(size) * 0.5)
	var max_dist: float = float(size) * 0.5
	for y: int in range(size):
		for x: int in range(size):
			var dist: float = center.distance_to(Vector2(float(x), float(y)))
			var ratio: float = clamp(dist / max_dist, 0.0, 1.0)
			var alpha: float = pow(1.0 - ratio, 2.2)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)

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
