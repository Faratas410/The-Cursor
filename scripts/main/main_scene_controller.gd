extends Node2D

@onready var _camera: Camera2D = $MainCamera as Camera2D

func _ready() -> void:
	_center_camera_to_viewport()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_center_camera_to_viewport()

func _center_camera_to_viewport() -> void:
	if _camera == null:
		return
	var view_size: Vector2 = get_viewport_rect().size
	_camera.global_position = view_size * 0.5
