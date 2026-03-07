extends Node

@export var npc_scene: PackedScene
@export var prophet_scene: PackedScene
@export var skeptic_scene: PackedScene
@export var npc_container_path: NodePath
@export var game_manager_path: NodePath

@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _prophet_timer: Timer = $ProphetTimer
@onready var _event_timer: Timer = $EventTimer

var _npc_container: Node
var _game_manager: GameManager
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_npc_container = get_node_or_null(npc_container_path)
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	if _npc_container == null or _game_manager == null:
		return

	_spawn_timer.wait_time = _game_manager.get_effective_npc_spawn_interval()
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_spawn_timer.start()

	_prophet_timer.wait_time = 30.0
	_prophet_timer.timeout.connect(_on_prophet_timer_timeout)
	_prophet_timer.start()

	_schedule_next_event()
	_event_timer.timeout.connect(_on_event_timer_timeout)
	_event_timer.start()

func _on_spawn_timer_timeout() -> void:
	if _npc_container == null or _game_manager == null or npc_scene == null:
		return
	if _game_manager.final_sequence_active or _game_manager.final_gathering_active or not _game_manager.is_gameplay_phase():
		return

	_update_spawn_scaling()
	var devotion_mode: bool = _game_manager.global_devotion_active
	if devotion_mode:
		_spawn_timer.wait_time = 0.3
	else:
		_spawn_timer.wait_time = _game_manager.get_effective_npc_spawn_interval()

	var wild_count: int = get_tree().get_nodes_in_group("wild_npc").size()
	var available_slots: int = _game_manager.max_npc - wild_count
	if available_slots <= 0:
		_try_spawn_skeptic()
		return

	var cluster_min: int = max(1, _game_manager.get_effective_spawn_cluster_min())
	var cluster_max: int = max(cluster_min, _game_manager.get_effective_spawn_cluster_max())
	if devotion_mode:
		cluster_min = max(cluster_min, 10)
		cluster_max = max(cluster_max, 20)

	var cluster_size: int = _rng.randi_range(cluster_min, cluster_max)
	var spawn_count: int = min(cluster_size, available_slots)
	var spawned: Array[NPC] = _spawn_npc_cluster(spawn_count, _random_world_position(), 48.0, false)
	if devotion_mode:
		for npc_entity: NPC in spawned:
			npc_entity.set_forced_attracted(6.0)

	_try_spawn_skeptic()

func _on_prophet_timer_timeout() -> void:
	if _npc_container == null or _game_manager == null or prophet_scene == null:
		return
	if _game_manager.final_sequence_active or _game_manager.final_gathering_active or not _game_manager.is_gameplay_phase():
		return
	if _game_manager.followers < 1000:
		return

	var prophet_count: int = get_tree().get_nodes_in_group("prophet").size()
	if prophet_count >= 3:
		return

	var prophet: Prophet = prophet_scene.instantiate() as Prophet
	if prophet == null:
		return

	prophet.global_position = _random_world_position()
	_npc_container.add_child(prophet)

func _on_event_timer_timeout() -> void:
	if _npc_container == null or _game_manager == null:
		return
	if _game_manager.final_sequence_active or _game_manager.final_gathering_active or not _game_manager.is_gameplay_phase():
		return

	var roll: int = _rng.randi_range(0, 2)
	match roll:
		0:
			_trigger_pilgrimage_event()
		1:
			_trigger_resistance_event()
		2:
			_trigger_miracle_event()
		_:
			pass

	_schedule_next_event()
	_event_timer.start()

func _trigger_pilgrimage_event() -> void:
	if npc_scene == null:
		return
	var center: Vector2 = _random_world_position()
	var count: int = _rng.randi_range(12, 18)
	var spawned: Array[NPC] = _spawn_npc_cluster(count, center, 90.0, true)
	for npc_entity: NPC in spawned:
		npc_entity.set_forced_attracted(8.0)

func _trigger_resistance_event() -> void:
	if skeptic_scene == null:
		return
	for i: int in range(3):
		_spawn_skeptic_with_lifetime(12.0)

func _trigger_miracle_event() -> void:
	_game_manager.start_miracle(10.0, 1)

func _schedule_next_event() -> void:
	_event_timer.wait_time = _rng.randf_range(20.0, 40.0)

func _spawn_npc_cluster(count: int, center: Vector2, radius: float, clamp_inside_view: bool) -> Array[NPC]:
	var spawned: Array[NPC] = []
	if npc_scene == null:
		return spawned

	var view_size: Vector2 = get_viewport().get_visible_rect().size
	for i: int in range(count):
		var npc_instance: NPC = npc_scene.instantiate() as NPC
		if npc_instance == null:
			continue
		npc_instance.speed *= _game_manager.get_npc_speed_multiplier()

		var angle: float = _rng.randf_range(0.0, TAU)
		var distance: float = _rng.randf_range(0.0, radius)
		var offset: Vector2 = Vector2.RIGHT.rotated(angle) * distance
		var spawn_pos: Vector2 = center + offset
		if clamp_inside_view:
			spawn_pos.x = clamp(spawn_pos.x, 12.0, view_size.x - 12.0)
			spawn_pos.y = clamp(spawn_pos.y, 12.0, view_size.y - 12.0)
		npc_instance.global_position = spawn_pos
		_npc_container.add_child(npc_instance)
		spawned.append(npc_instance)

	return spawned

func _spawn_skeptic_with_lifetime(lifetime: float) -> void:
	if skeptic_scene == null:
		return
	var skeptic: Skeptic = skeptic_scene.instantiate() as Skeptic
	if skeptic == null:
		return

	skeptic.global_position = _random_world_position()
	_npc_container.add_child(skeptic)
	if lifetime > 0.0:
		var timer: SceneTreeTimer = get_tree().create_timer(lifetime)
		timer.timeout.connect(skeptic.queue_free)

func _try_spawn_skeptic() -> void:
	if _game_manager.followers < 5000:
		return
	if skeptic_scene == null:
		return

	var skeptic_count: int = get_tree().get_nodes_in_group("skeptic").size()
	if skeptic_count >= 8:
		return
	if _rng.randf() > 0.08:
		return

	_spawn_skeptic_with_lifetime(0.0)

func _update_spawn_scaling() -> void:
	var follower_count: int = _game_manager.followers
	if follower_count < 100:
		_game_manager.max_npc = 20
	elif follower_count < 1000:
		_game_manager.max_npc = 40
	elif follower_count < 10000:
		_game_manager.max_npc = 70
	elif follower_count < 100000:
		_game_manager.max_npc = 120
	else:
		_game_manager.max_npc = 200

	if _game_manager.global_devotion_active:
		_game_manager.max_npc = max(_game_manager.max_npc, 260)

func _random_world_position() -> Vector2:
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	if _game_manager != null and _game_manager.has_upgrade("pilgrimage"):
		var center: Vector2 = view_size * 0.5
		var radius_x: float = max(40.0, view_size.x * 0.25)
		var radius_y: float = max(40.0, view_size.y * 0.25)
		return Vector2(
			clamp(center.x + _rng.randf_range(-radius_x, radius_x), 40.0, max(40.0, view_size.x - 40.0)),
			clamp(center.y + _rng.randf_range(-radius_y, radius_y), 40.0, max(40.0, view_size.y - 40.0))
		)
	return Vector2(
		_rng.randf_range(40.0, max(40.0, view_size.x - 40.0)),
		_rng.randf_range(40.0, max(40.0, view_size.y - 40.0))
	)