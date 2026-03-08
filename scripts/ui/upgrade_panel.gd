extends Control

@warning_ignore("unused_signal")
signal upgrade_purchased(upgrade: Dictionary)

const UPGRADE_TREE_NODE_SCENE: PackedScene = preload("res://scenes/ui/upgrade_tree_node.tscn")

static var UI_TEXTURES: Dictionary = {
	"panel_main": preload("res://assets/ui/panels/panel_main.png"),
	"panel_upgrade": preload("res://assets/ui/panels/panel_upgrade.png"),
	"panel_popup": preload("res://assets/ui/panels/panel_popup.png"),
	"overlay_dark": preload("res://assets/ui/overlays/ui_dark_overlay.png"),
	"tooltip_panel": preload("res://assets/ui/tooltips/tooltip_panel.png"),
	"tooltip_label_bg": preload("res://assets/ui/tooltips/label_bg.png"),
	"continue_idle": preload("res://assets/ui/buttons/btn_continue_idle.png"),
	"continue_hover": preload("res://assets/ui/buttons/btn_continue_hover.png"),
	"continue_pressed": preload("res://assets/ui/buttons/btn_continue_pressed.png"),
	"connector_line": preload("res://assets/ui/connectors/tree_connector_line.png"),
	"connector_active": preload("res://assets/ui/connectors/tree_connector_active.png")
}

static var ICON_TEXTURES: Dictionary = {
	"conversion": preload("res://assets/ui/icons/icon_conversion.png"),
	"faith": preload("res://assets/ui/icons/icon_faith.png"),
	"spawn": preload("res://assets/ui/icons/icon_spawn.png"),
	"cult": preload("res://assets/ui/icons/icon_cult.png"),
	"aura": preload("res://assets/ui/icons/icon_aura.png"),
	"aura_ui": preload("res://assets/ui/effects/cursor_aura_ui.png"),
	"final": preload("res://assets/ui/icons/icon_final.png")
}

