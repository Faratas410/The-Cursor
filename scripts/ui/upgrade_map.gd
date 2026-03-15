extends Control
class_name UpgradeMap

@warning_ignore("unused_signal")
signal upgrade_purchased(upgrade: Dictionary)

const UPGRADE_MAP_NODE_SCENE: PackedScene = preload("res://scenes/ui/upgrade_map_node.tscn")
const PANEL_TOOLTIP_TEXTURE: Texture2D = preload("res://assets/ui/panels/panel_tooltip_9slice.png")
const BUTTON_CONTINUE_IDLE_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_continue_idle.png")
const BUTTON_CONTINUE_HOVER_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_continue_hover.png")
const BUTTON_CONTINUE_PRESSED_TEXTURE: Texture2D = preload("res://assets/ui/buttons/btn_continue_pressed.png")

const COLUMN_X_BY_KEY: Dictionary = {
	"conversion": -400.0,
	"faith": -200.0,
	"world_control": 0.0,
	"cult_power": 200.0,
	"ritual": 400.0
}

const COLUMN_BY_BRANCH: Dictionary = {
	"conversion": "conversion",
	"faith_flow": "faith",
	"world_control": "world_control",
	"cult_power": "cult_power",
	"ritual": "ritual",
	"late_game": "cult_power"
}

const COLUMN_OVERRIDE_BY_ID: Dictionary = {
	"worship_wave": "ritual",
	"they_can_see_you": "ritual"
}

const ICON_KEY_BY_ID: Dictionary = {
	"awakening": "divine_favor",
	"magnetic_presence": "cult_influence",
	"faster_conversion": "conversion_speed",
	"conversion_pulse": "dark_ritual",
	"conversion_chain": "conversion_chain",
	"mass_conversion": "mass_conversion",
	"faith_amplifier": "faith_multiplier",
	"steady_worship": "faith_multiplier",
	"violent_faith": "corruption_power",
	"cult_donations": "faith_multiplier",
	"sacred_economy": "cult_growth",
	"divine_harvest": "forbidden_knowledge",
	"overflow_faith": "corruption_power",
	"curious_crowds": "cult_growth",
	"path_growth": "cult_growth",
	"path_control": "cult_influence",
	"pilgrimage": "cult_influence",
	"wandering_faith": "corruption_power",
	"sacred_ground": "dark_ritual",
	"ritual_knife": "dark_ritual",
	"blood_ledger": "forbidden_knowledge",
	"blood_tithe": "ritual_mastery",
	"grand_offering": "cult_dominion",
	"cult_leaders": "cult_dominion",
	"wide_influence": "cult_influence",
	"focused_conversion": "conversion_speed",
	"prophecy": "divine_favor",
	"skeptic_hunt": "corruption_power",
	"divine_aura": "cult_influence",
	"cult_expansion": "cult_growth",
	"worship_wave": "ritual_mastery",
	"they_can_see_you": "cult_dominion"
}

@export var game_manager_path: NodePath

@onready var _camera: UpgradeMapCamera = $Camera2D as UpgradeMapCamera
@onready var _map_viewport: Control = $MapViewport
@onready var _map_container: Node2D = $MapViewport/MapContainer
@onready var _connection_lines: Node2D = $MapViewport/MapContainer/ConnectionLines
@onready var _tooltip_panel: Panel = $MapViewport/TooltipPanel
@onready var _tooltip_title: Label = $MapViewport/TooltipPanel/VBox/Title
@onready var _tooltip_description: Label = $MapViewport/TooltipPanel/VBox/Description
@onready var _tooltip_cost: Label = $MapViewport/TooltipPanel/VBox/Cost
@onready var _tooltip_status: Label = $MapViewport/TooltipPanel/VBox/Status
@onready var _continue_button: Button = $ContinueCultButton

var _game_manager: GameManager
var _nodes_by_id: Dictionary = {}
var _positions_by_id: Dictionary = {}
var _definitions_by_id: Dictionary = {}
var _is_initialized: bool = false
var _tooltip_tween: Tween
var _continue_button_tween: Tween

