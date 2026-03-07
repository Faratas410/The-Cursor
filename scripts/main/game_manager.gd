extends Node
class_name GameManager

enum RunPhase {
	GAMEPLAY,
	UPGRADE
}

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
@warning_ignore("unused_signal")
signal run_started()
@warning_ignore("unused_signal")
signal run_ended()
@warning_ignore("unused_signal")
signal upgrade_phase_opened()
@warning_ignore("unused_signal")
signal upgrade_phase_closed()

const UPGRADE_TREE_DEFS: Array[Dictionary] = [
	{
		"id": "awakening", "name": "Awakening", "description": "The first spark of devotion.",
		"cost": 0.0, "branch": "root", "tier": 0, "dependencies": PackedStringArray(),
		"purchased": true, "effect_type": "conversion_speed_mult", "effect_value": 1.10,
		"visible_by_default": true
	},
	{
		"id": "magnetic_presence", "name": "Magnetic Presence", "description": "Unlocked magnetism around the cursor.",
		"cost": 30.0, "branch": "conversion", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"purchased": false, "effect_type": "npc_magnetism_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "faster_conversion", "name": "Faster Conversion", "description": "Convert with stronger force.",
		"cost": 50.0, "branch": "conversion", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"purchased": false, "effect_type": "conversion_speed_mult_add", "effect_value": 0.25,
		"visible_by_default": true
	},
	{
		"id": "conversion_pulse", "name": "Conversion Pulse", "description": "Periodic pulse conversion unlock.",
		"cost": 80.0, "branch": "conversion", "tier": 2, "dependencies": PackedStringArray(["magnetic_presence"]),
		"purchased": false, "effect_type": "periodic_auto_convert_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "conversion_chain", "name": "Conversion Chain", "description": "Chance to chain nearby converts.",
		"cost": 120.0, "branch": "conversion", "tier": 2, "dependencies": PackedStringArray(["faster_conversion"]),
		"purchased": false, "effect_type": "chain_conversion_chance", "effect_value": 0.20,
		"visible_by_default": true
	},
	{
		"id": "mass_conversion", "name": "Mass Conversion", "description": "Increase conversion radius.",
		"cost": 200.0, "branch": "conversion", "tier": 3, "dependencies": PackedStringArray(["conversion_chain"]),
		"purchased": false, "effect_type": "conversion_radius_mult_add", "effect_value": 0.40,
		"visible_by_default": true
	},
	{
		"id": "faith_amplifier", "name": "Faith Amplifier", "description": "Increase all faith gain.",
		"cost": 40.0, "branch": "faith_flow", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"purchased": false, "effect_type": "faith_gain_mult_add", "effect_value": 0.30,
		"visible_by_default": true
	},
	{
		"id": "cult_donations", "name": "Cult Donations", "description": "Passive faith generation per second.",
		"cost": 70.0, "branch": "faith_flow", "tier": 2, "dependencies": PackedStringArray(["faith_amplifier"]),
		"purchased": false, "effect_type": "passive_faith_per_second_add", "effect_value": 0.5,
		"visible_by_default": true
	},
	{
		"id": "sacred_economy", "name": "Sacred Economy", "description": "Passive follower generation.",
		"cost": 120.0, "branch": "faith_flow", "tier": 3, "dependencies": PackedStringArray(["cult_donations"]),
		"purchased": false, "effect_type": "passive_followers_per_second_add", "effect_value": 1.0,
		"visible_by_default": true
	},
	{
		"id": "divine_harvest", "name": "Divine Harvest", "description": "Gain bonus faith per conversion.",
		"cost": 180.0, "branch": "faith_flow", "tier": 3, "dependencies": PackedStringArray(["faith_amplifier"]),
		"purchased": false, "effect_type": "faith_per_conversion_add", "effect_value": 2.0,
		"visible_by_default": true
	},
	{
		"id": "overflow_faith", "name": "Overflow Faith", "description": "Overflow followers can become faith.",
		"cost": 250.0, "branch": "faith_flow", "tier": 4, "dependencies": PackedStringArray(["divine_harvest"]),
		"purchased": false, "effect_type": "overflow_followers_to_faith_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "curious_crowds", "name": "Curious Crowds", "description": "Increase NPC spawn rate.",
		"cost": 50.0, "branch": "world_control", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"purchased": false, "effect_type": "npc_spawn_rate_mult_add", "effect_value": 0.25,
		"visible_by_default": true
	},
	{
		"id": "pilgrimage", "name": "Pilgrimage", "description": "Crowds drift more toward center.",
		"cost": 80.0, "branch": "world_control", "tier": 2, "dependencies": PackedStringArray(["curious_crowds"]),
		"purchased": false, "effect_type": "npc_spawn_bias_to_center_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "wandering_faith", "name": "Wandering Faith", "description": "NPC movement slows for readability.",
		"cost": 120.0, "branch": "world_control", "tier": 2, "dependencies": PackedStringArray(["curious_crowds"]),
		"purchased": false, "effect_type": "npc_speed_mult", "effect_value": 0.85,
		"visible_by_default": true
	},
	{
		"id": "sacred_ground", "name": "Sacred Ground", "description": "Unlock larger spawn clustering.",
		"cost": 200.0, "branch": "world_control", "tier": 3, "dependencies": PackedStringArray(["pilgrimage"]),
		"purchased": false, "effect_type": "spawn_cluster_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "cult_leaders", "name": "Cult Leaders", "description": "Unlock mini-prophet effects.",
		"cost": 150.0, "branch": "cult_power", "tier": 1, "dependencies": PackedStringArray(["mass_conversion", "sacred_economy"]),
		"purchased": false, "effect_type": "mini_prophet_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "prophecy", "name": "Prophecy", "description": "Unlock prophet spawn boosts.",
		"cost": 200.0, "branch": "cult_power", "tier": 2, "dependencies": PackedStringArray(["cult_leaders"]),
		"purchased": false, "effect_type": "prophet_spawn_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "skeptic_hunt", "name": "Skeptic Hunt", "description": "Unlock anti-skeptic bonuses.",
		"cost": 250.0, "branch": "cult_power", "tier": 2, "dependencies": PackedStringArray(["cult_leaders"]),
		"purchased": false, "effect_type": "skeptic_bonus_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "divine_aura", "name": "Divine Aura", "description": "Unlock aura-based conversions.",
		"cost": 300.0, "branch": "late_game", "tier": 1, "dependencies": PackedStringArray(["prophecy"]),
		"purchased": false, "effect_type": "cursor_aura_convert_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "cult_expansion", "name": "Cult Expansion", "description": "Massively scale spawning.",
		"cost": 400.0, "branch": "late_game", "tier": 2, "dependencies": PackedStringArray(["sacred_ground", "divine_aura"]),
		"purchased": false, "effect_type": "npc_spawn_multiplier_big", "effect_value": 2.0,
		"visible_by_default": true
	},
	{
		"id": "worship_wave", "name": "Worship Wave", "description": "Run start mass conversion unlock.",
		"cost": 500.0, "branch": "late_game", "tier": 3, "dependencies": PackedStringArray(["cult_expansion"]),
		"purchased": false, "effect_type": "run_start_mass_conversion_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "they_can_see_you", "name": "They Can See You", "description": "Final world shift unlock.",
		"cost": 1000.0, "branch": "late_game", "tier": 4, "dependencies": PackedStringArray(["worship_wave"]),
		"purchased": false, "effect_type": "final_world_shift_unlock", "effect_value": true,
		"visible_by_default": true
	}
]

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

