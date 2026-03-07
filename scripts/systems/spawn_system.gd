extends Node

@export var npc_scene: PackedScene
@export var npc_container_path: NodePath
@export var game_manager_path: NodePath

@onready var _spawn_timer: Timer = $SpawnTimer

var _npc_container: Node
var _game_manager: GameManager
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_npc_container = get_node_or_null(npc_container_path)
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	if _npc_container == null or _game_manager == null:
		return

	_spawn_timer.wait_time = _game_manager.npc_spawn_interval
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if _npc_container == null or _game_manager == null or npc_scene == null:
		return

	_spawn_timer.wait_time = _game_manager.npc_spawn_interval
	if _npc_container.get_child_count() >= _game_manager.max_npc:
		return

	var npc_instance: NPC = npc_scene.instantiate() as NPC
	if npc_instance == null:
		return

	var view_size: Vector2 = get_viewport().get_visible_rect().size
	npc_instance.global_position = Vector2(
		_rng.randf_range(20.0, max(20.0, view_size.x - 20.0)),
		_rng.randf_range(20.0, max(20.0, view_size.y - 20.0))
	)
	_npc_container.add_child(npc_instance)