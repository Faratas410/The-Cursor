extends CanvasLayer

@export var game_manager_path: NodePath
@export var followers_label_path: NodePath
@export var faith_label_path: NodePath
@export var followers_per_second_label_path: NodePath
@export var cult_power_label_path: NodePath
@export var run_timer_label_path: NodePath
@export var upgrade_panel_path: NodePath
@export var enable_runtime_debug_overlay: bool = true

var _game_manager: GameManager
var _followers_label: Label
var _faith_label: Label
var _followers_per_second_label: Label
var _cult_power_label: Label
var _run_timer_label: Label
var _upgrade_panel: Control
var _cursor: CursorEntity
var _debug_panel: PanelContainer
var _debug_momentum_label: Label
var _debug_pressure_label: Label
var _debug_influence_label: Label

var _cult_moment_shown: bool = false
var _final_sequence_running: bool = false

var _upgrade_overlay: ColorRect
var _upgrade_summary_panel: Panel
var _run_followers_label: Label
var _run_faith_label: Label
var _run_cult_power_label: Label
var _continue_button: Button

const DIVINE_PULSE_SCENE: PackedScene = preload("res://scenes/effects/divine_pulse.tscn")
const END_SCREEN_SCENE: PackedScene = preload("res://scenes/ui/end_screen.tscn")

static var UI_TEXTURES: Dictionary = {
	"panel_main": preload("res://assets/ui/panels/panel_main.png"),
	"panel_upgrade": preload("res://assets/ui/panels/panel_main.png"),
	"panel_popup": preload("res://assets/ui/panels/panel_popup.png"),
	"panel_tooltip_9slice": preload("res://assets/ui/panels/panel_tooltip_9slice.png"),
	"label_bg": preload("res://assets/ui/labels/label_bg.png"),
	"followers_icon": preload("res://assets/ui/icons/followers_icon.png"),
	"faith_icon": preload("res://assets/ui/icons/faith_icon.png"),
	"cult_power_icon": preload("res://assets/ui/icons/cult_power_icon.png"),
	"conversion_icon": preload("res://assets/ui/icons/conversion_icon.png"),
	"upgrade_icon": preload("res://assets/ui/icons/upgrade_icon.png"),
	"momentum_icon": preload("res://assets/ui/icons/momentum_icon.png"),
	"pressure_icon": preload("res://assets/ui/icons/pressure_icon.png"),
	"influence_icon": preload("res://assets/ui/icons/influence_icon.png")
}

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_followers_label = get_node_or_null(followers_label_path) as Label
	_faith_label = get_node_or_null(faith_label_path) as Label
	_followers_per_second_label = get_node_or_null(followers_per_second_label_path) as Label
	_cult_power_label = get_node_or_null(cult_power_label_path) as Label
	_run_timer_label = get_node_or_null(run_timer_label_path) as Label
	_upgrade_panel = get_node_or_null(upgrade_panel_path) as Control
	_cursor = get_tree().get_first_node_in_group("cursor") as CursorEntity

	_setup_ui_visuals()
	_setup_debug_overlay()

	if _game_manager != null:
		_game_manager.state_changed.connect(_on_state_changed)
		_game_manager.divinity_level_changed.connect(_on_divinity_level_changed)
		_game_manager.divine_pulse_requested.connect(_on_divine_pulse_requested)
		_game_manager.world_message_requested.connect(_on_world_message_requested)
		_game_manager.final_sequence_started.connect(_on_final_sequence_started)

	_on_state_changed()

func _process(_delta: float) -> void:
	_refresh_debug_overlay()

func _setup_ui_visuals() -> void:
	var top_bar: HBoxContainer = _get_top_bar()
	if top_bar != null:
		top_bar.anchor_left = 0.0
		top_bar.anchor_right = 1.0
		top_bar.offset_left = 16.0
		top_bar.offset_right = -16.0
		top_bar.clip_contents = true
		top_bar.add_theme_constant_override("separation", 4)
		# Remove stretched top-bar background texture to avoid bright lower fringe.
		_remove_panel_background("TopBarBackground")
		_wrap_stat_label(top_bar, _followers_label, UI_TEXTURES["followers_icon"] as Texture2D, "Followers")
		_wrap_stat_label(top_bar, _faith_label, UI_TEXTURES["faith_icon"] as Texture2D, "Faith")
		_wrap_stat_label(top_bar, _followers_per_second_label, UI_TEXTURES["conversion_icon"] as Texture2D, "FollowersPerSecond")
		_wrap_stat_label(top_bar, _cult_power_label, UI_TEXTURES["cult_power_icon"] as Texture2D, "CultPower")
		_wrap_stat_label(top_bar, _run_timer_label, UI_TEXTURES["upgrade_icon"] as Texture2D, "RunTimer")
