extends Node

@warning_ignore("unused_signal")
signal npc_converted()

@export var game_manager_path: NodePath
@export var feedback_layer_path: NodePath

var _game_manager: GameManager
var _feedback_layer: CanvasLayer
var _recent_conversion_times: Array[float] = []
var _last_mass_prayer_time: float = -10.0
var _prophet_last_convert_msec: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

const FLOATING_TEXT_SCENE: PackedScene = preload("res://scenes/ui/floating_text.tscn")

func _ready() -> void:
	_rng.randomize()
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_feedback_layer = get_node_or_null(feedback_layer_path) as CanvasLayer

func _process(_delta: float) -> void:
	if _game_manager == null:
		return
	if _game_manager.final_sequence_active or not _game_manager.is_gameplay_phase():
		return
	_process_prophet_conversion()

func _on_npc_detected(npc: Node) -> void:
	if _game_manager == null:
		return
	if _game_manager.final_sequence_active or not _game_manager.is_gameplay_phase():
		return

	var npc_entity: NPC = npc as NPC
	if npc_entity == null or npc_entity.converted:
		return

	var targets: Array[NPC] = _collect_conversion_targets(npc_entity)
	var converted_count: int = 0
	for target: NPC in targets:
		if _convert_npc(target, true):
			converted_count += 1

	if converted_count > 0:
		_register_mass_prayer_progress(converted_count)
		play_convert_sound()

func _collect_conversion_targets(origin: NPC) -> Array[NPC]:
	var converted_targets: Array[NPC] = []
	if origin == null or origin.converted:
		return converted_targets

	if _game_manager.mass_conversion_radius <= 0.0:
		converted_targets.append(origin)
		return converted_targets

	var search_root: Node = origin.get_parent()
	if search_root == null:
		converted_targets.append(origin)
		return converted_targets

	var queue: Array[NPC] = [origin]
	var seen: Dictionary = {}

	while queue.size() > 0:
		var current: NPC = queue.pop_front() as NPC
		if current == null:
			continue
		var id: int = current.get_instance_id()
		if seen.has(id) or current.converted:
			continue

		seen[id] = true
		converted_targets.append(current)

		for child: Node in search_root.get_children():
			var other: NPC = child as NPC
			if other == null or other.converted:
				continue
			if seen.has(other.get_instance_id()):
				continue
			if current.global_position.distance_to(other.global_position) <= _game_manager.mass_conversion_radius:
				queue.append(other)

	return converted_targets

func _convert_npc(npc_entity: NPC, apply_resistance: bool) -> bool:
	if npc_entity == null or npc_entity.converted:
		return false

	if apply_resistance and _is_conversion_blocked_by_skeptic(npc_entity.global_position):
		_spawn_feedback(npc_entity.global_position, 0, "Doubt")
		return false

	npc_entity.apply_converted_visual()
	var gained_followers: int = _game_manager.get_current_conversion_value()
	if gained_followers <= 0:
		npc_entity.queue_free()
		return false

	_game_manager.add_followers(gained_followers)
	var faith_per_conversion: float = _game_manager.get_faith_per_conversion()
	if faith_per_conversion > 0.0:
		_game_manager.add_faith(faith_per_conversion)
	npc_converted.emit()
	_game_manager.npc_converted.emit()
	_spawn_feedback(npc_entity.global_position, gained_followers, "")

	if _can_add_active_follower():
		var slot: Dictionary = _generate_follow_slot()
		npc_entity.become_follower(float(slot["angle"]), float(slot["distance"]))
	else:
		npc_entity.queue_free()

	return true

func _is_conversion_blocked_by_skeptic(position: Vector2) -> bool:
	var skeptics: Array = get_tree().get_nodes_in_group("skeptic")
	if skeptics.is_empty():
		return false

	var nearby_count: int = 0
	for node: Node in skeptics:
		var skeptic: Skeptic = node as Skeptic
		if skeptic == null:
			continue
		if skeptic.global_position.distance_to(position) <= skeptic.influence_radius:
			nearby_count += 1

	if nearby_count <= 0:
		return false

	var chance_to_convert: float = max(0.15, 1.0 - (0.35 * float(nearby_count)))
	return _rng.randf() > chance_to_convert

func _can_add_active_follower() -> bool:
	var active_count: int = get_tree().get_nodes_in_group("followers").size()
	return active_count < _game_manager.max_followers_near_cursor

func _generate_follow_slot() -> Dictionary:
	var follower_count: int = get_tree().get_nodes_in_group("followers").size()
	var ring_index: int = int(float(follower_count) / 10.0)
	var ring_distance: float = 46.0 + (float(ring_index) * 18.0)
	var angle: float = _rng.randf() * TAU
	return {"angle": angle, "distance": ring_distance}

func _spawn_feedback(world_position: Vector2, amount: int, override_text: String) -> void:
	if _feedback_layer == null or FLOATING_TEXT_SCENE == null:
		return

	var floating_text: FloatingText = FLOATING_TEXT_SCENE.instantiate() as FloatingText
	if floating_text == null:
		return
	_feedback_layer.add_child(floating_text)

	var text: String = override_text
	if text.is_empty():
		text = "+%d Follower" % amount
	floating_text.show_text(world_position, text)

func _register_mass_prayer_progress(converted_count: int) -> void:
	var now_sec: float = float(Time.get_ticks_msec()) / 1000.0
	for i: int in range(converted_count):
		_recent_conversion_times.append(now_sec)

	while _recent_conversion_times.size() > 0 and now_sec - _recent_conversion_times[0] > 2.0:
		_recent_conversion_times.pop_front()

	if _recent_conversion_times.size() >= 5 and now_sec - _last_mass_prayer_time >= 2.0:
		_last_mass_prayer_time = now_sec
		_trigger_mass_prayer()

func _trigger_mass_prayer() -> void:
	get_tree().call_group("followers", "trigger_worship_now")
	var cursor: CursorEntity = get_tree().get_first_node_in_group("cursor") as CursorEntity
	if cursor != null:
		_game_manager.divine_pulse_requested.emit(cursor.global_position)

func _process_prophet_conversion() -> void:
	if _game_manager == null or _game_manager.followers < 1000:
		return

	var now_msec: int = Time.get_ticks_msec()
	var prophets: Array = get_tree().get_nodes_in_group("prophet")
	for node: Node in prophets:
		var prophet: Prophet = node as Prophet
		if prophet == null:
			continue

		var prophet_id: int = prophet.get_instance_id()
		var last_msec: int = int(_prophet_last_convert_msec.get(prophet_id, 0))
		if now_msec - last_msec < 2000:
			continue

		var target: NPC = _find_nearest_wild_npc(prophet.global_position, 100.0)
		if target == null:
			continue

		_prophet_last_convert_msec[prophet_id] = now_msec
		if _convert_npc(target, false):
			play_convert_sound()

func _find_nearest_wild_npc(origin: Vector2, radius: float) -> NPC:
	var closest: NPC
	var best_distance: float = radius
	var wild_npcs: Array = get_tree().get_nodes_in_group("wild_npc")
	for node: Node in wild_npcs:
		var npc_entity: NPC = node as NPC
		if npc_entity == null or npc_entity.converted:
			continue
		var distance: float = origin.distance_to(npc_entity.global_position)
		if distance <= best_distance:
			best_distance = distance
			closest = npc_entity
	return closest

func play_convert_sound() -> void:
	pass







