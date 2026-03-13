extends Control

@warning_ignore("unused_signal")
signal upgrade_purchased(upgrade: Dictionary)

const UPGRADE_TREE_NODE_SCENE: PackedScene = preload("res://scenes/ui/upgrade_tree_node.tscn")

static var UI_TEXTURES: Dictionary = {
	"panel_main": preload("res://assets/ui/panels/panel_main.png"),
	"panel_upgrade": preload("res://assets/ui/panels/panel_card.png"),
	"panel_popup": preload("res://assets/ui/panels/panel_popup.png"),
	"panel_main_9slice": preload("res://assets/ui/panels/panel_card_9slice.png"),
	"panel_card_9slice": preload("res://assets/ui/panels/panel_card_9slice.png"),
	"panel_tooltip_9slice": preload("res://assets/ui/panels/panel_tooltip_9slice.png"),
	"overlay_dark": preload("res://assets/ui/overlays/ui_dark_overlay.png"),
	"tooltip_panel": preload("res://assets/ui/tooltips/tooltip_panel.png"),
	"tooltip_label_bg": preload("res://assets/ui/labels/label_bg.png"),
	"continue_idle": preload("res://assets/ui/buttons/btn_continue_idle.png"),
	"continue_hover": preload("res://assets/ui/buttons/btn_continue_hover.png"),
	"continue_pressed": preload("res://assets/ui/buttons/btn_continue_pressed.png"),
	"button_primary": preload("res://assets/ui/buttons/btn_upgrade_hover.png"),
	"button_secondary": preload("res://assets/ui/buttons/btn_upgrade.png"),
	"button_disabled": preload("res://assets/ui/buttons/btn_upgrade_disabled.png"),
	"connector_line": preload("res://assets/ui/connectors/tree_connector_line.png"),
	"connector_active": preload("res://assets/ui/connectors/tree_connector_active.png")
}

