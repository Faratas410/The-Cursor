extends Node2D
class_name CursorEntity

signal npc_detected(npc: Node)

@export var game_manager_path: NodePath
@export var attraction_radius: float = 60.0

@onready var _area: Area2D = $Area2D

var _game_manager: GameManager
var _last_position: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.UP

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_last_position = global_position
	_area.body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if _game_manager == null:
		return

	if not _game_manager.cursor_locked:
		global_position = get_global_mouse_position()

	var delta_pos: Vector2 = global_position - _last_position
	if delta_pos.length() > 0.001:
		movement_direction = delta_pos.normalized()
	_last_position = global_position

	attraction_radius = _game_manager.get_effective_attraction_radius()

func _on_body_entered(body: Node) -> void:
	if _game_manager != null and _game_manager.final_sequence_active:
		return
	if body.is_in_group("npc"):
		npc_detected.emit(body)