extends Camera2D
class_name UpgradeMapCamera

signal transform_changed(pan_position: Vector2, zoom_factor: float)

@export var zoom_min: float = 0.7
@export var zoom_max: float = 1.6
@export var zoom_in_factor: float = 0.9
@export var zoom_out_factor: float = 1.1
@export var pan_limit: float = 800.0

var _pan_position: Vector2 = Vector2(0.0, -40.0)
var _zoom_factor: float = 0.82
var _drag_active: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO
var _focus_tween: Tween

func _ready() -> void:
	enabled = false
	_apply_camera_transform()

func get_pan_position() -> Vector2:
	return _pan_position

func get_zoom_factor() -> float:
	return _zoom_factor

func is_dragging() -> bool:
	return _drag_active

func handle_wheel(button_index: int) -> void:
	# Inverted as requested: wheel up zooms out, wheel down zooms in.
	if button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom_factor = clampf(_zoom_factor * zoom_out_factor, zoom_min, zoom_max)
	elif button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom_factor = clampf(_zoom_factor * zoom_in_factor, zoom_min, zoom_max)
	_emit_transform_changed()

func begin_drag(mouse_position: Vector2) -> void:
	_drag_active = true
	_last_mouse_position = mouse_position
	if _focus_tween != null and _focus_tween.is_running():
		_focus_tween.kill()

func update_drag(mouse_position: Vector2) -> void:
	if not _drag_active:
		return
	var mouse_delta: Vector2 = mouse_position - _last_mouse_position
	_last_mouse_position = mouse_position
	_pan_position -= mouse_delta * _zoom_factor
	_pan_position = _clamp_pan_position(_pan_position)
	_emit_transform_changed()

func end_drag() -> void:
	_drag_active = false

func focus_toward_node(node_position: Vector2, duration: float = 0.18, near_weight: float = 0.30, far_distance: float = 320.0) -> void:
	if _drag_active:
		return
	var delta: Vector2 = node_position - _pan_position
	if delta.length() < 8.0:
		return

	var target_pan_position: Vector2 = node_position
	if delta.length() <= far_distance:
		target_pan_position = _pan_position + (delta * near_weight)
	target_pan_position = _clamp_pan_position(target_pan_position)

	if _focus_tween != null and _focus_tween.is_running():
		_focus_tween.kill()
	_focus_tween = create_tween()
	_focus_tween.set_trans(Tween.TRANS_SINE)
	_focus_tween.set_ease(Tween.EASE_OUT)
	_focus_tween.tween_method(_set_pan_position, _pan_position, target_pan_position, clampf(duration, 0.12, 0.22))

func _set_pan_position(value: Vector2) -> void:
	_pan_position = _clamp_pan_position(value)
	_emit_transform_changed()

func _clamp_pan_position(pan_position_value: Vector2) -> Vector2:
	return Vector2(
		clampf(pan_position_value.x, -pan_limit, pan_limit),
		clampf(pan_position_value.y, -pan_limit, pan_limit)
	)

func _apply_camera_transform() -> void:
	position = _pan_position
	zoom = Vector2(_zoom_factor, _zoom_factor)

func _emit_transform_changed() -> void:
	_apply_camera_transform()
	transform_changed.emit(_pan_position, _zoom_factor)