func _ready() -> void:
	_map_container.position = Vector2.ZERO
	_map_container.scale = Vector2.ONE
	_game_manager = _resolve_game_manager()
	if _game_manager == null:
		visible = false
		return

	if not _game_manager.state_changed.is_connected(_on_game_state_changed):
		_game_manager.state_changed.connect(_on_game_state_changed)
	if not _game_manager.upgrade_purchased.is_connected(_on_upgrade_purchased):
		_game_manager.upgrade_purchased.connect(_on_upgrade_purchased)

	_camera.transform_changed.connect(_on_camera_transform_changed)
	_map_viewport.gui_input.connect(_on_map_viewport_gui_input)
	_map_viewport.resized.connect(_on_map_viewport_resized)
	_continue_button.pressed.connect(_on_continue_pressed)
	_continue_button.mouse_entered.connect(_on_continue_button_mouse_entered)
	_continue_button.mouse_exited.connect(_on_continue_button_mouse_exited)
	_continue_button.button_down.connect(_on_continue_button_down)
	_continue_button.button_up.connect(_on_continue_button_up)
	_tooltip_panel.visible = false
	_tooltip_panel.top_level = true
	_tooltip_panel.z_as_relative = false
	_tooltip_panel.z_index = 4095
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.modulate = Color(0.96, 0.94, 1.0, 0.0)
	_continue_button.pivot_offset = _continue_button.custom_minimum_size * 0.5
	_apply_panel_and_button_styles()

	call_deferred("_deferred_initialize")

func _apply_panel_and_button_styles() -> void:
	var tooltip_style: StyleBoxTexture = StyleBoxTexture.new()
	tooltip_style.texture = PANEL_TOOLTIP_TEXTURE
	tooltip_style.texture_margin_left = 16.0
	tooltip_style.texture_margin_top = 16.0
	tooltip_style.texture_margin_right = 16.0
	tooltip_style.texture_margin_bottom = 16.0
	tooltip_style.content_margin_left = 12.0
	tooltip_style.content_margin_top = 10.0
	tooltip_style.content_margin_right = 12.0
	tooltip_style.content_margin_bottom = 10.0
	_tooltip_panel.add_theme_stylebox_override("panel", tooltip_style)
	_tooltip_title.add_theme_color_override("font_color", Color(1.00, 0.93, 0.72, 1.0))
	_tooltip_description.add_theme_color_override("font_color", Color(0.95, 0.93, 0.98, 1.0))
	_tooltip_cost.add_theme_color_override("font_color", Color(1.00, 0.88, 0.58, 1.0))
	_tooltip_status.add_theme_color_override("font_color", Color(0.88, 0.86, 0.96, 1.0))

	var cta_normal: StyleBoxTexture = StyleBoxTexture.new()
	cta_normal.texture = BUTTON_CONTINUE_IDLE_TEXTURE
	cta_normal.set_texture_margin_all(10.0)
	var cta_hover: StyleBoxTexture = StyleBoxTexture.new()
	cta_hover.texture = BUTTON_CONTINUE_HOVER_TEXTURE
	cta_hover.set_texture_margin_all(10.0)
	var cta_disabled: StyleBoxTexture = StyleBoxTexture.new()
	cta_disabled.texture = BUTTON_CONTINUE_IDLE_TEXTURE
	cta_disabled.set_texture_margin_all(10.0)
	var cta_pressed: StyleBoxTexture = StyleBoxTexture.new()
	cta_pressed.texture = BUTTON_CONTINUE_PRESSED_TEXTURE
	cta_pressed.set_texture_margin_all(10.0)
	_continue_button.add_theme_stylebox_override("normal", cta_normal)
	_continue_button.add_theme_stylebox_override("hover", cta_hover)
	_continue_button.add_theme_stylebox_override("pressed", cta_pressed)
	_continue_button.add_theme_stylebox_override("disabled", cta_disabled)
	_continue_button.add_theme_color_override("font_color", Color(1.00, 0.95, 0.80, 1.0))
	_continue_button.add_theme_color_override("font_focus_color", Color(1.00, 0.98, 0.88, 1.0))
	_continue_button.add_theme_color_override("font_hover_color", Color(1.00, 0.98, 0.88, 1.0))
	_continue_button.add_theme_color_override("font_pressed_color", Color(1.00, 0.90, 0.72, 1.0))
	_continue_button.add_theme_font_size_override("font_size", 26)

