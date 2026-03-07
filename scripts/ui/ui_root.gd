extends CanvasLayer

@export var game_manager_path: NodePath
@export var followers_label_path: NodePath
@export var faith_label_path: NodePath
@export var followers_per_second_label_path: NodePath
@export var cult_power_label_path: NodePath
@export var run_timer_label_path: NodePath
@export var upgrade_panel_path: NodePath

var _game_manager: GameManager
var _followers_label: Label
var _faith_label: Label
var _followers_per_second_label: Label
var _cult_power_label: Label
var _run_timer_label: Label
var _upgrade_panel: Control

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
	"panel_upgrade": preload("res://assets/ui/panels/panel_upgrade.png"),
	"panel_popup": preload("res://assets/ui/panels/panel_popup.png"),
	"label_bg": preload("res://assets/ui/labels/label_bg.png"),
	"icon_follower": preload("res://assets/ui/icons/icon_follower.png"),
	"icon_faith": preload("res://assets/ui/icons/icon_faith.png"),
	"icon_cult_power": preload("res://assets/ui/icons/icon_cult_power.png")
}

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_followers_label = get_node_or_null(followers_label_path) as Label
	_faith_label = get_node_or_null(faith_label_path) as Label
	_followers_per_second_label = get_node_or_null(followers_per_second_label_path) as Label
	_cult_power_label = get_node_or_null(cult_power_label_path) as Label
	_run_timer_label = get_node_or_null(run_timer_label_path) as Label
	_upgrade_panel = get_node_or_null(upgrade_panel_path) as Control

	_setup_ui_visuals()

	if _game_manager != null:
		_game_manager.state_changed.connect(_on_state_changed)
		_game_manager.divinity_level_changed.connect(_on_divinity_level_changed)
		_game_manager.divine_pulse_requested.connect(_on_divine_pulse_requested)
		_game_manager.world_message_requested.connect(_on_world_message_requested)
		_game_manager.final_sequence_started.connect(_on_final_sequence_started)

	_on_state_changed()

func _setup_ui_visuals() -> void:
	var top_bar: HBoxContainer = _get_top_bar()
	if top_bar != null:
		_ensure_panel_background("TopBarBackground", top_bar, UI_TEXTURES["panel_main"] as Texture2D)
		_wrap_stat_label(top_bar, _followers_label, UI_TEXTURES["icon_follower"] as Texture2D, "Followers")
		_wrap_stat_label(top_bar, _faith_label, UI_TEXTURES["icon_faith"] as Texture2D, "Faith")
		_wrap_stat_label(top_bar, _followers_per_second_label, UI_TEXTURES["icon_follower"] as Texture2D, "FollowersPerSecond")
		_wrap_stat_label(top_bar, _cult_power_label, UI_TEXTURES["icon_cult_power"] as Texture2D, "CultPower")
		_wrap_stat_label(top_bar, _run_timer_label, UI_TEXTURES["icon_faith"] as Texture2D, "RunTimer")


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
		var followers_per_second: float = float(_game_manager.followers) * _game_manager.faith_per_follower
		_followers_per_second_label.text = "Followers/sec: %.2f" % followers_per_second
	if _cult_power_label != null:
		_cult_power_label.text = "Cult Power: %s" % _format_int(_game_manager.cult_power)
	if _run_timer_label != null:
		_run_timer_label.text = "Run: %s" % _format_run_time(_game_manager.run_time_remaining)

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

func _wrap_stat_label(top_bar: HBoxContainer, label: Label, icon_texture: Texture2D, row_name: String) -> void:
	if top_bar == null or label == null or icon_texture == null:
		return
	if label.get_parent() != top_bar:
		return

	var row: PanelContainer = PanelContainer.new()
	row.name = "StatRow_%s" % row_name
	row.custom_minimum_size = Vector2(210.0, 36.0)

	var row_style: StyleBoxTexture = StyleBoxTexture.new()
	row_style.texture = UI_TEXTURES["label_bg"] as Texture2D
	row_style.set_texture_margin_all(8.0)
	row.add_theme_stylebox_override("panel", row_style)

	var content: HBoxContainer = HBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(content)

	var icon: TextureRect = TextureRect.new()
	icon.texture = icon_texture
	icon.custom_minimum_size = Vector2(22.0, 22.0)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	content.add_child(icon)

	var original_index: int = label.get_index()
	top_bar.remove_child(label)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(label)

	top_bar.add_child(row)
	top_bar.move_child(row, original_index)

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
