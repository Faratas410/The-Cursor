extends Camera2D
class_name UpgradeMapCamera

signal transform_changed(map_offset: Vector2, zoom_factor: float)

@export var zoom_min: float = 0.7
@export var zoom_max: float = 1.6
@export var zoom_in_factor: float = 0.9
@export var zoom_out_factor: float = 1.1
@export var pan_limit: float = 800.0

var _map_offset: Vector2 = Vector2(0.0, -40.0)
var _zoom_factor: float = 0.82
var _drag_active: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO
var _focus_tween: Tween

func get_map_offset() -> Vector2:
	return _map_offset

func get_zoom_factor() -> float:
	return _zoom_factor

func is_dragging() -> bool:
	return _drag_active

func handle_wheel(button_index: int) -> void:
	if button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom_factor = clampf(_zoom_factor * zoom_in_factor, zoom_min, zoom_max)
	elif button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom_factor = clampf(_zoom_factor * zoom_out_factor, zoom_min, zoom_max)
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
	_map_offset -= mouse_delta
	_map_offset = _clamp_offset(_map_offset)
	_emit_transform_changed()

func end_drag() -> void:
	_drag_active = false

func focus_toward_node(node_position: Vector2, duration: float = 0.18, near_weight: float = 0.30, far_distance: float = 320.0) -> void:
	if _drag_active:
		return
	var center_offset: Vector2 = -node_position * _zoom_factor
	var delta: Vector2 = center_offset - _map_offset
	if delta.length() < 8.0:
		return

	var target_offset: Vector2 = center_offset
	if delta.length() <= far_distance:
		target_offset = _map_offset + (delta * near_weight)
	target_offset = _clamp_offset(target_offset)

	if _focus_tween != null and _focus_tween.is_running():
		_focus_tween.kill()
	_focus_tween = create_tween()
	_focus_tween.set_trans(Tween.TRANS_SINE)
	_focus_tween.set_ease(Tween.EASE_OUT)
	_focus_tween.tween_method(_set_map_offset, _map_offset, target_offset, clampf(duration, 0.12, 0.22))

func _set_map_offset(value: Vector2) -> void:
	_map_offset = _clamp_offset(value)
	_emit_transform_changed()

func _clamp_offset(offset: Vector2) -> Vector2:
	return Vector2(
		clampf(offset.x, -pan_limit, pan_limit),
		clampf(offset.y, -pan_limit, pan_limit)
	)

func _emit_transform_changed() -> void:
	transform_changed.emit(_map_offset, _zoom_factor)