const UPGRADE_COPY_BY_ID: Dictionary = {
	"awakening": {
		"display_name": "Awakening",
		"short_desc": "The Cursor stirs.",
		"tooltip_title": "Awakening",
		"tooltip_desc": "The cult begins to notice your presence.\nIncreases base conversion speed slightly."
	},
	"magnetic_presence": {
		"display_name": "Magnetic Presence",
		"short_desc": "NPCs drift toward you.",
		"tooltip_title": "Magnetic Presence",
		"tooltip_desc": "Nearby NPCs slowly move toward the cursor.\nImproves close-range conversion opportunities."
	},
	"faster_conversion": {
		"display_name": "Faster Conversion",
		"short_desc": "Convert faster.",
		"tooltip_title": "Faster Conversion",
		"tooltip_desc": "Increases raw conversion speed.\nHelps secure more followers before the run ends."
	},
	"conversion_pulse": {
		"display_name": "Conversion Pulse",
		"short_desc": "Periodic auto-convert.",
		"tooltip_title": "Conversion Pulse",
		"tooltip_desc": "Every few seconds, one nearby NPC converts automatically.\nAdds passive pressure during each run."
	},
	"conversion_chain": {
		"display_name": "Conversion Chain",
		"short_desc": "Conversions can spread.",
		"tooltip_title": "Conversion Chain",
		"tooltip_desc": "Converted NPCs have a chance to trigger an extra nearby conversion.\nImproves burst growth."
	},
	"mass_conversion": {
		"display_name": "Mass Conversion",
		"short_desc": "Wider conversion radius.",
		"tooltip_title": "Mass Conversion",
		"tooltip_desc": "Expands your effective conversion area.\nLets clustered groups convert more easily."
	},
	"faith_amplifier": {
		"display_name": "Faith Amplifier",
		"short_desc": "More faith per gain.",
		"tooltip_title": "Faith Amplifier",
		"tooltip_desc": "Boosts total faith income.\nImproves purchasing power between runs."
	},
	"cult_donations": {
		"display_name": "Cult Donations",
		"short_desc": "Passive faith income.",
		"tooltip_title": "Cult Donations",
		"tooltip_desc": "Followers begin contributing faith automatically.\nAdds steady resource flow during a run."
	},
	"sacred_economy": {
		"display_name": "Sacred Economy",
		"short_desc": "Passive follower growth.",
		"tooltip_title": "Sacred Economy",
		"tooltip_desc": "Adds passive follower generation.\nImproves baseline growth even without perfect play."
	},
	"divine_harvest": {
		"display_name": "Divine Harvest",
		"short_desc": "More faith on convert.",
		"tooltip_title": "Divine Harvest",
		"tooltip_desc": "Each conversion yields extra faith.\nStrong for active, high-contact runs."
	},
	"overflow_faith": {
		"display_name": "Overflow Faith",
		"short_desc": "Excess becomes faith.",
		"tooltip_title": "Overflow Faith",
		"tooltip_desc": "Excess follower output is partially redirected into faith.\nImproves scaling once your runs get crowded."
	},
	"curious_crowds": {
		"display_name": "Curious Crowds",
		"short_desc": "More NPCs appear.",
		"tooltip_title": "Curious Crowds",
		"tooltip_desc": "Increases NPC spawn pressure.\nCreates denser, more rewarding runs."
	},
	"pilgrimage": {
		"display_name": "Pilgrimage",
		"short_desc": "NPCs spawn nearer center.",
		"tooltip_title": "Pilgrimage",
		"tooltip_desc": "Biases NPC presence toward the central play area.\nReduces wasted movement."
	},
	"wandering_faith": {
		"display_name": "Wandering Faith",
		"short_desc": "NPCs move slower.",
		"tooltip_title": "Wandering Faith",
		"tooltip_desc": "Slows general NPC movement.\nMakes them easier to catch and convert."
	},
	"sacred_ground": {
		"display_name": "Sacred Ground",
		"short_desc": "Clustered arrivals.",
		"tooltip_title": "Sacred Ground",
		"tooltip_desc": "NPCs begin arriving in more favorable groups.\nImproves burst conversion potential."
	},
	"cult_leaders": {
		"display_name": "Cult Leaders",
		"short_desc": "Converts create leaders.",
		"tooltip_title": "Cult Leaders",
		"tooltip_desc": "Some converted followers become small cult leaders.\nThey help spread your influence nearby."
	},
	"prophecy": {
		"display_name": "Prophecy",
		"short_desc": "Prophets may appear.",
		"tooltip_title": "Prophecy",
		"tooltip_desc": "Unlocks prophet presence during runs.\nAdds stronger autonomous conversion pressure."
	},
	"skeptic_hunt": {
		"display_name": "Skeptic Hunt",
		"short_desc": "Skeptics become targets.",
		"tooltip_title": "Skeptic Hunt",
		"tooltip_desc": "Skeptics become high-value conversion opportunities.\nTurning resistance into faith strengthens the cult."
	},
	"divine_aura": {
		"display_name": "Divine Aura",
		"short_desc": "Aura converts nearby.",
		"tooltip_title": "Divine Aura",
		"tooltip_desc": "Your cursor emits a conversion aura.\nNearby NPCs are pressured even without direct contact."
	},
	"cult_expansion": {
		"display_name": "Cult Expansion",
		"short_desc": "The world fills faster.",
		"tooltip_title": "Cult Expansion",
		"tooltip_desc": "Significantly increases overall NPC presence.\nThe cult begins to dominate each run."
	},
	"worship_wave": {
		"display_name": "Worship Wave",
		"short_desc": "Strong start each run.",
		"tooltip_title": "Worship Wave",
		"tooltip_desc": "Each run begins with a burst of cult momentum.\nHelps accelerate opening conversions."
	},
	"they_can_see_you": {
		"display_name": "THEY CAN SEE YOU",
		"short_desc": "The world recognizes you.",
		"tooltip_title": "THEY CAN SEE YOU",
		"tooltip_desc": "The cult reaches full awareness of the cursor.\nThis is the final threshold before the world shifts."
	}
}

const ICON_ROLE_BY_ID: Dictionary = {
	"awakening": "cult",
	"magnetic_presence": "conversion",
	"faster_conversion": "conversion",
	"conversion_pulse": "conversion",
	"conversion_chain": "conversion",
	"mass_conversion": "conversion",
	"faith_amplifier": "faith",
	"cult_donations": "faith",
	"sacred_economy": "faith",
	"divine_harvest": "faith",
	"overflow_faith": "faith",
	"curious_crowds": "spawn",
	"pilgrimage": "spawn",
	"wandering_faith": "spawn",
	"sacred_ground": "spawn",
	"cult_leaders": "cult",
	"prophecy": "cult",
	"skeptic_hunt": "cult",
	"divine_aura": "aura_ui",
	"cult_expansion": "final",
	"worship_wave": "final",
	"they_can_see_you": "final"
}