func _deferred_initialize() -> void:
	await get_tree().process_frame
	_rebuild_nodes()
	_refresh_states()
	_is_initialized = true
	_on_camera_transform_changed(_camera.get_pan_position(), _camera.get_zoom_factor())

func set_game_manager_path(path: NodePath) -> void:
	game_manager_path = path

func _process(_delta: float) -> void:
	if _tooltip_panel.visible:
		var target: Vector2 = get_viewport().get_mouse_position() + Vector2(20.0, 18.0)
		_tooltip_panel.position = _clamp_tooltip_to_view(target)

func _resolve_game_manager() -> GameManager:
	if not game_manager_path.is_empty():
		return get_node_or_null(game_manager_path) as GameManager
	return get_tree().get_first_node_in_group("game_manager") as GameManager

func _on_map_viewport_resized() -> void:
	if not _is_initialized:
		return
	_rebuild_nodes()
	_refresh_states()
	_on_camera_transform_changed(_camera.get_pan_position(), _camera.get_zoom_factor())

func _rebuild_nodes() -> void:
	for child: Node in _map_container.get_children():
		if child.name != "ConnectionLines":
			child.queue_free()

	_nodes_by_id.clear()
	_positions_by_id.clear()
	_definitions_by_id.clear()

	var definitions: Array[Dictionary] = _game_manager.get_upgrade_definitions()
	for definition: Dictionary in definitions:
		var id: String = String(definition.get("id", ""))
		if id.is_empty():
			continue
		_definitions_by_id[id] = definition.duplicate(true)
		var node_position: Vector2 = _compute_node_position(definition)
		_positions_by_id[id] = node_position

		var node_instance: UpgradeMapNode = UPGRADE_MAP_NODE_SCENE.instantiate() as UpgradeMapNode
		if node_instance == null:
			continue
		node_instance.position = node_position
		node_instance.z_index = 10
		_map_container.add_child(node_instance)
		node_instance.set_upgrade_data(definition, _resolve_icon_texture(id))
		node_instance.purchase_requested.connect(_on_purchase_requested)
		node_instance.tooltip_requested.connect(_on_tooltip_requested)
		node_instance.tooltip_hidden.connect(_hide_tooltip)
		_nodes_by_id[id] = node_instance

	_redraw_connections()

func _compute_node_position(definition: Dictionary) -> Vector2:
	var id: String = String(definition.get("id", ""))
	if id == "awakening":
		return Vector2(0.0, -190.0)

	var column_key: String = _resolve_column_key(definition)
	var x: float = float(COLUMN_X_BY_KEY.get(column_key, 0.0))
	var tier: int = int(definition.get("tier", 1))
	var y: float = float((max(1, tier) - 1) * 160)
	if id == "they_can_see_you":
		y += 40.0
	return Vector2(x, y)

func _resolve_column_key(definition: Dictionary) -> String:
	var id: String = String(definition.get("id", ""))
	if COLUMN_OVERRIDE_BY_ID.has(id):
		return String(COLUMN_OVERRIDE_BY_ID[id])
	var branch: String = String(definition.get("branch", ""))
	if COLUMN_BY_BRANCH.has(branch):
		return String(COLUMN_BY_BRANCH[branch])
	return "world_control"

func _resolve_icon_texture(id: String) -> Texture2D:
	var icon_key: String = String(ICON_KEY_BY_ID.get(id, "divine_favor"))
	var texture: Texture2D = IconRegistry.get_upgrade_icon(icon_key)
	if texture != null:
		return texture
	return IconRegistry.get_upgrade_icon("divine_favor")

func _refresh_states() -> void:
	for id_variant: Variant in _nodes_by_id.keys():
		var id: String = String(id_variant)
		var node: UpgradeMapNode = _nodes_by_id[id] as UpgradeMapNode
		if node == null:
			continue
		node.set_state(_game_manager.get_upgrade_display_state(id))
	_redraw_connections()

