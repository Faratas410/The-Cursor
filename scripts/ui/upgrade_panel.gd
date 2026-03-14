extends Control

@warning_ignore("unused_signal")
signal upgrade_purchased(upgrade: Dictionary)

const UPGRADE_MAP_SCENE: PackedScene = preload("res://scenes/ui/upgrade_map.tscn")

@export var game_manager_path: NodePath

var _upgrade_map: Control

func _ready() -> void:
	_create_upgrade_map()

func _create_upgrade_map() -> void:
	if _upgrade_map != null:
		_upgrade_map.queue_free()

	_upgrade_map = UPGRADE_MAP_SCENE.instantiate() as Control
	if _upgrade_map == null:
		return

	add_child(_upgrade_map)
	_upgrade_map.set_anchors_preset(Control.PRESET_FULL_RECT)
	_upgrade_map.offset_left = 0.0
	_upgrade_map.offset_top = 0.0
	_upgrade_map.offset_right = 0.0
	_upgrade_map.offset_bottom = 0.0
	if _upgrade_map.has_method("set_game_manager_path"):
		_upgrade_map.call("set_game_manager_path", game_manager_path)
	if _upgrade_map.has_signal("upgrade_purchased"):
		_upgrade_map.connect("upgrade_purchased", Callable(self, "_on_upgrade_purchased"))

func _on_upgrade_purchased(upgrade: Dictionary) -> void:
	upgrade_purchased.emit(upgrade)