var current_phase: int = RunPhase.GAMEPLAY
var run_duration_seconds: float = 15.0
var run_time_remaining: float = 15.0
var run_followers_gained: int = 0
var run_faith_gained: float = 0.0

var _npc_pause_until_msec: int = 0
var _miracle_until_msec: int = 0
var _miracle_conversion_bonus: int = 0
var _session_start_msec: int = 0

var _upgrade_by_id: Dictionary = {}
var _conversion_speed_mult: float = 1.0
var _faith_gain_mult: float = 1.0
var _passive_faith_per_second: float = 0.0
var _faith_per_conversion_bonus: float = 0.0
var _npc_spawn_rate_mult: float = 1.0
var _npc_speed_mult: float = 1.0
var _conversion_radius_mult: float = 1.0
var _spawn_cluster_multiplier: float = 1.0
var _chain_conversion_chance: float = 0.0

func _ready() -> void:
	_session_start_msec = Time.get_ticks_msec()
	set_process(true)
	_initialize_upgrade_tree()
	start_run()

func _process(delta: float) -> void:
	if final_sequence_active:
		return
	if current_phase != RunPhase.GAMEPLAY:
		return

	run_time_remaining = max(0.0, run_time_remaining - delta)
	if run_time_remaining <= 0.0:
		end_run()
	else:
		state_changed.emit()