func _redraw_connections() -> void:
	for child: Node in _connection_lines.get_children():
		child.queue_free()

	for id_variant: Variant in _definitions_by_id.keys():
		var id: String = String(id_variant)
		var destination_position: Vector2 = _positions_by_id.get(id, Vector2.ZERO) as Vector2
		var definition: Dictionary = _definitions_by_id[id] as Dictionary
		var dependencies: PackedStringArray = definition.get("dependencies", PackedStringArray()) as PackedStringArray
		for dependency_id: String in dependencies:
			if not _positions_by_id.has(dependency_id):
				continue
			var source_position: Vector2 = _positions_by_id[dependency_id] as Vector2
			var style: Dictionary = _resolve_connection_style(id, dependency_id)
			var line: Line2D = Line2D.new()
			line.z_index = -5
			line.width = float(style.get("width", 2.4))
			line.default_color = style.get("color", Color(0.62, 0.51, 0.74, 0.34)) as Color
			line.add_point(source_position)
			line.add_point(destination_position)
			_connection_lines.add_child(line)

func _resolve_connection_style(id: String, dependency_id: String) -> Dictionary:
	var destination_state: String = _game_manager.get_upgrade_display_state(id)
	var dependency_state: String = _game_manager.get_upgrade_display_state(dependency_id)
	var dependencies_met: bool = _game_manager.are_dependencies_met(id)

	if dependency_state == "purchased" and destination_state == "purchased":
		return {"color": Color(0.98, 0.90, 0.55, 0.92), "width": 3.2}
	if dependency_state == "purchased" and dependencies_met and destination_state == "available":
		return {"color": Color(0.94, 0.80, 0.34, 0.82), "width": 2.8}
	if dependency_state == "purchased" and dependencies_met and destination_state == "unaffordable":
		return {"color": Color(0.82, 0.70, 0.42, 0.62), "width": 2.5}
	if destination_state == "choice_locked":
		return {"color": Color(0.70, 0.48, 0.48, 0.46), "width": 2.3}
	return {"color": Color(0.62, 0.51, 0.74, 0.30), "width": 2.2}

func _on_purchase_requested(upgrade_id: String) -> void:
	var state: String = _game_manager.get_upgrade_display_state(upgrade_id)
	if state == "locked" or state == "choice_locked":
		return
	_focus_on_node(upgrade_id, 0.16)
	if _game_manager.purchase_upgrade(upgrade_id):
		_refresh_states()

func _on_upgrade_purchased(upgrade: Dictionary) -> void:
	upgrade_purchased.emit(upgrade)
	var purchased_id: String = String(upgrade.get("id", ""))
	if not purchased_id.is_empty():
		_focus_on_node(purchased_id, 0.18)
		var node: UpgradeMapNode = _nodes_by_id.get(purchased_id, null) as UpgradeMapNode
		if node != null:
			node.play_purchase_pulse()
	_refresh_states()

func _focus_on_node(upgrade_id: String, duration: float) -> void:
	if _camera.is_dragging():
		return
	if not _positions_by_id.has(upgrade_id):
		return
	var node_position: Vector2 = _positions_by_id[upgrade_id] as Vector2
	_camera.focus_toward_node(node_position, duration)

func _on_game_state_changed() -> void:
	_refresh_states()

func _on_continue_pressed() -> void:
	_game_manager.continue_from_upgrade()

func _on_map_viewport_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event as InputEventMouseButton
		if button_event.button_index == MOUSE_BUTTON_WHEEL_UP or button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera.handle_wheel(button_event.button_index)
			get_viewport().set_input_as_handled()
			return
		if button_event.button_index == MOUSE_BUTTON_LEFT:
			if button_event.pressed:
				if _can_start_drag():
					_camera.begin_drag(button_event.position)
			else:
				_camera.end_drag()
	if event is InputEventMouseMotion:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		if _camera.is_dragging():
			_camera.update_drag(motion_event.position)
			get_viewport().set_input_as_handled()

func _can_start_drag() -> bool:
	var hovered: Control = get_viewport().gui_get_hovered_control()
	if hovered == null:
		return true
	if hovered is TextureButton:
		return false
	if hovered == _tooltip_panel:
		return false
	return hovered == _map_viewport

