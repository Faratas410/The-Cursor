extends Node
class_name GameManager

@warning_ignore("unused_signal")
signal npc_converted()
@warning_ignore("unused_signal")
signal upgrade_purchased(upgrade: Dictionary)
@warning_ignore("unused_signal")
signal dimension_changed(level: int)
@warning_ignore("unused_signal")
signal divinity_level_changed(level: int)
@warning_ignore("unused_signal")
signal divine_pulse_requested(position: Vector2)
@warning_ignore("unused_signal")
signal world_message_requested(message: String)
@warning_ignore("unused_signal")
signal world_transformed()
@warning_ignore("unused_signal")
signal final_sequence_started()
@warning_ignore("unused_signal")
signal final_sequence_finished()
@warning_ignore("unused_signal")
signal state_changed()

var followers: int = 0
var faith: float = 0.0

var conversion_value: int = 1
var faith_per_follower: float = 0.01

var npc_spawn_interval: float = 1.5
var max_npc: int = 50

var current_dimension: int = 0
var divinity_level: int = 0
var passive_followers_per_second: float = 0.0

var attraction_radius: float = 60.0
var attraction_radius_bonus: float = 0.0
var mass_conversion_radius: float = 0.0
var max_followers_near_cursor: int = 30
var spawn_cluster_min: int = 3
var spawn_cluster_max: int = 6
var spawn_cluster_bonus: int = 0

var cult_power: int = 0

var global_devotion_active: bool = false
var world_transformed_active: bool = false
var final_gathering_active: bool = false
var final_sequence_active: bool = false
var cursor_locked: bool = false
var ending_complete: bool = false

var _npc_pause_until_msec: int = 0
var _miracle_until_msec: int = 0
var _miracle_conversion_bonus: int = 0
var _session_start_msec: int = 0

func _ready() -> void:
	_session_start_msec = Time.get_ticks_msec()

func add_followers(amount: int) -> void:
	if amount <= 0:
		return
	if final_sequence_active:
		return
	followers += amount
	state_changed.emit()

func add_faith(amount: float) -> void:
	if amount <= 0.0:
		return
	if final_sequence_active:
		return
	faith += amount
	state_changed.emit()

func spend_faith(cost: float) -> bool:
	if final_sequence_active:
		return false
	if faith < cost:
		return false
	faith -= cost
	state_changed.emit()
	return true

func apply_upgrade(effect_type: StringName, effect_value: float) -> void:
	if final_sequence_active:
		return
	match effect_type:
		&"conversion_value":
			conversion_value += int(effect_value)
		&"passive_followers":
			passive_followers_per_second += effect_value
		&"spawn_interval":
			npc_spawn_interval = max(0.2, npc_spawn_interval - effect_value)
		&"attraction_radius":
			attraction_radius = max(attraction_radius, effect_value)
		&"mass_conversion":
			mass_conversion_radius = max(mass_conversion_radius, effect_value)
		_:
			return
	state_changed.emit()

func set_npc_pause(duration_seconds: float) -> void:
	_npc_pause_until_msec = Time.get_ticks_msec() + int(duration_seconds * 1000.0)

func are_npcs_paused() -> bool:
	if final_sequence_active:
		return true
	return Time.get_ticks_msec() < _npc_pause_until_msec

func start_miracle(duration_seconds: float, conversion_bonus: int) -> void:
	if final_sequence_active:
		return
	_miracle_until_msec = Time.get_ticks_msec() + int(duration_seconds * 1000.0)
	_miracle_conversion_bonus = max(0, conversion_bonus)
	state_changed.emit()

func get_current_conversion_value() -> int:
	if final_sequence_active:
		return 0
	var miracle_bonus: int = 0
	if Time.get_ticks_msec() < _miracle_until_msec:
		miracle_bonus = _miracle_conversion_bonus
	return conversion_value + miracle_bonus

func get_effective_attraction_radius() -> float:
	return attraction_radius + attraction_radius_bonus

func get_effective_spawn_cluster_min() -> int:
	return spawn_cluster_min + spawn_cluster_bonus

func get_effective_spawn_cluster_max() -> int:
	return spawn_cluster_max + spawn_cluster_bonus

func activate_global_devotion() -> void:
	if global_devotion_active:
		return
	global_devotion_active = true
	state_changed.emit()

func activate_world_transformation() -> void:
	if world_transformed_active:
		return
	world_transformed_active = true
	world_transformed.emit()
	state_changed.emit()

func activate_final_gathering() -> void:
	if final_gathering_active:
		return
	final_gathering_active = true
	state_changed.emit()

func start_final_sequence() -> void:
	if final_sequence_active:
		return
	final_sequence_active = true
	cursor_locked = false
	set_npc_pause(9999.0)
	final_sequence_started.emit()
	state_changed.emit()

func lock_cursor() -> void:
	if cursor_locked:
		return
	cursor_locked = true
	state_changed.emit()

func finish_final_sequence() -> void:
	if ending_complete:
		return
	ending_complete = true
	final_sequence_finished.emit()
	state_changed.emit()

func get_playtime_seconds() -> int:
	var elapsed_msec: int = Time.get_ticks_msec() - _session_start_msec
	return max(0, elapsed_msec // 1000)