const LAYOUT_SCALE_X: float = 0.38
const LAYOUT_SCALE_Y: float = 0.15
const BASE_NODE_SIZE: Vector2 = Vector2(140.0, 72.0)
const ROOT_NODE_SIZE: Vector2 = Vector2(170.0, 84.0)
const FINAL_NODE_SIZE: Vector2 = Vector2(190.0, 92.0)

const NODE_POSITIONS: Dictionary = {
	"awakening": Vector2(600.0, 20.0),
	"magnetic_presence": Vector2(180.0, 170.0),
	"faster_conversion": Vector2(180.0, 300.0),
	"conversion_pulse": Vector2(180.0, 430.0),
	"conversion_chain": Vector2(180.0, 560.0),
	"mass_conversion": Vector2(180.0, 690.0),
	"faith_amplifier": Vector2(600.0, 170.0),
	"cult_donations": Vector2(600.0, 300.0),
	"sacred_economy": Vector2(600.0, 430.0),
	"divine_harvest": Vector2(600.0, 560.0),
	"overflow_faith": Vector2(600.0, 690.0),
	"curious_crowds": Vector2(1020.0, 170.0),
	"pilgrimage": Vector2(1020.0, 300.0),
	"wandering_faith": Vector2(1020.0, 430.0),
	"sacred_ground": Vector2(1020.0, 560.0),
	"cult_leaders": Vector2(440.0, 820.0),
	"prophecy": Vector2(600.0, 820.0),
	"skeptic_hunt": Vector2(760.0, 820.0),
	"divine_aura": Vector2(600.0, 970.0),
	"cult_expansion": Vector2(600.0, 1100.0),
	"worship_wave": Vector2(600.0, 1230.0),
	"they_can_see_you": Vector2(590.0, 1370.0)
}

static var DEPENDENCY_EDGES: Array[PackedStringArray] = [
	PackedStringArray(["awakening", "magnetic_presence"]),
	PackedStringArray(["awakening", "faster_conversion"]),
	PackedStringArray(["awakening", "faith_amplifier"]),
	PackedStringArray(["awakening", "curious_crowds"]),
	PackedStringArray(["magnetic_presence", "conversion_pulse"]),
	PackedStringArray(["faster_conversion", "conversion_chain"]),
	PackedStringArray(["conversion_chain", "mass_conversion"]),
	PackedStringArray(["faith_amplifier", "cult_donations"]),
	PackedStringArray(["cult_donations", "sacred_economy"]),
	PackedStringArray(["faith_amplifier", "divine_harvest"]),
	PackedStringArray(["divine_harvest", "overflow_faith"]),
	PackedStringArray(["curious_crowds", "pilgrimage"]),
	PackedStringArray(["curious_crowds", "wandering_faith"]),
	PackedStringArray(["pilgrimage", "sacred_ground"]),
	PackedStringArray(["mass_conversion", "cult_leaders"]),
	PackedStringArray(["sacred_economy", "cult_leaders"]),
	PackedStringArray(["cult_leaders", "prophecy"]),
	PackedStringArray(["cult_leaders", "skeptic_hunt"]),
	PackedStringArray(["prophecy", "divine_aura"]),
	PackedStringArray(["sacred_ground", "cult_expansion"]),
	PackedStringArray(["divine_aura", "cult_expansion"]),
	PackedStringArray(["cult_expansion", "worship_wave"]),
	PackedStringArray(["worship_wave", "they_can_see_you"])
]

@export var game_manager_path: NodePath

var _game_manager: GameManager
var _dark_overlay: TextureRect
var _tree_root: Control
var _connection_layer: Control
var _node_layer: Control
var _tooltip_panel: Panel
var _tooltip_label: Label
var _run_summary_panel: Panel
var _run_followers_label: Label
var _run_faith_label: Label
var _continue_button: Button
var _tooltip_default_position: Vector2 = Vector2.ZERO

var _nodes_by_id: Dictionary = {}
var _defs_by_id: Dictionary = {}

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_build_ui()
	_build_tree_nodes()
	_apply_layout()
	_refresh_tree()

	if _game_manager != null:
		_game_manager.state_changed.connect(_refresh_tree)