func _setup_upgrade_overlay() -> void:
	_upgrade_overlay = ColorRect.new()
	_upgrade_overlay.name = "UpgradeOverlay"
	_upgrade_overlay.anchor_right = 1.0
	_upgrade_overlay.anchor_bottom = 1.0
	_upgrade_overlay.color = Color(0.05, 0.05, 0.06, 0.72)
	_upgrade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_upgrade_overlay.visible = false
	add_child(_upgrade_overlay)

	_upgrade_summary_panel = Panel.new()
	_upgrade_summary_panel.name = "UpgradeSummaryPanel"
	_upgrade_summary_panel.anchor_left = 0.5
	_upgrade_summary_panel.anchor_top = 0.5
	_upgrade_summary_panel.anchor_right = 0.5
	_upgrade_summary_panel.anchor_bottom = 0.5
	_upgrade_summary_panel.offset_left = 200.0
	_upgrade_summary_panel.offset_top = -150.0
	_upgrade_summary_panel.offset_right = 560.0
	_upgrade_summary_panel.offset_bottom = 160.0

	var panel_style: StyleBoxTexture = StyleBoxTexture.new()
	panel_style.texture = UI_TEXTURES["panel_popup"] as Texture2D
	panel_style.set_texture_margin_all(10.0)
	_upgrade_summary_panel.add_theme_stylebox_override("panel", panel_style)
	_upgrade_overlay.add_child(_upgrade_summary_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.anchor_right = 1.0
	box.anchor_bottom = 1.0
	box.offset_left = 18.0
	box.offset_top = 16.0
	box.offset_right = -18.0
	box.offset_bottom = -16.0
	box.add_theme_constant_override("separation", 10)
	_upgrade_summary_panel.add_child(box)

	var title: Label = Label.new()
	title.text = "Upgrade Phase"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	_run_followers_label = Label.new()
	_run_followers_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(_run_followers_label)

	_run_faith_label = Label.new()
	_run_faith_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(_run_faith_label)

	_run_cult_power_label = Label.new()
	_run_cult_power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(_run_cult_power_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 8.0)
	box.add_child(spacer)

	_continue_button = Button.new()
	_continue_button.text = "Continue"
	_continue_button.custom_minimum_size = Vector2(0.0, 38.0)
	_continue_button.pressed.connect(_on_continue_pressed)
	box.add_child(_continue_button)

func _on_state_changed() -> void:
	_refresh_labels()
	_refresh_phase_ui()

func _refresh_labels() -> void:
	if _game_manager == null:
		return
	if _followers_label != null:
		_followers_label.text = "Followers: %s / 1,000,000" % _format_int(_game_manager.followers)
	if _faith_label != null:
		_faith_label.text = "Faith: %.1f" % _game_manager.faith
	if _followers_per_second_label != null:
		var follower_count: float = float(_game_manager.followers)
		var faith_base_per_second: float = (follower_count * _game_manager.faith_per_follower) / (1.0 + (follower_count / 200.0))
		var faith_per_second: float = (faith_base_per_second * _game_manager.get_faith_gain_multiplier()) + _game_manager.get_passive_faith_per_second()
		_followers_per_second_label.text = "Faith/sec: %.2f" % faith_per_second
	if _cult_power_label != null:
		_cult_power_label.text = "Cult Power: %s" % _format_int(_game_manager.cult_power)
	if _run_timer_label != null:
		_run_timer_label.text = "Run: %s" % _format_run_time(_game_manager.run_time_remaining)
	_refresh_top_bar_row_sizes()

func _refresh_phase_ui() -> void:
	if _game_manager == null:
		return

	var show_upgrade: bool = _game_manager.is_upgrade_phase() and not _game_manager.final_sequence_active
	if _upgrade_panel != null:
		_upgrade_panel.visible = show_upgrade
	if _upgrade_panel != null and show_upgrade:
		move_child(_upgrade_panel, get_child_count() - 1)

	var top_bar: HBoxContainer = _get_top_bar()
	if top_bar != null:
		top_bar.modulate = Color(1.0, 1.0, 1.0, 0.74 if show_upgrade else 1.0)

func _on_continue_pressed() -> void:
	if _game_manager == null:
		return
	_game_manager.continue_from_upgrade()

func _on_divinity_level_changed(level: int) -> void:
	if level == 3 and not _cult_moment_shown:
		_cult_moment_shown = true
		_show_center_message("THEY CAN SEE YOU")

func _on_world_message_requested(message: String) -> void:
	_show_center_message(message)

func _on_divine_pulse_requested(position: Vector2) -> void:
	if DIVINE_PULSE_SCENE == null:
		return
	var pulse: DivinePulse = DIVINE_PULSE_SCENE.instantiate() as DivinePulse
	if pulse == null:
		return
	add_child(pulse)
	pulse.show_pulse(position)

func _on_final_sequence_started() -> void:
	if _final_sequence_running:
		return
	_final_sequence_running = true
	if _upgrade_overlay != null:
		_upgrade_overlay.visible = false
	if _upgrade_panel != null:
		_upgrade_panel.visible = false
	await _run_final_sequence()

func _run_final_sequence() -> void:
	_show_center_message("THEY FOLLOWED YOU")
	await get_tree().create_timer(2.0).timeout

	_show_center_message("BECAUSE YOU MOVED")
	await get_tree().create_timer(1.9).timeout

	_show_center_message("BUT NOW YOU STOP.")
	if _game_manager != null:
		_game_manager.lock_cursor()
	get_tree().call_group("followers", "perform_kneel")
	await get_tree().create_timer(1.8).timeout

	var fade_overlay: ColorRect = _create_overlay(Color.WHITE)
	await _tween_alpha(fade_overlay, 1.0, 1.8)

	var title: Label = Label.new()
	title.text = "THE CURSOR"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.anchor_left = 0.5
	title.anchor_top = 0.5
	title.anchor_right = 0.5
	title.anchor_bottom = 0.5
	title.offset_left = -240.0
	title.offset_top = -28.0
	title.offset_right = 240.0
	title.offset_bottom = 28.0
	title.modulate = Color(0.05, 0.05, 0.05, 1.0)
	add_child(title)
	await get_tree().create_timer(1.8).timeout

	title.queue_free()
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0
	await _tween_alpha(fade_overlay, 1.0, 1.8)
	await get_tree().create_timer(0.2).timeout

	_show_end_screen()
	if _game_manager != null:
		_game_manager.finish_final_sequence()

func _show_end_screen() -> void:
	if END_SCREEN_SCENE == null:
		return

	var end_screen: EndScreen = END_SCREEN_SCENE.instantiate() as EndScreen
	if end_screen == null:
		return

	add_child(end_screen)
	if _game_manager != null:
		end_screen.set_results(_game_manager.followers, _game_manager.get_playtime_seconds())

func _create_overlay(color: Color) -> ColorRect:
	var overlay: ColorRect = ColorRect.new()
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.offset_left = 0.0
	overlay.offset_top = 0.0
	overlay.offset_right = 0.0
	overlay.offset_bottom = 0.0
	overlay.color = Color(color.r, color.g, color.b, 1.0)
	overlay.modulate.a = 0.0
	add_child(overlay)
	return overlay

func _tween_alpha(node: CanvasItem, target_alpha: float, duration: float):
	var tween: Tween = create_tween()
	tween.tween_property(node, "modulate:a", target_alpha, duration)
	await tween.finished

func _show_center_message(text: String) -> void:
	var popup: Panel = Panel.new()
	popup.anchor_left = 0.5
	popup.anchor_top = 0.5
	popup.anchor_right = 0.5
	popup.anchor_bottom = 0.5
	popup.offset_left = -280.0
	popup.offset_top = -32.0
	popup.offset_right = 280.0
	popup.offset_bottom = 32.0
	popup.modulate = Color(1.0, 1.0, 1.0, 0.0)

	var panel_style: StyleBoxTexture = StyleBoxTexture.new()
	panel_style.texture = UI_TEXTURES["panel_popup"] as Texture2D
	panel_style.set_texture_margin_all(10.0)
	popup.add_theme_stylebox_override("panel", panel_style)

	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = 18.0
	label.offset_top = 10.0
	label.offset_right = -18.0
	label.offset_bottom = -10.0
	label.modulate = Color(1.0, 0.95, 0.65, 1.0)
	popup.add_child(label)
	add_child(popup)

	var tween: Tween = create_tween()
	tween.tween_property(popup, "modulate:a", 1.0, 0.2)
	tween.tween_interval(0.9)
	tween.tween_property(popup, "modulate:a", 0.0, 0.4)
	tween.finished.connect(popup.queue_free)

func _get_top_bar() -> HBoxContainer:
	if _followers_label == null:
		return null
	return _followers_label.get_parent() as HBoxContainer

func _ensure_panel_background(node_name: String, target: Control, texture: Texture2D) -> void:
	if target == null or texture == null:
		return

	var background: TextureRect = get_node_or_null(node_name) as TextureRect
	if background == null:
		background = TextureRect.new()
		background.name = node_name
		add_child(background)

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture = texture
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.anchor_left = target.anchor_left
	background.anchor_top = target.anchor_top
	background.anchor_right = target.anchor_right
	background.anchor_bottom = target.anchor_bottom
	background.offset_left = target.offset_left - 8.0
	background.offset_top = target.offset_top - 8.0
	background.offset_right = target.offset_right + 8.0
	background.offset_bottom = target.offset_bottom + 8.0
	background.z_index = target.z_index - 1

	var target_index: int = target.get_index()
	if background.get_index() >= target_index:
		move_child(background, target_index)

func _remove_panel_background(node_name: String) -> void:
	var background: TextureRect = get_node_or_null(node_name) as TextureRect
	if background != null:
		background.queue_free()

func _wrap_stat_label(top_bar: HBoxContainer, label: Label, icon_texture: Texture2D, row_name: String) -> void:
	if top_bar == null or label == null or icon_texture == null:
		return
	if label.get_parent() != top_bar:
		return

	var min_width: float = 170.0
	match row_name:
		"Followers":
			min_width = 286.0
		"Faith":
			min_width = 168.0
		"FollowersPerSecond":
			min_width = 196.0
		"CultPower":
			min_width = 184.0
		"RunTimer":
			min_width = 138.0
		_:
			min_width = 168.0

	var row: PanelContainer = PanelContainer.new()
	row.name = "StatRow_%s" % row_name
	row.custom_minimum_size = Vector2(min_width, 38.0)
	row.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	row.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var row_style: StyleBoxTexture = StyleBoxTexture.new()
	row_style.texture = UI_TEXTURES["label_bg"] as Texture2D
	row_style.texture_margin_left = 8.0
	row_style.texture_margin_top = 8.0
	row_style.texture_margin_right = 8.0
	row_style.texture_margin_bottom = 8.0
	row_style.content_margin_left = 5.0
	row_style.content_margin_top = 2.0
	row_style.content_margin_right = 5.0
	row_style.content_margin_bottom = 2.0
	row.add_theme_stylebox_override("panel", row_style)

	var content: HBoxContainer = HBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.offset_left = 5.0
	content.offset_top = 3.0
	content.offset_right = -5.0
	content.offset_bottom = -3.0
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(content)

	var icon: TextureRect = TextureRect.new()
	icon.texture = icon_texture
	icon.custom_minimum_size = Vector2(16.0, 16.0)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	content.add_child(icon)

	var original_index: int = label.get_index()
	top_bar.remove_child(label)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	content.add_child(label)

	top_bar.add_child(row)
	top_bar.move_child(row, original_index)

func _refresh_top_bar_row_sizes() -> void:
	_resize_stat_row_for_label(_followers_label, 286.0)
	_resize_stat_row_for_label(_faith_label, 168.0)
	_resize_stat_row_for_label(_followers_per_second_label, 196.0)
	_resize_stat_row_for_label(_cult_power_label, 184.0)
	_resize_stat_row_for_label(_run_timer_label, 138.0)

func _resize_stat_row_for_label(label: Label, base_min_width: float) -> void:
	if label == null:
		return
	var content: HBoxContainer = label.get_parent() as HBoxContainer
	if content == null:
		return
	var row: PanelContainer = content.get_parent() as PanelContainer
	if row == null:
		return

	var font: Font = label.get_theme_font("font")
	var font_size: int = label.get_theme_font_size("font_size")
	var text_width: float = label.get_minimum_size().x
	if font != null:
		text_width = font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x

	var icon_and_padding: float = 44.0
	var required_width: float = ceil(text_width + icon_and_padding)
	row.custom_minimum_size = Vector2(max(base_min_width, required_width), row.custom_minimum_size.y)
func _setup_debug_overlay() -> void:
	if not enable_runtime_debug_overlay:
		return
	_debug_panel = PanelContainer.new()
	_debug_panel.name = "RuntimeDebugOverlay"
	_debug_panel.anchor_left = 0.0
	_debug_panel.anchor_top = 1.0
	_debug_panel.anchor_right = 0.0
	_debug_panel.anchor_bottom = 1.0
	_debug_panel.offset_left = 12.0
	_debug_panel.offset_top = -116.0
	_debug_panel.offset_right = 292.0
	_debug_panel.offset_bottom = -12.0
	_debug_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = UI_TEXTURES["panel_tooltip_9slice"] as Texture2D
	style.texture_margin_left = 16.0
	style.texture_margin_top = 16.0
	style.texture_margin_right = 16.0
	style.texture_margin_bottom = 16.0
	style.content_margin_left = 8.0
	style.content_margin_top = 6.0
	style.content_margin_right = 8.0
	style.content_margin_bottom = 6.0
	_debug_panel.add_theme_stylebox_override("panel", style)

	var rows: VBoxContainer = VBoxContainer.new()
	rows.anchor_right = 1.0
	rows.anchor_bottom = 1.0
	rows.offset_left = 10.0
	rows.offset_top = 8.0
	rows.offset_right = -10.0
	rows.offset_bottom = -8.0
	rows.add_theme_constant_override("separation", 4)
	_debug_panel.add_child(rows)

	var momentum_row: HBoxContainer = _create_debug_icon_row(UI_TEXTURES["momentum_icon"] as Texture2D, "Momentum: -")
	_debug_momentum_label = momentum_row.get_node("Value") as Label
	rows.add_child(momentum_row)

	var pressure_row: HBoxContainer = _create_debug_icon_row(UI_TEXTURES["pressure_icon"] as Texture2D, "Pressure: -")
	_debug_pressure_label = pressure_row.get_node("Value") as Label
	rows.add_child(pressure_row)

	var influence_row: HBoxContainer = _create_debug_icon_row(UI_TEXTURES["influence_icon"] as Texture2D, "Influence Radius: -")
	_debug_influence_label = influence_row.get_node("Value") as Label
	rows.add_child(influence_row)
	add_child(_debug_panel)

func _refresh_debug_overlay() -> void:
	if not enable_runtime_debug_overlay:
		if _debug_panel != null:
			_debug_panel.visible = false
		return
	if _debug_panel == null or _debug_momentum_label == null or _debug_pressure_label == null or _debug_influence_label == null:
		return
	if _game_manager != null and _game_manager.is_upgrade_phase():
		_debug_panel.visible = false
		return
	if _cursor == null:
		_cursor = get_tree().get_first_node_in_group("cursor") as CursorEntity
	if _cursor == null:
		_debug_momentum_label.text = "Momentum: -"
		_debug_pressure_label.text = "Pressure: -"
		_debug_influence_label.text = "Influence Radius: -"
		return

	_debug_panel.visible = true
	_debug_momentum_label.text = "Momentum: %.1f / %.1f" % [_cursor.cult_momentum, CursorEntity.MOMENTUM_MAX]
	_debug_pressure_label.text = "Pressure: %.1f / %.1f" % [_cursor.cult_pressure, CursorEntity.PRESSURE_MAX]
	_debug_influence_label.text = "Influence Radius: %.1f" % _cursor.influence_radius

func _create_debug_icon_row(icon_texture: Texture2D, text: String) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var icon: TextureRect = TextureRect.new()
	icon.texture = icon_texture
	icon.custom_minimum_size = Vector2(16.0, 16.0)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	row.add_child(icon)

	var label: Label = Label.new()
	label.name = "Value"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	return row
func _format_run_time(seconds: float) -> String:
	return "%.1fs" % max(0.0, seconds)

func _format_int(value: int) -> String:
	var text: String = str(value)
	var out: String = ""
	var count: int = 0
	for i: int in range(text.length() - 1, -1, -1):
		out = text.substr(i, 1) + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return out




