func _initialize_upgrade_tree() -> void:
	_upgrade_by_id.clear()
	for definition: Dictionary in UPGRADE_TREE_DEFS:
		var entry: Dictionary = definition.duplicate(true)
		var id: String = String(entry.get("id", ""))
		if id.is_empty():
			continue
		entry["purchased"] = bool(entry.get("purchased", false))
		_upgrade_by_id[id] = entry

	if has_upgrade("awakening"):
		_apply_upgrade_effect("conversion_speed_mult", 1.10)
		if conversion_value == 1:
			conversion_value = max(1, int(round(float(conversion_value) * _conversion_speed_mult)))

func start_run() -> void:
	if final_sequence_active:
		return
	current_phase = RunPhase.GAMEPLAY
	run_time_remaining = run_duration_seconds
	run_followers_gained = 0
	run_faith_gained = 0.0
	if has_upgrade("worship_wave"):
		mass_conversion_radius = max(mass_conversion_radius, 52.0)
	run_started.emit()
	state_changed.emit()

func end_run() -> void:
	if final_sequence_active:
		return
	if current_phase == RunPhase.UPGRADE:
		return

	current_phase = RunPhase.UPGRADE
	run_time_remaining = 0.0
	run_ended.emit()
	upgrade_phase_opened.emit()
	state_changed.emit()

func continue_from_upgrade() -> void:
	if final_sequence_active:
		return
	if current_phase != RunPhase.UPGRADE:
		return

	upgrade_phase_closed.emit()
	start_run()

func is_gameplay_phase() -> bool:
	if final_sequence_active:
		return false
	return current_phase == RunPhase.GAMEPLAY

func is_upgrade_phase() -> bool:
	if final_sequence_active:
		return false
	return current_phase == RunPhase.UPGRADE

func add_followers(amount: int) -> void:
	if amount <= 0:
		return
	if final_sequence_active:
		return
	followers += amount
	if current_phase == RunPhase.GAMEPLAY:
		run_followers_gained += amount
	if has_upgrade("overflow_faith") and max_npc > 0 and followers > 1000000:
		add_faith(float(amount) * 0.03)
	state_changed.emit()

func add_faith(amount: float) -> void:
	if amount <= 0.0:
		return
	if final_sequence_active:
		return
	faith += amount
	if current_phase == RunPhase.GAMEPLAY:
		run_faith_gained += amount
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

func get_upgrade_definitions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for definition: Dictionary in UPGRADE_TREE_DEFS:
		var id: String = String(definition.get("id", ""))
		if id.is_empty() or not _upgrade_by_id.has(id):
			continue
		var entry: Dictionary = _upgrade_by_id[id].duplicate(true)
		entry["dependencies_met"] = are_dependencies_met(id)
		entry["can_purchase"] = can_purchase_upgrade(id)
		result.append(entry)
	return result

func has_upgrade(id: String) -> bool:
	if not _upgrade_by_id.has(id):
		return false
	return bool(_upgrade_by_id[id].get("purchased", false))

func are_dependencies_met(id: String) -> bool:
	if not _upgrade_by_id.has(id):
		return false
	var dependencies: PackedStringArray = _upgrade_by_id[id].get("dependencies", PackedStringArray()) as PackedStringArray
	for dependency_id: String in dependencies:
		if not has_upgrade(dependency_id):
			return false
	return true

func can_purchase_upgrade(id: String) -> bool:
	if final_sequence_active:
		return false
	if not is_upgrade_phase():
		return false
	if not _upgrade_by_id.has(id):
		return false
	if has_upgrade(id):
		return false
	if not are_dependencies_met(id):
		return false
	var cost: float = float(_upgrade_by_id[id].get("cost", 0.0))
	return faith >= cost

func purchase_upgrade(id: String) -> bool:
	if not can_purchase_upgrade(id):
		return false

	var data: Dictionary = _upgrade_by_id[id]
	var cost: float = float(data.get("cost", 0.0))
	if not spend_faith(cost):
		return false

	data["purchased"] = true
	_upgrade_by_id[id] = data

	var effect_type: String = String(data.get("effect_type", ""))
	var effect_value: Variant = data.get("effect_value", null)
	_apply_upgrade_effect(effect_type, effect_value)

	var payload: Dictionary = {
		"id": id,
		"name": String(data.get("name", id)),
		"cost": cost,
		"effect_type": effect_type,
		"effect_value": effect_value
	}
	upgrade_purchased.emit(payload)
	state_changed.emit()
	return true

