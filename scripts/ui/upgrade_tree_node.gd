extends Control
class_name UpgradeTreeNode

signal node_pressed(upgrade_id: String)
signal node_hover_started(upgrade_id: String, screen_position: Vector2)
signal node_hover_ended()

static var NODE_TEXTURES: Dictionary = {
	"default": preload("res://assets/ui/nodes/upgrade_card_bg.png"),
	"hover": preload("res://assets/ui/nodes/upgrade_node_hover.png"),
	"locked": preload("res://assets/ui/nodes/upgrade_node_locked.png"),
	"purchased": preload("res://assets/ui/nodes/upgrade_node_purchased.png"),
	"root": preload("res://assets/ui/nodes/upgrade_node_root.png"),
	"final": preload("res://assets/ui/nodes/upgrade_node_final.png")
}

const UPGRADE_PULSE_TEXTURE: Texture2D = preload("res://assets/ui/effects/upgrade_pulse.png")

@onready var _background: TextureRect = $Background
@onready var _icon: TextureRect = $Icon
@onready var _name_label: Label = $NameLabel
@onready var _short_desc_label: Label = $ShortDescLabel
@onready var _cost_label: Label = $CostLabel
@onready var _purchased_mark: Label = $PurchasedMark
@onready var _lock_overlay: ColorRect = $LockOverlay
@onready var _hit_button: Button = $HitButton
@onready var _pulse_overlay: TextureRect = $PulseOverlay

var _upgrade_id: String = ""
var _tooltip_title: String = ""
var _tooltip_desc: String = ""
var _short_desc: String = ""
var _cost: float = 0.0
var _dependencies: PackedStringArray = PackedStringArray()
var _visual_state: String = "locked"

func _ready() -> void:
	_background.stretch_mode = TextureRect.STRETCH_SCALE
	_pulse_overlay.stretch_mode = TextureRect.STRETCH_SCALE
	_hit_button.pressed.connect(_on_pressed)
	_hit_button.mouse_entered.connect(_on_mouse_entered)
	_hit_button.mouse_exited.connect(_on_mouse_exited)
	_hit_button.focus_entered.connect(_on_mouse_entered)
	_hit_button.focus_exited.connect(_on_mouse_exited)
	_pulse_overlay.texture = UPGRADE_PULSE_TEXTURE
	_pulse_overlay.visible = false
	_apply_visual_state()

func set_upgrade_data(data: Dictionary) -> void:
	_upgrade_id = String(data.get("id", ""))
	_tooltip_title = String(data.get("tooltip_title", data.get("name", _upgrade_id)))
	_tooltip_desc = String(data.get("tooltip_desc", data.get("description", "")))
	_short_desc = String(data.get("short_desc", ""))
	_cost = float(data.get("cost", 0.0))
	_dependencies = data.get("dependencies", PackedStringArray()) as PackedStringArray

	_name_label.text = String(data.get("name", _upgrade_id))
	_short_desc_label.text = _short_desc
	_cost_label.text = "Cost: %.0f Faith" % _cost
	_icon.texture = data.get("icon_texture", null) as Texture2D

func set_visual_state(state: String) -> void:
	_visual_state = state
	_apply_visual_state()

func set_selected(is_selected: bool) -> void:
	if is_selected:
		modulate = Color(1.08, 1.08, 1.08, 1.0)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func get_upgrade_id() -> String:
	return _upgrade_id

func get_tooltip_title() -> String:
	return _tooltip_title

func get_tooltip_desc() -> String:
	return _tooltip_desc

func get_short_desc() -> String:
	return _short_desc

func get_cost() -> float:
	return _cost

func get_dependencies() -> PackedStringArray:
	return _dependencies

func pulse_purchased() -> void:
	var base_scale: Vector2 = scale
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", base_scale * 1.05, 0.1)
	tween.tween_property(self, "scale", base_scale, 0.12)

	_pulse_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_pulse_overlay.visible = true
	var pulse_tween: Tween = create_tween()
	pulse_tween.tween_property(_pulse_overlay, "modulate:a", 0.95, 0.08)
	pulse_tween.tween_property(_pulse_overlay, "modulate:a", 0.0, 0.22)
	pulse_tween.finished.connect(func() -> void: _pulse_overlay.visible = false)

func flash_invalid() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 0.72, 0.72, 1.0), 0.08)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)

func _apply_visual_state() -> void:
	var available_texture: Texture2D = _get_base_available_texture()
	var hover_texture: Texture2D = NODE_TEXTURES["hover"] as Texture2D
	var locked_texture: Texture2D = NODE_TEXTURES["locked"] as Texture2D
	var purchased_texture: Texture2D = NODE_TEXTURES["purchased"] as Texture2D

	match _visual_state:
		"available":
			_background.texture = hover_texture
			_lock_overlay.visible = false
			_purchased_mark.visible = false
			_hit_button.disabled = false
			_name_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
			_short_desc_label.modulate = Color(0.95, 0.95, 0.95, 1.0)
			_cost_label.modulate = Color(1.0, 0.95, 0.78, 1.0)
		"unaffordable":
			_background.texture = available_texture
			_lock_overlay.visible = false
			_purchased_mark.visible = false
			_hit_button.disabled = false
			_name_label.modulate = Color(0.88, 0.88, 0.88, 1.0)
			_short_desc_label.modulate = Color(0.84, 0.84, 0.84, 1.0)
			_cost_label.modulate = Color(0.95, 0.76, 0.76, 1.0)
		"purchased":
			_background.texture = purchased_texture
			_lock_overlay.visible = false
			_purchased_mark.visible = true
			_hit_button.disabled = true
			_name_label.modulate = Color(0.72, 1.0, 0.78, 1.0)
			_short_desc_label.modulate = Color(0.72, 1.0, 0.78, 1.0)
			_cost_label.modulate = Color(0.72, 1.0, 0.78, 1.0)
		_:
			_background.texture = locked_texture
			_lock_overlay.visible = true
			_purchased_mark.visible = false
			_hit_button.disabled = false
			_name_label.modulate = Color(0.7, 0.7, 0.7, 1.0)
			_short_desc_label.modulate = Color(0.66, 0.66, 0.66, 1.0)
			_cost_label.modulate = Color(0.65, 0.65, 0.65, 1.0)

func _get_base_available_texture() -> Texture2D:
	if _upgrade_id == "awakening":
		return NODE_TEXTURES["root"] as Texture2D
	if _upgrade_id == "they_can_see_you":
		return NODE_TEXTURES["final"] as Texture2D
	return NODE_TEXTURES["default"] as Texture2D

func _on_pressed() -> void:
	node_pressed.emit(_upgrade_id)

func _on_mouse_entered() -> void:
	node_hover_started.emit(_upgrade_id, get_global_rect().end)

func _on_mouse_exited() -> void:
	node_hover_ended.emit()