func _build_ui() -> void:
	for child: Node in get_children():
		child.queue_free()

	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0

	_dark_overlay = TextureRect.new()
	_dark_overlay.name = "DarkOverlay"
	_dark_overlay.anchor_right = 1.0
	_dark_overlay.anchor_bottom = 1.0
	_dark_overlay.texture = UI_TEXTURES["overlay_dark"] as Texture2D
	_dark_overlay.stretch_mode = TextureRect.STRETCH_SCALE
	_dark_overlay.modulate = Color(1.0, 1.0, 1.0, 0.46)
	_dark_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dark_overlay)

	_tree_root = Control.new()
	_tree_root.name = "TreeRoot"
	_tree_root.anchor_left = 0.0
	_tree_root.anchor_top = 0.0
	_tree_root.anchor_right = 0.0
	_tree_root.anchor_bottom = 0.0
	_tree_root.offset_left = 0.0
	_tree_root.offset_top = 0.0
	_tree_root.offset_right = 0.0
	_tree_root.offset_bottom = 0.0
	_tree_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tree_root)

	var tree_background: TextureRect = TextureRect.new()
	tree_background.name = "TreeBackground"
	tree_background.anchor_right = 1.0
	tree_background.anchor_bottom = 1.0
	tree_background.texture = UI_TEXTURES["panel_upgrade"] as Texture2D
	tree_background.stretch_mode = TextureRect.STRETCH_SCALE
	tree_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tree_root.add_child(tree_background)

	_connection_layer = Control.new()
	_connection_layer.name = "ConnectionLayer"
	_connection_layer.anchor_right = 1.0
	_connection_layer.anchor_bottom = 1.0
	_connection_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tree_root.add_child(_connection_layer)

	_node_layer = Control.new()
	_node_layer.name = "NodeLayer"
	_node_layer.anchor_right = 1.0
	_node_layer.anchor_bottom = 1.0
	_node_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tree_root.add_child(_node_layer)

	var tree_title: Label = Label.new()
	tree_title.text = "UPGRADE TREE"
	tree_title.position = Vector2(316.0, 10.0)
	tree_title.modulate = Color(0.96, 0.93, 0.84, 0.96)
	_tree_root.add_child(tree_title)

	_add_branch_label("Conversion", Vector2(90.0, 52.0))
	_add_branch_label("Faith Flow", Vector2(290.0, 52.0))
	_add_branch_label("World Control", Vector2(472.0, 52.0))

	_run_summary_panel = Panel.new()
	_run_summary_panel.name = "RunSummaryPanel"
	_run_summary_panel.offset_left = 60.0
	_run_summary_panel.offset_top = 95.0
	_run_summary_panel.offset_right = 310.0
	_run_summary_panel.offset_bottom = 215.0
	var summary_style: StyleBoxTexture = StyleBoxTexture.new()
	summary_style.texture = UI_TEXTURES["panel_main"] as Texture2D
	summary_style.set_texture_margin_all(10.0)
	_run_summary_panel.add_theme_stylebox_override("panel", summary_style)
	add_child(_run_summary_panel)

	var summary_box: VBoxContainer = VBoxContainer.new()
	summary_box.anchor_right = 1.0
	summary_box.anchor_bottom = 1.0
	summary_box.offset_left = 12.0
	summary_box.offset_top = 10.0
	summary_box.offset_right = -12.0
	summary_box.offset_bottom = -10.0
	summary_box.add_theme_constant_override("separation", 6)
	_run_summary_panel.add_child(summary_box)

	var summary_title: Label = Label.new()
	summary_title.text = "RUN SUMMARY"
	summary_box.add_child(summary_title)

	_run_followers_label = _build_summary_row(summary_box)
	_run_faith_label = _build_summary_row(summary_box)

	_continue_button = Button.new()
	_continue_button.name = "ContinueButton"
	_continue_button.anchor_left = 0.0
	_continue_button.anchor_top = 0.0
	_continue_button.anchor_right = 0.0
	_continue_button.anchor_bottom = 0.0
	_continue_button.offset_left = 0.0
	_continue_button.offset_top = 0.0
	_continue_button.offset_right = 240.0
	_continue_button.offset_bottom = 56.0
	_continue_button.text = "CONTINUE CULT"
	_apply_continue_button_visual(_continue_button)
	_continue_button.pressed.connect(_on_continue_pressed)
	add_child(_continue_button)

	_tooltip_panel = Panel.new()
	_tooltip_panel.name = "TooltipPanel"
	_tooltip_panel.visible = false
	_tooltip_panel.size = Vector2(280.0, 136.0)
	var tooltip_style: StyleBoxTexture = StyleBoxTexture.new()
	tooltip_style.texture = UI_TEXTURES["tooltip_panel"] as Texture2D
	tooltip_style.set_texture_margin_all(10.0)
	_tooltip_panel.add_theme_stylebox_override("panel", tooltip_style)
	add_child(_tooltip_panel)

	_tooltip_label = Label.new()
	_tooltip_label.anchor_right = 1.0
	_tooltip_label.anchor_bottom = 1.0
	_tooltip_label.offset_left = 10.0
	_tooltip_label.offset_top = 8.0
	_tooltip_label.offset_right = -10.0
	_tooltip_label.offset_bottom = -8.0
	_tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_panel.add_child(_tooltip_label)