func get_upgrade_display_state(id: String) -> String:
	if not _upgrade_by_id.has(id):
		return "locked"
	if has_upgrade(id):
		return "purchased"
	if not are_dependencies_met(id):
		return "locked"
	if can_purchase_upgrade(id):
		return "available"
	return "unaffordable"

func get_resolved_stat(stat_name: String) -> Variant:
	match stat_name:
		"conversion_speed_mult":
			return _conversion_speed_mult
		"faith_gain_mult":
			return _faith_gain_mult
		"passive_faith_per_second":
			return _passive_faith_per_second
		"faith_per_conversion":
			return _faith_per_conversion_bonus
		"npc_spawn_rate_mult":
			return _npc_spawn_rate_mult
		"npc_speed_mult":
			return _npc_speed_mult
		"conversion_radius_mult":
			return _conversion_radius_mult
		"chain_conversion_chance":
			return _chain_conversion_chance
		"spawn_cluster_multiplier":
			return _spawn_cluster_multiplier
		_:
			return null

func _apply_upgrade_effect(effect_type: String, effect_value: Variant) -> void:
	match effect_type:
		"conversion_speed_mult":
			_conversion_speed_mult = _conversion_speed_mult * float(effect_value)
		"conversion_speed_mult_add":
			_conversion_speed_mult += float(effect_value)
		"npc_magnetism_unlock":
			if bool(effect_value):
				attraction_radius = max(attraction_radius, 90.0)
		"periodic_auto_convert_unlock":
			pass
		"chain_conversion_chance":
			_chain_conversion_chance = max(_chain_conversion_chance, float(effect_value))
		"conversion_radius_mult_add":
			_conversion_radius_mult += float(effect_value)
			mass_conversion_radius = max(mass_conversion_radius, 40.0 * _conversion_radius_mult)
		"faith_gain_mult_add":
			_faith_gain_mult += float(effect_value)
		"passive_faith_per_second_add":
			_passive_faith_per_second += float(effect_value)
		"passive_followers_per_second_add":
			passive_followers_per_second += float(effect_value)
		"faith_per_conversion_add":
			_faith_per_conversion_bonus += float(effect_value)
		"overflow_followers_to_faith_unlock":
			pass
		"npc_spawn_rate_mult_add":
			_npc_spawn_rate_mult += float(effect_value)
		"npc_spawn_bias_to_center_unlock":
			pass
		"npc_speed_mult":
			_npc_speed_mult *= float(effect_value)
		"spawn_cluster_unlock":
			spawn_cluster_bonus = max(spawn_cluster_bonus, 2)
		"mini_prophet_unlock":
			pass
		"prophet_spawn_unlock":
			pass
		"skeptic_bonus_unlock":
			pass
		"cursor_aura_convert_unlock":
			mass_conversion_radius = max(mass_conversion_radius, 48.0)
		"npc_spawn_multiplier_big":
			_spawn_cluster_multiplier *= float(effect_value)
			spawn_cluster_bonus += 3
		"run_start_mass_conversion_unlock":
			pass
		"final_world_shift_unlock":
			pass
		_:
			pass

func set_npc_pause(duration_seconds: float) -> void:
	_npc_pause_until_msec = Time.get_ticks_msec() + int(duration_seconds * 1000.0)

func are_npcs_paused() -> bool:
	if final_sequence_active:
		return true
	if current_phase != RunPhase.GAMEPLAY:
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
	var base_value: float = float(conversion_value + miracle_bonus) * _conversion_speed_mult
	return max(1, int(round(base_value)))

func get_faith_gain_multiplier() -> float:
	return _faith_gain_mult

func get_passive_faith_per_second() -> float:
	return _passive_faith_per_second

func get_faith_per_conversion() -> float:
	return _faith_per_conversion_bonus

func get_effective_npc_spawn_interval() -> float:
	return max(0.2, npc_spawn_interval / max(0.25, _npc_spawn_rate_mult))

func get_npc_speed_multiplier() -> float:
	return _npc_speed_mult

func get_effective_attraction_radius() -> float:
	return attraction_radius + attraction_radius_bonus

func get_effective_spawn_cluster_min() -> int:
	return int(round(float(spawn_cluster_min + spawn_cluster_bonus) * _spawn_cluster_multiplier))

func get_effective_spawn_cluster_max() -> int:
	return int(round(float(spawn_cluster_max + spawn_cluster_bonus) * _spawn_cluster_multiplier))

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
	return max(0, int(elapsed_msec / 1000))