static var ICON_TEXTURES: Dictionary = {
	"conversion": preload("res://assets/ui/icons/icon_conversion.png"),
	"faith": preload("res://assets/ui/icons/icon_faith.png"),
	"spawn": preload("res://assets/ui/icons/icon_spawn.png"),
	"cult": preload("res://assets/ui/icons/icon_cult.png"),
	"aura": preload("res://assets/ui/icons/icon_aura.png"),
	"aura_ui": preload("res://assets/vfx/cursor/cursor_ripple.png"),
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

const UPGRADE_ICON_KEY_BY_ID: Dictionary = {
	"awakening": "divine_favor",
	"magnetic_presence": "cult_influence",
	"faster_conversion": "conversion_speed",
	"conversion_pulse": "dark_ritual",
	"conversion_chain": "conversion_chain",
	"mass_conversion": "mass_conversion",
	"faith_amplifier": "faith_multiplier",
	"cult_donations": "faith_multiplier",
	"sacred_economy": "cult_growth",
	"divine_harvest": "forbidden_knowledge",
	"overflow_faith": "corruption_power",
	"curious_crowds": "cult_growth",
	"pilgrimage": "cult_influence",
	"wandering_faith": "corruption_power",
	"sacred_ground": "dark_ritual",
	"cult_leaders": "cult_dominion",
	"prophecy": "divine_favor",
	"skeptic_hunt": "corruption_power",
	"divine_aura": "cult_influence",
	"cult_expansion": "cult_growth",
	"worship_wave": "ritual_mastery",
	"they_can_see_you": "cult_dominion"
}

const LAYOUT_SCALE_X: float = 1.0
const LAYOUT_SCALE_Y: float = 1.0
const BASE_NODE_SIZE: Vector2 = Vector2(148.0, 48.0)
const ROOT_NODE_SIZE: Vector2 = Vector2(160.0, 52.0)
const FINAL_NODE_SIZE: Vector2 = Vector2(160.0, 52.0)

const NODE_POSITIONS: Dictionary = {
    "awakening": Vector2(404.0, 24.0),
    "magnetic_presence": Vector2(24.0, 96.0),
    "faster_conversion": Vector2(24.0, 156.0),
    "conversion_pulse": Vector2(24.0, 216.0),
    "conversion_chain": Vector2(24.0, 276.0),
    "mass_conversion": Vector2(24.0, 336.0),
    "faith_amplifier": Vector2(214.0, 96.0),
    "steady_worship": Vector2(214.0, 156.0),
    "violent_faith": Vector2(214.0, 216.0),
    "cult_donations": Vector2(214.0, 276.0),
    "sacred_economy": Vector2(214.0, 336.0),
    "divine_harvest": Vector2(214.0, 396.0),
    "curious_crowds": Vector2(404.0, 96.0),
    "path_growth": Vector2(404.0, 156.0),
    "path_control": Vector2(404.0, 216.0),
    "pilgrimage": Vector2(404.0, 276.0),
    "sacred_ground": Vector2(404.0, 336.0),
    "ritual_knife": Vector2(784.0, 96.0),
    "blood_ledger": Vector2(784.0, 156.0),
    "blood_tithe": Vector2(784.0, 216.0),
    "grand_offering": Vector2(784.0, 276.0),
    "cult_leaders": Vector2(594.0, 96.0),
    "wide_influence": Vector2(594.0, 156.0),
    "focused_conversion": Vector2(594.0, 216.0),
    "divine_aura": Vector2(594.0, 336.0),
    "cult_expansion": Vector2(594.0, 396.0),
    "worship_wave": Vector2(784.0, 336.0),
    "they_can_see_you": Vector2(784.0, 456.0)
}
static var DEPENDENCY_EDGES: Array[PackedStringArray] = [
    PackedStringArray(["awakening", "magnetic_presence"]),
    PackedStringArray(["awakening", "faster_conversion"]),
    PackedStringArray(["magnetic_presence", "conversion_pulse"]),
    PackedStringArray(["faster_conversion", "conversion_chain"]),
    PackedStringArray(["conversion_chain", "mass_conversion"]),
    PackedStringArray(["awakening", "faith_amplifier"]),
    PackedStringArray(["faith_amplifier", "steady_worship"]),
    PackedStringArray(["faith_amplifier", "violent_faith"]),
    PackedStringArray(["steady_worship", "cult_donations"]),
    PackedStringArray(["cult_donations", "sacred_economy"]),
    PackedStringArray(["violent_faith", "divine_harvest"]),
    PackedStringArray(["awakening", "curious_crowds"]),
    PackedStringArray(["curious_crowds", "path_growth"]),
    PackedStringArray(["curious_crowds", "path_control"]),
    PackedStringArray(["path_control", "pilgrimage"]),
    PackedStringArray(["curious_crowds", "sacred_ground"]),
    PackedStringArray(["awakening", "ritual_knife"]),
    PackedStringArray(["ritual_knife", "blood_ledger"]),
    PackedStringArray(["blood_ledger", "blood_tithe"]),
    PackedStringArray(["blood_tithe", "grand_offering"]),
    PackedStringArray(["mass_conversion", "cult_leaders"]),
    PackedStringArray(["ritual_knife", "cult_leaders"]),
    PackedStringArray(["cult_leaders", "wide_influence"]),
    PackedStringArray(["cult_leaders", "focused_conversion"]),
    PackedStringArray(["cult_leaders", "divine_aura"]),
    PackedStringArray(["sacred_ground", "cult_expansion"]),
    PackedStringArray(["divine_aura", "cult_expansion"]),
    PackedStringArray(["cult_expansion", "worship_wave"]),
    PackedStringArray(["worship_wave", "they_can_see_you"])
]

@export var game_manager_path: NodePath

var _game_manager: GameManager
var _dark_overlay: TextureRect
var _tree_root: Control
var _main_panel_frame: Panel
var _connection_layer: Control
var _node_layer: Control
var _tooltip_panel: Panel
var _tooltip_label: Label
var _run_summary_panel: Panel
var _run_followers_label: Label
var _run_faith_label: Label
var _continue_button: Button
var _tooltip_default_position: Vector2 = Vector2.ZERO
var _sacrifice_panel: Panel
var _sacrifice_preview_label: Label
var _sacrifice_auto_status_label: Label
var _sacrifice_countdown_label: Label
var _sacrifice_button_50: Button
var _sacrifice_button_100: Button
var _sacrifice_button_25p: Button
var _sacrifice_button_max: Button


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
	_dark_overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
	_tree_root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_tree_root)

	_main_panel_frame = Panel.new()
	_main_panel_frame.name = "MainPanelFrame"
	_main_panel_frame.anchor_right = 1.0
	_main_panel_frame.anchor_bottom = 1.0
	_main_panel_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_panel_frame.clip_contents = true
	var main_panel_style: StyleBoxTexture = StyleBoxTexture.new()
	main_panel_style.texture = UI_TEXTURES["panel_main_9slice"] as Texture2D
	main_panel_style.texture_margin_left = 28.0
	main_panel_style.texture_margin_top = 28.0
	main_panel_style.texture_margin_right = 28.0
	main_panel_style.texture_margin_bottom = 28.0
	main_panel_style.content_margin_left = 18.0
	main_panel_style.content_margin_top = 14.0
	main_panel_style.content_margin_right = 18.0
	main_panel_style.content_margin_bottom = 14.0
	_main_panel_frame.add_theme_stylebox_override("panel", main_panel_style)
	_tree_root.add_child(_main_panel_frame)

	_connection_layer = Control.new()
	_connection_layer.name = "ConnectionLayer"
	_connection_layer.anchor_right = 1.0
	_connection_layer.anchor_bottom = 1.0
	_connection_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_panel_frame.add_child(_connection_layer)

	_node_layer = Control.new()
	_node_layer.name = "NodeLayer"
	_node_layer.anchor_right = 1.0
	_node_layer.anchor_bottom = 1.0
	_node_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	_main_panel_frame.add_child(_node_layer)

	var tree_title: Label = Label.new()
	tree_title.text = "UPGRADE TREE"
	tree_title.position = Vector2(390.0, 12.0)
	tree_title.modulate = Color(0.96, 0.93, 0.84, 0.96)
	_main_panel_frame.add_child(tree_title)

	_add_branch_label("Conversion", Vector2(26.0, 68.0))
	_add_branch_label("Faith Flow", Vector2(226.0, 68.0))
	_add_branch_label("World Control", Vector2(426.0, 68.0))

	_add_branch_label("Cult Power", Vector2(606.0, 68.0))
	_add_branch_label("Ritual", Vector2(806.0, 68.0))
	_run_summary_panel = Panel.new()
	_run_summary_panel.name = "RunSummaryPanel"
	_run_summary_panel.offset_left = 60.0
	_run_summary_panel.offset_top = 95.0
	_run_summary_panel.offset_right = 310.0
	_run_summary_panel.offset_bottom = 215.0
	var summary_style: StyleBoxTexture = StyleBoxTexture.new()
	summary_style.texture = UI_TEXTURES["panel_tooltip_9slice"] as Texture2D
	summary_style.texture_margin_left = 16.0
	summary_style.texture_margin_top = 16.0
	summary_style.texture_margin_right = 16.0
	summary_style.texture_margin_bottom = 16.0
	summary_style.content_margin_left = 10.0
	summary_style.content_margin_top = 8.0
	summary_style.content_margin_right = 10.0
	summary_style.content_margin_bottom = 8.0
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

	_sacrifice_panel = Panel.new()
	_sacrifice_panel.name = "SacrificePanel"
	var sacrifice_style: StyleBoxTexture = StyleBoxTexture.new()
	sacrifice_style.texture = UI_TEXTURES["panel_tooltip_9slice"] as Texture2D
	sacrifice_style.texture_margin_left = 16.0
	sacrifice_style.texture_margin_top = 16.0
	sacrifice_style.texture_margin_right = 16.0
	sacrifice_style.texture_margin_bottom = 16.0
	sacrifice_style.content_margin_left = 10.0
	sacrifice_style.content_margin_top = 8.0
	sacrifice_style.content_margin_right = 10.0
	sacrifice_style.content_margin_bottom = 8.0
	_sacrifice_panel.add_theme_stylebox_override("panel", sacrifice_style)
	add_child(_sacrifice_panel)

	var sacrifice_box: VBoxContainer = VBoxContainer.new()
	sacrifice_box.anchor_right = 1.0
	sacrifice_box.anchor_bottom = 1.0
	sacrifice_box.offset_left = 12.0
	sacrifice_box.offset_top = 10.0
	sacrifice_box.offset_right = -12.0
	sacrifice_box.offset_bottom = -10.0
	sacrifice_box.add_theme_constant_override("separation", 5)
	_sacrifice_panel.add_child(sacrifice_box)

	var sacrifice_title: Label = Label.new()
	sacrifice_title.text = "SACRIFICE"
	sacrifice_box.add_child(sacrifice_title)

	_sacrifice_preview_label = Label.new()
	_sacrifice_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sacrifice_box.add_child(_sacrifice_preview_label)

	_sacrifice_auto_status_label = Label.new()
	sacrifice_box.add_child(_sacrifice_auto_status_label)

	_sacrifice_countdown_label = Label.new()
	sacrifice_box.add_child(_sacrifice_countdown_label)

	var sacrifice_row_a: HBoxContainer = HBoxContainer.new()
	sacrifice_row_a.add_theme_constant_override("separation", 6)
	sacrifice_box.add_child(sacrifice_row_a)

	_sacrifice_button_50 = Button.new()
	_sacrifice_button_50.text = "Sacrifice 50"
	_apply_small_button_visual(_sacrifice_button_50, true)
	_sacrifice_button_50.pressed.connect(_on_sacrifice_50_pressed)
	sacrifice_row_a.add_child(_sacrifice_button_50)

	_sacrifice_button_100 = Button.new()
	_sacrifice_button_100.text = "Sacrifice 100"
	_apply_small_button_visual(_sacrifice_button_100, false)
	_sacrifice_button_100.pressed.connect(_on_sacrifice_100_pressed)
	sacrifice_row_a.add_child(_sacrifice_button_100)

	var sacrifice_row_b: HBoxContainer = HBoxContainer.new()
	sacrifice_row_b.add_theme_constant_override("separation", 6)
	sacrifice_box.add_child(sacrifice_row_b)

	_sacrifice_button_25p = Button.new()
	_sacrifice_button_25p.text = "Sacrifice 25%"
	_apply_small_button_visual(_sacrifice_button_25p, false)
	_sacrifice_button_25p.pressed.connect(_on_sacrifice_25p_pressed)
	sacrifice_row_b.add_child(_sacrifice_button_25p)

	_sacrifice_button_max = Button.new()
	_sacrifice_button_max.text = "Sacrifice MAX"
	_apply_small_button_visual(_sacrifice_button_max, true)
	_sacrifice_button_max.pressed.connect(_on_sacrifice_max_pressed)
	sacrifice_row_b.add_child(_sacrifice_button_max)

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
	tooltip_style.texture = UI_TEXTURES["panel_tooltip_9slice"] as Texture2D
	tooltip_style.texture_margin_left = 16.0
	tooltip_style.texture_margin_top = 16.0
	tooltip_style.texture_margin_right = 16.0
	tooltip_style.texture_margin_bottom = 16.0
	tooltip_style.content_margin_left = 10.0
	tooltip_style.content_margin_top = 8.0
	tooltip_style.content_margin_right = 10.0
	tooltip_style.content_margin_bottom = 8.0
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
	var top_safe: float = 86.0
	var bottom_reserved: float = 230.0
	var panel_size: Vector2 = Vector2(
		clamp(viewport_size.x - 90.0, 860.0, 1180.0),
		clamp(viewport_size.y - (top_safe + bottom_reserved), 340.0, 500.0)
	)
	var panel_pos: Vector2 = Vector2(
		(viewport_size.x - panel_size.x) * 0.5,
		top_safe
	)

	_tree_root.position = panel_pos
	_tree_root.size = panel_size

	var continue_size: Vector2 = Vector2(240.0, 56.0)
	_continue_button.position = Vector2(
		panel_pos.x + (panel_size.x - continue_size.x) * 0.5,
		viewport_size.y - continue_size.y - 10.0
	)
	_continue_button.size = continue_size

	var summary_size: Vector2 = Vector2(300.0, 118.0)
	var summary_pos: Vector2 = Vector2(panel_pos.x, panel_pos.y + panel_size.y + 8.0)
	var summary_max_y: float = _continue_button.position.y - summary_size.y - 8.0
	summary_pos.y = min(summary_pos.y, summary_max_y)
	_run_summary_panel.position = summary_pos
	_run_summary_panel.size = summary_size

	if _sacrifice_panel != null:
		var sacrifice_size: Vector2 = Vector2(360.0, 156.0)
		var sacrifice_x: float = panel_pos.x + panel_size.x - sacrifice_size.x
		var sacrifice_y: float = panel_pos.y + panel_size.y + 8.0
		var sacrifice_max_y: float = _continue_button.position.y - sacrifice_size.y - 8.0
		sacrifice_y = min(sacrifice_y, sacrifice_max_y)
		_sacrifice_panel.position = Vector2(sacrifice_x, sacrifice_y)
		_sacrifice_panel.size = sacrifice_size

	var tooltip_size: Vector2 = Vector2(265.0, 180.0)
	_tooltip_panel.size = tooltip_size
	_tooltip_default_position = Vector2(panel_pos.x + panel_size.x + 12.0, panel_pos.y)
	if _tooltip_default_position.x + tooltip_size.x > viewport_size.x - 12.0:
		_tooltip_default_position = Vector2(panel_pos.x + panel_size.x - tooltip_size.x, panel_pos.y + 8.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()

func _build_summary_row(parent: VBoxContainer) -> Label:
	var container: PanelContainer = PanelContainer.new()
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = UI_TEXTURES["tooltip_label_bg"] as Texture2D
	style.texture_margin_left = 8.0
	style.texture_margin_top = 8.0
	style.texture_margin_right = 8.0
	style.texture_margin_bottom = 8.0
	style.content_margin_left = 10.0
	style.content_margin_top = 6.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 6.0
	container.add_theme_stylebox_override("panel", style)
	container.custom_minimum_size = Vector2(0.0, 34.0)
	parent.add_child(container)

	var label: Label = Label.new()
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = 10.0
	label.offset_top = 5.0
	label.offset_right = -10.0
	label.offset_bottom = -5.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
func _apply_small_button_visual(button: Button, emphasize: bool) -> void:
	var primary: Texture2D = UI_TEXTURES["button_primary"] as Texture2D
	var secondary: Texture2D = UI_TEXTURES["button_secondary"] as Texture2D
	var disabled: Texture2D = UI_TEXTURES["button_disabled"] as Texture2D

	var normal_style: StyleBoxTexture = StyleBoxTexture.new()
	normal_style.texture = (primary if emphasize else secondary) as Texture2D
	normal_style.set_texture_margin_all(8.0)

	var hover_style: StyleBoxTexture = StyleBoxTexture.new()
	hover_style.texture = primary
	hover_style.set_texture_margin_all(8.0)

	var pressed_style: StyleBoxTexture = StyleBoxTexture.new()
	pressed_style.texture = secondary
	pressed_style.set_texture_margin_all(8.0)

	var disabled_style: StyleBoxTexture = StyleBoxTexture.new()
	disabled_style.texture = disabled
	disabled_style.set_texture_margin_all(8.0)

	button.custom_minimum_size = Vector2(132.0, 34.0)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", hover_style)
	button.add_theme_stylebox_override("disabled", disabled_style)

func _add_branch_label(text_value: String, local_position: Vector2) -> void:
	var label: Label = Label.new()
	label.text = text_value
	label.position = local_position
	label.modulate = Color(0.88, 0.88, 0.9, 0.85)
	_main_panel_frame.add_child(label)

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
		_node_layer.add_child(node_control)
		node_control.set_upgrade_data(_defs_by_id[id] as Dictionary)
		node_control.node_pressed.connect(_on_upgrade_node_pressed)
		node_control.node_hover_started.connect(_on_node_hover_started)
		node_control.node_hover_ended.connect(_on_node_hover_ended)
		_nodes_by_id[id] = node_control
func _scaled_position(upgrade_id: String) -> Vector2:
	var raw: Vector2 = NODE_POSITIONS.get(upgrade_id, Vector2.ZERO) as Vector2
	return raw

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
	if _nodes_by_id.is_empty() and not definitions.is_empty():
		_build_tree_nodes()

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


	_refresh_sacrifice_panel()
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
	var icon_key: String = String(UPGRADE_ICON_KEY_BY_ID.get(upgrade_id, "cult_dominion"))
	var registry_icon: Texture2D = IconRegistry.get_upgrade_icon(icon_key)
	if registry_icon != null:
		return registry_icon
	if ICON_TEXTURES.has("cult"):
		return ICON_TEXTURES["cult"] as Texture2D
	return null

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
	return state == "available" or state == "unaffordable" or state == "purchased" or state == "choice_locked"

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

func _on_node_hover_started(upgrade_id: String, _screen_position: Vector2) -> void:
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

	var lines: Array[String] = []
	lines.append(title)
	lines.append(tooltip_desc)
	if state == "purchased":
		lines.append("Status: Purchased")
	elif state == "choice_locked":
		var reason: String = _game_manager.get_choice_lock_reason(upgrade_id)
		if reason.is_empty():
			reason = "another upgrade in this group"
		lines.append("Locked by choice: %s" % reason)
	else:
		lines.append("Cost: %.0f Faith" % cost)
	if state == "locked":
		var deps: PackedStringArray = data.get("dependencies", PackedStringArray()) as PackedStringArray
		if not deps.is_empty():
			lines.append("Requires: %s" % _format_dependency_names(deps))

	var tooltip_body: String = ""
	for i: int in range(lines.size()):
		tooltip_body += lines[i]
		if i < lines.size() - 1:
			tooltip_body += "\n"
	_tooltip_label.text = tooltip_body
	_tooltip_panel.visible = true

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var max_x: float = viewport_size.x - _tooltip_panel.size.x - 12.0
	var max_y: float = viewport_size.y - _tooltip_panel.size.y - 12.0
	_tooltip_panel.position = Vector2(
		clamp(_tooltip_default_position.x, 12.0, max_x),
		clamp(_tooltip_default_position.y, 12.0, max_y)
	)

func _format_dependency_names(dependencies: PackedStringArray) -> String:
	var display_names: Array[String] = []
	for dependency_id: String in dependencies:
		display_names.append(_display_name_for_id(dependency_id))
	var out: String = ""
	for i: int in range(display_names.size()):
		out += display_names[i]
		if i < display_names.size() - 1:
			out += ", "
	return out

func _display_name_for_id(upgrade_id: String) -> String:
	if UPGRADE_COPY_BY_ID.has(upgrade_id):
		var copy: Dictionary = UPGRADE_COPY_BY_ID[upgrade_id] as Dictionary
		return String(copy.get("display_name", upgrade_id))
	if _defs_by_id.has(upgrade_id):
		var data: Dictionary = _defs_by_id[upgrade_id] as Dictionary
		return String(data.get("name", upgrade_id))
	return upgrade_id

func _refresh_sacrifice_panel() -> void:
	if _game_manager == null or _sacrifice_preview_label == null:
		return

	var max_safe: int = _game_manager.get_manual_sacrifice_max_safe_amount()
	var preview_faith: float = _game_manager.get_sacrifice_faith_preview(max_safe, "manual")
	if _game_manager.sacrifice_unlocked:
		_sacrifice_preview_label.text = "MAX sacrifice: %d followers -> %.1f faith" % [max_safe, preview_faith]
	else:
		_sacrifice_preview_label.text = "Manual sacrifice locked (Ritual Knife)."

	if _game_manager.auto_sacrifice_enabled:
		_sacrifice_auto_status_label.text = "Auto Sacrifice: Enabled"
		if _game_manager.is_gameplay_phase():
			_sacrifice_countdown_label.text = "Next auto in %.1fs" % _game_manager.get_auto_sacrifice_seconds_until_next()
		else:
			_sacrifice_countdown_label.text = "Auto paused (Upgrade Phase)"
	else:
		_sacrifice_auto_status_label.text = "Auto Sacrifice: Locked"
		_sacrifice_countdown_label.text = "Unlock with Blood Tithe"

	var can_manual: bool = _game_manager.sacrifice_unlocked and _game_manager.is_upgrade_phase()
	var show_manual_buttons: bool = _game_manager.sacrifice_unlocked
	if _sacrifice_button_50 != null:
		_sacrifice_button_50.visible = show_manual_buttons
		_sacrifice_button_50.disabled = not can_manual
	if _sacrifice_button_100 != null:
		_sacrifice_button_100.visible = show_manual_buttons
		_sacrifice_button_100.disabled = not can_manual
	if _sacrifice_button_25p != null:
		_sacrifice_button_25p.visible = show_manual_buttons
		_sacrifice_button_25p.disabled = not can_manual
	if _sacrifice_button_max != null:
		_sacrifice_button_max.visible = show_manual_buttons
		_sacrifice_button_max.disabled = not can_manual

	_apply_layout()

func _on_sacrifice_50_pressed() -> void:
	if _game_manager == null:
		return
	_game_manager.perform_sacrifice(50, "manual")
	_refresh_tree()

func _on_sacrifice_100_pressed() -> void:
	if _game_manager == null:
		return
	_game_manager.perform_sacrifice(100, "manual")
	_refresh_tree()

func _on_sacrifice_25p_pressed() -> void:
	if _game_manager == null:
		return
	var safe: int = _game_manager.get_manual_sacrifice_max_safe_amount()
	var amount: int = int(floor(float(safe) * 0.25))
	_game_manager.perform_sacrifice(max(0, amount), "manual")
	_refresh_tree()

func _on_sacrifice_max_pressed() -> void:
	if _game_manager == null:
		return
	var safe: int = _game_manager.get_manual_sacrifice_max_safe_amount()
	_game_manager.perform_sacrifice(safe, "manual")
	_refresh_tree()

func _on_node_hover_ended() -> void:
	_hide_tooltip()

func _hide_tooltip() -> void:
	if _tooltip_panel != null:
		_tooltip_panel.visible = false

func _on_continue_pressed() -> void:
	if _game_manager == null:
		return
	_game_manager.continue_from_upgrade()



