func _apply_layout() -> void:
	if _tree_root == null or _run_summary_panel == null or _continue_button == null:
		return

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var panel_size: Vector2 = Vector2(720.0, 390.0)
	var panel_pos: Vector2 = Vector2(
		(viewport_size.x - panel_size.x) * 0.5,
		max(95.0, (viewport_size.y - panel_size.y) * 0.34)
	)

	_tree_root.position = panel_pos
	_tree_root.size = panel_size

	var summary_size: Vector2 = Vector2(240.0, 120.0)
	var summary_pos: Vector2 = Vector2(max(24.0, panel_pos.x - summary_size.x - 24.0), panel_pos.y)
	_run_summary_panel.position = summary_pos
	_run_summary_panel.size = summary_size

	var continue_size: Vector2 = Vector2(240.0, 58.0)
	_continue_button.position = Vector2(
		panel_pos.x + (panel_size.x - continue_size.x) * 0.5,
		panel_pos.y + panel_size.y + 18.0
	)
	_continue_button.size = continue_size

	var tooltip_size: Vector2 = Vector2(240.0, 170.0)
	_tooltip_panel.size = tooltip_size
	_tooltip_default_position = Vector2(panel_pos.x + panel_size.x + 24.0, panel_pos.y)
	if _tooltip_default_position.x + tooltip_size.x > viewport_size.x - 12.0:
		_tooltip_default_position = Vector2(summary_pos.x, summary_pos.y + summary_size.y + 14.0)

	if _continue_button.position.y + continue_size.y > viewport_size.y - 8.0:
		_continue_button.position.y = viewport_size.y - continue_size.y - 8.0

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()

func _build_summary_row(parent: VBoxContainer) -> Label:
	var container: PanelContainer = PanelContainer.new()
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = UI_TEXTURES["tooltip_label_bg"] as Texture2D
	style.set_texture_margin_all(6.0)
	container.add_theme_stylebox_override("panel", style)
	container.custom_minimum_size = Vector2(0.0, 26.0)
	parent.add_child(container)

	var label: Label = Label.new()
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = 8.0
	label.offset_top = 3.0
	label.offset_right = -8.0
	label.offset_bottom = -3.0
	container.add_child(label)
	return label

func _apply_continue_button_visual(button: Button) -> void:
	var idle: Texture2D = UI_TEXTURES["continue_idle"] as Texture2D
	var hover: Texture2D = UI_TEXTURES["continue_hover"] as Texture2D
	var pressed: Texture2D = UI_TEXTURES["continue_pressed"] as Texture2D

	var normal_style: StyleBoxTexture = StyleBoxTexture.new()
	normal_style.texture = idle
	normal_style.set_texture_margin_all(8.0)

	var hover_style: StyleBoxTexture = StyleBoxTexture.new()
	hover_style.texture = hover
	hover_style.set_texture_margin_all(8.0)

	var pressed_style: StyleBoxTexture = StyleBoxTexture.new()
	pressed_style.texture = pressed
	pressed_style.set_texture_margin_all(8.0)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", hover_style)
	button.add_theme_stylebox_override("disabled", normal_style)

func _add_branch_label(text_value: String, local_position: Vector2) -> void:
	var label: Label = Label.new()
	label.text = text_value
	label.position = local_position
	label.modulate = Color(0.88, 0.88, 0.9, 0.85)
	_tree_root.add_child(label)