func _on_camera_transform_changed(pan_position: Vector2, zoom_factor: float) -> void:
	# Super overlay map above gameplay: move/scale map content within the UI viewport only.
	_map_container.position = (_map_viewport.size * 0.5) + pan_position
	_map_container.scale = Vector2.ONE * zoom_factor

func _on_tooltip_requested(upgrade_id: String, _screen_position: Vector2) -> void:
	if not _definitions_by_id.has(upgrade_id):
		return
	var data: Dictionary = _definitions_by_id[upgrade_id] as Dictionary
	var state: String = _game_manager.get_upgrade_display_state(upgrade_id)
	_tooltip_title.text = String(data.get("name", upgrade_id))
	_tooltip_description.text = String(data.get("description", ""))
	_tooltip_cost.text = "Cost: %.0f Faith" % float(data.get("cost", 0.0))
	_tooltip_status.text = _build_status_text(upgrade_id, state)
	_tooltip_panel.visible = true
	_tooltip_panel.move_to_front()
	_play_tooltip_fade(true)

func _hide_tooltip() -> void:
	_play_tooltip_fade(false)
	_tooltip_panel.top_level = true
	_tooltip_panel.z_as_relative = false
	_tooltip_panel.z_index = 4095
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _play_tooltip_fade(show: bool) -> void:
	if _tooltip_tween != null and _tooltip_tween.is_running():
		_tooltip_tween.kill()
	_tooltip_tween = create_tween()
	_tooltip_tween.set_trans(Tween.TRANS_SINE)
	_tooltip_tween.set_ease(Tween.EASE_OUT)
	if show:
		_tooltip_tween.tween_property(_tooltip_panel, "modulate", Color(1.0, 0.98, 1.0, 1.0), 0.12)
		return
	_tooltip_tween.tween_property(_tooltip_panel, "modulate", Color(0.96, 0.94, 1.0, 0.0), 0.08)
	_tooltip_tween.finished.connect(_hide_tooltip_panel_if_faded)

func _hide_tooltip_panel_if_faded() -> void:
	if _tooltip_panel.modulate.a <= 0.01:
		_tooltip_panel.visible = false

func _on_continue_button_mouse_entered() -> void:
	_tween_continue_button_scale(Vector2(1.04, 1.04), 0.10)

func _on_continue_button_mouse_exited() -> void:
	_tween_continue_button_scale(Vector2.ONE, 0.10)

func _on_continue_button_down() -> void:
	_tween_continue_button_scale(Vector2(0.98, 0.98), 0.06)

func _on_continue_button_up() -> void:
	_tween_continue_button_scale(Vector2(1.04, 1.04), 0.08)

func _tween_continue_button_scale(target: Vector2, duration: float) -> void:
	if _continue_button_tween != null and _continue_button_tween.is_running():
		_continue_button_tween.kill()
	_continue_button_tween = create_tween()
	_continue_button_tween.set_trans(Tween.TRANS_SINE)
	_continue_button_tween.set_ease(Tween.EASE_OUT)
	_continue_button_tween.tween_property(_continue_button, "scale", target, duration)

func _build_status_text(upgrade_id: String, state: String) -> String:
	if state == "choice_locked":
		var lock_reason: String = _game_manager.get_choice_lock_reason(upgrade_id)
		if not lock_reason.is_empty():
			return "Status: Choice Locked (%s)" % lock_reason
	if state == "locked" and not _game_manager.are_dependencies_met(upgrade_id):
		return "Status: Locked (Missing prerequisites)"
	return "Status: %s" % _state_copy(state)

func _state_copy(state: String) -> String:
	match state:
		"available":
			return "Available"
		"unaffordable":
			return "Not enough Faith"
		"purchased":
			return "Purchased"
		"choice_locked":
			return "Choice Locked"
		_:
			return "Locked"

func _clamp_tooltip_to_view(position_to_clamp: Vector2) -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = _tooltip_panel.size
	var clamped_x: float = clampf(position_to_clamp.x, 8.0, viewport_size.x - panel_size.x - 8.0)
	var clamped_y: float = clampf(position_to_clamp.y, 8.0, viewport_size.y - panel_size.y - 8.0)
	return Vector2(clamped_x, clamped_y)





