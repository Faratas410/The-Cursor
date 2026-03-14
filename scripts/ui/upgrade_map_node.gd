extends Node2D
class_name UpgradeMapNode

signal purchase_requested(upgrade_id: String)
signal tooltip_requested(upgrade_id: String, screen_position: Vector2)
signal tooltip_hidden()

const LOCKED_ALPHA: float = 0.42
const NODE_SIZE: Vector2 = Vector2(96.0, 68.0)

@onready var _icon_button: TextureButton = $Icon
@onready var _state_overlay: ColorRect = $StateOverlay
@onready var _state_label: Label = $StateLabel

var _upgrade_id: String = ""
var _title: String = ""
var _description: String = ""
var _cost: float = 0.0
var _state: String = "locked"
var _ring: Line2D
var _hover_tween: Tween
var _purchase_tween: Tween

func _ready() -> void:
	_icon_button.custom_minimum_size = NODE_SIZE
	_icon_button.pressed.connect(_on_pressed)
	_icon_button.mouse_entered.connect(_on_mouse_entered)
	_icon_button.mouse_exited.connect(_on_mouse_exited)
	_ensure_ring()
	_apply_state()

func set_upgrade_data(data: Dictionary, icon_texture: Texture2D) -> void:
	_upgrade_id = String(data.get("id", ""))
	_title = String(data.get("name", _upgrade_id))
	_description = String(data.get("description", ""))
	_cost = float(data.get("cost", 0.0))
	_icon_button.texture_normal = icon_texture
	_icon_button.texture_hover = icon_texture
	_icon_button.texture_pressed = icon_texture
	_icon_button.texture_disabled = icon_texture

func set_state(new_state: String) -> void:
	var previous_state: String = _state
	_state = new_state
	_apply_state()
	if previous_state != "purchased" and _state == "purchased":
		play_purchase_pulse()

func get_upgrade_id() -> String:
	return _upgrade_id

func get_title() -> String:
	return _title

func get_description() -> String:
	return _description

func get_cost() -> float:
	return _cost

func get_state() -> String:
	return _state

func get_node_size() -> Vector2:
	return NODE_SIZE

func play_purchase_pulse() -> void:
	if _purchase_tween != null and _purchase_tween.is_running():
		_purchase_tween.kill()
	if _hover_tween != null and _hover_tween.is_running():
		_hover_tween.kill()
	_purchase_tween = create_tween()
	_purchase_tween.set_trans(Tween.TRANS_BACK)
	_purchase_tween.set_ease(Tween.EASE_OUT)
	_purchase_tween.tween_property(self, "scale", Vector2(1.10, 1.10), 0.10)
	_purchase_tween.tween_property(self, "scale", Vector2.ONE, 0.16)

func _ensure_ring() -> void:
	if _ring != null:
		return
	_ring = Line2D.new()
	_ring.name = "FocusRing"
	_ring.closed = true
	_ring.width = 2.4
	_ring.z_index = 3
	_ring.add_point(Vector2(-48.0, -34.0))
	_ring.add_point(Vector2(48.0, -34.0))
	_ring.add_point(Vector2(48.0, 34.0))
	_ring.add_point(Vector2(-48.0, 34.0))
	add_child(_ring)

func _apply_state() -> void:
	if _icon_button == null:
		return
	_state_overlay.visible = false
	_state_label.visible = false
	_state_label.text = ""
	_state_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_icon_button.disabled = false
	_icon_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	_ring.visible = true
	_ring.width = 2.4

	match _state:
		"purchased":
			modulate = Color(1.10, 1.06, 0.94, 1.0)
			_icon_button.modulate = Color(1.10, 1.04, 0.88, 1.0)
			_state_overlay.visible = true
			_state_overlay.color = Color(0.35, 0.22, 0.02, 0.28)
			_state_label.visible = true
			_state_label.text = "Owned"
			_state_label.modulate = Color(1.0, 0.93, 0.72, 1.0)
			_ring.default_color = Color(0.99, 0.90, 0.52, 0.98)
			_ring.width = 3.0
			_icon_button.disabled = true
		"available":
			_state_overlay.visible = true
			_state_overlay.color = Color(0.56, 0.38, 0.06, 0.16)
			_ring.default_color = Color(0.93, 0.80, 0.34, 0.90)
			_ring.width = 2.8
		"unaffordable":
			modulate = Color(0.92, 0.92, 0.92, 1.0)
			_state_overlay.visible = true
			_state_overlay.color = Color(0.12, 0.12, 0.12, 0.28)
			_ring.default_color = Color(0.66, 0.59, 0.78, 0.66)
			_ring.width = 2.2
		"choice_locked":
			modulate = Color(0.78, 0.78, 0.78, LOCKED_ALPHA)
			_state_overlay.visible = true
			_state_overlay.color = Color(0.0, 0.0, 0.0, 0.46)
			_state_label.visible = true
			_state_label.text = "Locked"
			_state_label.modulate = Color(0.95, 0.82, 0.82, 1.0)
			_ring.default_color = Color(0.72, 0.48, 0.48, 0.54)
			_ring.width = 2.0
			_icon_button.disabled = true
		_:
			modulate = Color(0.72, 0.72, 0.72, LOCKED_ALPHA)
			_state_overlay.visible = true
			_state_overlay.color = Color(0.0, 0.0, 0.0, 0.48)
			_state_label.visible = true
			_state_label.text = "Locked"
			_state_label.modulate = Color(0.95, 0.82, 0.82, 1.0)
			_ring.default_color = Color(0.58, 0.52, 0.68, 0.48)
			_ring.width = 2.0

func _on_pressed() -> void:
	purchase_requested.emit(_upgrade_id)

func _on_mouse_entered() -> void:
	_start_hover_feedback()
	tooltip_requested.emit(_upgrade_id, _icon_button.get_screen_position() + Vector2(16.0, 16.0))

func _on_mouse_exited() -> void:
	_stop_hover_feedback()
	tooltip_hidden.emit()

func _start_hover_feedback() -> void:
	if _state == "locked" or _state == "choice_locked":
		return
	if _hover_tween != null and _hover_tween.is_running():
		_hover_tween.kill()
	_hover_tween = create_tween()
	_hover_tween.set_trans(Tween.TRANS_SINE)
	_hover_tween.set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", Vector2(1.04, 1.04), 0.10)

func _stop_hover_feedback() -> void:
	if _hover_tween != null and _hover_tween.is_running():
		_hover_tween.kill()
	var reset_tween: Tween = create_tween()
	reset_tween.set_trans(Tween.TRANS_SINE)
	reset_tween.set_ease(Tween.EASE_OUT)
	reset_tween.tween_property(self, "scale", Vector2.ONE, 0.10)