func _build_tree_nodes() -> void:
	_nodes_by_id.clear()
	_defs_by_id.clear()

	if _game_manager == null:
		return

	var definitions: Array[Dictionary] = _game_manager.get_upgrade_definitions()
	for definition: Dictionary in definitions:
		var patched: Dictionary = _apply_display_copy(definition)
		var id: String = String(patched.get("id", ""))
		if id.is_empty():
			continue
		_defs_by_id[id] = patched

	for id: String in NODE_POSITIONS.keys():
		if not _defs_by_id.has(id):
			continue

		var node_control: UpgradeTreeNode = UPGRADE_TREE_NODE_SCENE.instantiate() as UpgradeTreeNode
		if node_control == null:
			continue

		var node_size: Vector2 = _node_size_for(id)
		node_control.custom_minimum_size = node_size
		node_control.size = node_size
		node_control.position = _scaled_position(id)
		node_control.set_upgrade_data(_defs_by_id[id] as Dictionary)
		node_control.node_pressed.connect(_on_upgrade_node_pressed)
		node_control.node_hover_started.connect(_on_node_hover_started)
		node_control.node_hover_ended.connect(_on_node_hover_ended)
		_node_layer.add_child(node_control)
		_nodes_by_id[id] = node_control

func _scaled_position(upgrade_id: String) -> Vector2:
	var raw: Vector2 = NODE_POSITIONS.get(upgrade_id, Vector2.ZERO) as Vector2
	return Vector2(raw.x * LAYOUT_SCALE_X, raw.y * LAYOUT_SCALE_Y) + Vector2(40.0, 68.0)

func _node_size_for(upgrade_id: String) -> Vector2:
	if upgrade_id == "awakening":
		return ROOT_NODE_SIZE
	if upgrade_id == "they_can_see_you":
		return FINAL_NODE_SIZE
	return BASE_NODE_SIZE

func _node_center(upgrade_id: String) -> Vector2:
	if not _nodes_by_id.has(upgrade_id):
		return Vector2.ZERO
	var node_control: UpgradeTreeNode = _nodes_by_id[upgrade_id] as UpgradeTreeNode
	if node_control == null:
		return Vector2.ZERO
	return node_control.position + (node_control.size * 0.5)

func _refresh_tree() -> void:
	if _game_manager == null:
		return

	visible = _game_manager.is_upgrade_phase() and not _game_manager.final_sequence_active
	if not visible:
		_hide_tooltip()
		return

	_apply_layout()

	var definitions: Array[Dictionary] = _game_manager.get_upgrade_definitions()
	for definition: Dictionary in definitions:
		var patched: Dictionary = _apply_display_copy(definition)
		var id: String = String(patched.get("id", ""))
		if id.is_empty() or not _nodes_by_id.has(id):
			continue

		_defs_by_id[id] = patched
		var node_control: UpgradeTreeNode = _nodes_by_id[id] as UpgradeTreeNode
		if node_control == null:
			continue

		node_control.set_upgrade_data(patched)
		var state: String = _game_manager.get_upgrade_display_state(id)
		node_control.set_visual_state(state)

	_rebuild_connections()

	if _run_followers_label != null:
		_run_followers_label.text = "Followers gained: %d" % _game_manager.run_followers_gained
	if _run_faith_label != null:
		_run_faith_label.text = "Faith gained: %.1f" % _game_manager.run_faith_gained

func _apply_display_copy(definition: Dictionary) -> Dictionary:
	var patched: Dictionary = definition.duplicate(true)
	var id: String = String(patched.get("id", ""))
	if id.is_empty() or not UPGRADE_COPY_BY_ID.has(id):
		return patched

	var copy: Dictionary = UPGRADE_COPY_BY_ID[id] as Dictionary
	patched["name"] = String(copy.get("display_name", patched.get("name", id)))
	patched["short_desc"] = String(copy.get("short_desc", ""))
	patched["tooltip_title"] = String(copy.get("tooltip_title", patched["name"]))
	patched["tooltip_desc"] = String(copy.get("tooltip_desc", patched.get("description", "")))
	patched["description"] = patched["tooltip_desc"]
	patched["icon_texture"] = _icon_texture_for_upgrade(id)
	return patched

func _icon_texture_for_upgrade(upgrade_id: String) -> Texture2D:
	var role: String = String(ICON_ROLE_BY_ID.get(upgrade_id, "cult"))
	if ICON_TEXTURES.has(role):
		return ICON_TEXTURES[role] as Texture2D
	return ICON_TEXTURES["cult"] as Texture2D

