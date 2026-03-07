extends Node2D
class_name CursorEntity

signal npc_detected(npc: Node)

@onready var _area: Area2D = $Area2D

func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("npc"):
		npc_detected.emit(body)