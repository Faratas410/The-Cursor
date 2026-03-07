extends Node

signal npc_converted()

@export var game_manager_path: NodePath
@export var feedback_layer_path: NodePath

var _game_manager: GameManager
var _feedback_layer: CanvasLayer

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_feedback_layer = get_node_or_null(feedback_layer_path) as CanvasLayer

func _on_npc_detected(npc: Node) -> void:
	if _game_manager == null:
		return

	var npc_entity: NPC = npc as NPC
	if npc_entity == null:
		return
	if npc_entity.converted:
		return

	npc_entity.converted = true
	_game_manager.add_followers(_game_manager.conversion_value)
	npc_converted.emit()
	_game_manager.npc_converted.emit()
	_spawn_feedback(npc_entity.global_position, _game_manager.conversion_value)
	npc_entity.queue_free()

func _spawn_feedback(world_position: Vector2, amount: int) -> void:
	if _feedback_layer == null:
		return

	var label: Label = Label.new()
	label.text = "+%d" % amount
	label.modulate = Color(1.0, 0.95, 0.6)
	label.position = world_position + Vector2(8.0, -8.0)
	_feedback_layer.add_child(label)

	var tween: Tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0.0, -24.0), 0.35)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.35)
	tween.finished.connect(label.queue_free)