func _rebuild_connections() -> void:
	for child: Node in _connection_layer.get_children():
		child.queue_free()

	for edge: PackedStringArray in DEPENDENCY_EDGES:
		if edge.size() < 2:
			continue

		var from_id: String = edge[0]
		var to_id: String = edge[1]
		if not _nodes_by_id.has(from_id) or not _nodes_by_id.has(to_id):
			continue

		var is_active: bool = _is_edge_active(to_id)
		var line: Line2D = Line2D.new()
		line.width = 2.2
		line.antialiased = true
		line.texture_mode = Line2D.LINE_TEXTURE_TILE
		line.texture = (UI_TEXTURES["connector_active"] if is_active else UI_TEXTURES["connector_line"]) as Texture2D
		line.default_color = Color(1.0, 1.0, 1.0, 0.42 if is_active else 0.22)
		line.add_point(_node_center(from_id))
		line.add_point(_node_center(to_id))
		_connection_layer.add_child(line)

func _is_edge_active(destination_id: String) -> bool:
	if _game_manager == null:
		return false
	var state: String = _game_manager.get_upgrade_display_state(destination_id)
	return state == "available" or state == "unaffordable" or state == "purchased"

func _on_upgrade_node_pressed(upgrade_id: String) -> void:
	if _game_manager == null:
		return
	if _game_manager.final_sequence_active:
		return
	if not _game_manager.is_upgrade_phase():
		return

	var node_control: UpgradeTreeNode = _nodes_by_id.get(upgrade_id, null) as UpgradeTreeNode
	if _game_manager.purchase_upgrade(upgrade_id):
		if node_control != null:
			node_control.pulse_purchased()
		upgrade_purchased.emit({"id": upgrade_id})
		_refresh_tree()
	else:
		if node_control != null:
			node_control.flash_invalid()

func _on_node_hover_started(upgrade_id: String, screen_position: Vector2) -> void:
	if not _defs_by_id.has(upgrade_id):
		_hide_tooltip()
		return

	var data: Dictionary = _defs_by_id[upgrade_id] as Dictionary
	var title: String = String(data.get("tooltip_title", data.get("name", upgrade_id)))
	var tooltip_desc: String = String(data.get("tooltip_desc", data.get("description", "")))
	var cost: float = float(data.get("cost", 0.0))
	var state: String = "locked"
	if _game_manager != null:
		state = _game_manager.get_upgrade_display_state(upgrade_id)

	var lines: PackedStringArray = PackedStringArray()
	lines.append(title)
	lines.append(tooltip_desc)
	if state == "purchased":
		lines.append("Status: Purchased")
	else:
		lines.append("Cost: %.0f Faith" % cost)
	if state == "locked":
		var deps: PackedStringArray = data.get("dependencies", PackedStringArray()) as PackedStringArray
		if not deps.is_empty():
			lines.append("Requires: %s" % _format_dependency_names(deps))

	_tooltip_label.text = "\n".join(lines)
	_tooltip_panel.visible = true

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var max_x: float = viewport_size.x - _tooltip_panel.size.x - 12.0
	var max_y: float = viewport_size.y - _tooltip_panel.size.y - 12.0
	_tooltip_panel.position = Vector2(
		clamp(_tooltip_default_position.x, 12.0, max_x),
		clamp(_tooltip_default_position.y, 12.0, max_y)
	)

func _format_dependency_names(dependencies: PackedStringArray) -> String:
	var display_names: PackedStringArray = PackedStringArray()
	for dependency_id: String in dependencies:
		display_names.append(_display_name_for_id(dependency_id))
	return ", ".join(display_names)

func _display_name_for_id(upgrade_id: String) -> String:
	if UPGRADE_COPY_BY_ID.has(upgrade_id):
		var copy: Dictionary = UPGRADE_COPY_BY_ID[upgrade_id] as Dictionary
		return String(copy.get("display_name", upgrade_id))
	if _defs_by_id.has(upgrade_id):
		var data: Dictionary = _defs_by_id[upgrade_id] as Dictionary
		return String(data.get("name", upgrade_id))
	return upgrade_id

func _on_node_hover_ended() -> void:
	_hide_tooltip()

func _hide_tooltip() -> void:
	if _tooltip_panel != null:
		_tooltip_panel.visible = false

func _on_continue_pressed() -> void:
	if _game_manager == null:
		return
	_game_manager.continue_from_upgrade()
