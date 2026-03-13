extends Node
class_name GameManager

enum RunPhase {
	GAMEPLAY,
	UPGRADE
}

const MAX_CONVERSION_RADIUS: float = 44.0

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
@warning_ignore("unused_signal")
signal sacrifice_performed(amount: int, faith_gained: float, source: String)
@warning_ignore("unused_signal")
signal auto_sacrifice_triggered(amount: int, faith_gained: float)
@warning_ignore("unused_signal")
signal upgrade_choice_locked(group_id: String, chosen_upgrade_id: String)

static var UPGRADE_TREE_DEFS: Array[Dictionary] = [
	{
		"id": "awakening", "name": "Awakening", "description": "The first spark of devotion.",
		"cost": 0.0, "branch": "root", "tier": 0, "dependencies": PackedStringArray(),
		"choice_group_id": "", "purchased": true, "effect_type": "conversion_speed_mult", "effect_value": 1.10,
		"visible_by_default": true
	},
	{
		"id": "magnetic_presence", "name": "Magnetic Presence", "description": "Unlocked magnetism around the cursor.",
		"cost": 40.0, "branch": "conversion", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"choice_group_id": "", "purchased": false, "effect_type": "npc_magnetism_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "faster_conversion", "name": "Faster Conversion", "description": "Convert with stronger force.",
		"cost": 75.0, "branch": "conversion", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"choice_group_id": "", "purchased": false, "effect_type": "conversion_speed_mult_add", "effect_value": 0.25,
		"visible_by_default": true
	},
	{
		"id": "conversion_pulse", "name": "Conversion Pulse", "description": "Periodic pulse conversion unlock.",
		"cost": 120.0, "branch": "conversion", "tier": 2, "dependencies": PackedStringArray(["magnetic_presence"]),
		"choice_group_id": "", "purchased": false, "effect_type": "periodic_auto_convert_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "conversion_chain", "name": "Conversion Chain", "description": "Chance to chain nearby converts.",
		"cost": 180.0, "branch": "conversion", "tier": 2, "dependencies": PackedStringArray(["faster_conversion"]),
		"choice_group_id": "", "purchased": false, "effect_type": "chain_conversion_chance", "effect_value": 0.20,
		"visible_by_default": true
	},
	{
		"id": "mass_conversion", "name": "Mass Conversion", "description": "Increase conversion radius.",
		"cost": 320.0, "branch": "conversion", "tier": 3, "dependencies": PackedStringArray(["conversion_chain"]),
		"choice_group_id": "", "purchased": false, "effect_type": "conversion_radius_mult_add", "effect_value": 8.0,
		"visible_by_default": true
	},
	{
		"id": "faith_amplifier", "name": "Faith Amplifier", "description": "Increase all faith gain.",
		"cost": 60.0, "branch": "faith_flow", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"choice_group_id": "", "purchased": false, "effect_type": "faith_gain_mult_add", "effect_value": 0.30,
		"visible_by_default": true
	},
	{
		"id": "steady_worship", "name": "Steady Worship", "description": "Passive faith focus with weaker sacrifice.",
		"cost": 160.0, "branch": "faith_flow", "tier": 2, "dependencies": PackedStringArray(["faith_amplifier"]),
		"choice_group_id": "faith_path", "purchased": false, "effect_type": "steady_worship_choice", "effect_value": 1.0,
		"visible_by_default": true
	},
	{
		"id": "violent_faith", "name": "Violent Faith", "description": "Ritual burst focus over passive comfort.",
		"cost": 160.0, "branch": "faith_flow", "tier": 2, "dependencies": PackedStringArray(["faith_amplifier"]),
		"choice_group_id": "faith_path", "purchased": false, "effect_type": "violent_faith_choice", "effect_value": 1.0,
		"visible_by_default": true
	},
	{
		"id": "cult_donations", "name": "Cult Donations", "description": "Passive faith generation per second.",
		"cost": 110.0, "branch": "faith_flow", "tier": 3, "dependencies": PackedStringArray(["steady_worship"]),
		"choice_group_id": "", "purchased": false, "effect_type": "passive_faith_per_second_add", "effect_value": 0.2,
		"visible_by_default": true
	},
	{
		"id": "sacred_economy", "name": "Sacred Economy", "description": "Passive follower generation.",
		"cost": 220.0, "branch": "faith_flow", "tier": 4, "dependencies": PackedStringArray(["cult_donations"]),
		"choice_group_id": "", "purchased": false, "effect_type": "passive_followers_per_second_add", "effect_value": 0.15,
		"visible_by_default": true
	},
	{
		"id": "divine_harvest", "name": "Divine Harvest", "description": "Gain bonus faith per conversion.",
		"cost": 380.0, "branch": "faith_flow", "tier": 4, "dependencies": PackedStringArray(["violent_faith"]),
		"choice_group_id": "", "purchased": false, "effect_type": "faith_per_conversion_add", "effect_value": 0.5,
		"visible_by_default": true
	},
	{
		"id": "overflow_faith", "name": "Overflow Faith", "description": "Overflow followers can become faith.",
		"cost": 700.0, "branch": "faith_flow", "tier": 5, "dependencies": PackedStringArray(["divine_harvest"]),
		"choice_group_id": "", "purchased": false, "effect_type": "overflow_followers_to_faith_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "curious_crowds", "name": "Curious Crowds", "description": "Increase NPC spawn rate.",
		"cost": 90.0, "branch": "world_control", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"choice_group_id": "", "purchased": false, "effect_type": "npc_spawn_rate_mult_add", "effect_value": 0.20,
		"visible_by_default": true
	},
	{
		"id": "path_growth", "name": "Path of Growth", "description": "Spawn-oriented growth path.",
		"cost": 170.0, "branch": "world_control", "tier": 2, "dependencies": PackedStringArray(["curious_crowds"]),
		"choice_group_id": "world_path", "purchased": false, "effect_type": "growth_path_choice", "effect_value": 1.0,
		"visible_by_default": true
	},
	{
		"id": "path_control", "name": "Path of Control", "description": "Control-oriented safer conversions.",
		"cost": 170.0, "branch": "world_control", "tier": 2, "dependencies": PackedStringArray(["curious_crowds"]),
		"choice_group_id": "world_path", "purchased": false, "effect_type": "control_path_choice", "effect_value": 1.0,
		"visible_by_default": true
	},
	{
		"id": "pilgrimage", "name": "Pilgrimage", "description": "Crowds drift more toward center.",
		"cost": 130.0, "branch": "world_control", "tier": 3, "dependencies": PackedStringArray(["path_control"]),
		"choice_group_id": "", "purchased": false, "effect_type": "npc_spawn_bias_to_center_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "wandering_faith", "name": "Wandering Faith", "description": "NPC movement slows for readability.",
		"cost": 180.0, "branch": "world_control", "tier": 3, "dependencies": PackedStringArray(["path_control"]),
		"choice_group_id": "", "purchased": false, "effect_type": "npc_speed_mult", "effect_value": 0.85,
		"visible_by_default": true
	},
	{
		"id": "sacred_ground", "name": "Sacred Ground", "description": "Unlock larger spawn clustering.",
		"cost": 340.0, "branch": "world_control", "tier": 4, "dependencies": PackedStringArray(["curious_crowds"]),
		"choice_group_id": "", "purchased": false, "effect_type": "spawn_cluster_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "ritual_knife", "name": "Ritual Knife", "description": "Unlock manual sacrifice.",
		"cost": 140.0, "branch": "ritual", "tier": 1, "dependencies": PackedStringArray(["awakening"]),
		"choice_group_id": "", "purchased": false, "effect_type": "unlock_manual_sacrifice", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "blood_ledger", "name": "Blood Ledger", "description": "Improves sacrifice efficiency.",
		"cost": 260.0, "branch": "ritual", "tier": 2, "dependencies": PackedStringArray(["ritual_knife"]),
		"choice_group_id": "", "purchased": false, "effect_type": "sacrifice_efficiency_mult_add", "effect_value": 0.15,
		"visible_by_default": true
	},
	{
		"id": "blood_tithe", "name": "Blood Tithe", "description": "Unlock auto sacrifice.",
		"cost": 420.0, "branch": "ritual", "tier": 3, "dependencies": PackedStringArray(["blood_ledger"]),
		"choice_group_id": "", "purchased": false, "effect_type": "unlock_auto_sacrifice", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "grand_offering", "name": "Grand Offering", "description": "Boosts auto sacrifice payout and cap.",
		"cost": 620.0, "branch": "ritual", "tier": 4, "dependencies": PackedStringArray(["blood_tithe"]),
		"choice_group_id": "", "purchased": false, "effect_type": "grand_offering_package", "effect_value": 1.0,
		"visible_by_default": true
	},
	{
		"id": "cult_leaders", "name": "Cult Leaders", "description": "Unlock mini-prophet effects.",
		"cost": 280.0, "branch": "cult_power", "tier": 1, "dependencies": PackedStringArray(["mass_conversion", "ritual_knife"]),
		"choice_group_id": "", "purchased": false, "effect_type": "mini_prophet_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "wide_influence", "name": "Wide Influence", "description": "A larger aura-oriented cult style.",
		"cost": 320.0, "branch": "cult_power", "tier": 2, "dependencies": PackedStringArray(["cult_leaders"]),
		"choice_group_id": "cult_path", "purchased": false, "effect_type": "wide_influence_choice", "effect_value": 1.0,
		"visible_by_default": true
	},
	{
		"id": "focused_conversion", "name": "Focused Conversion", "description": "Faster high-precision conversion style.",
		"cost": 320.0, "branch": "cult_power", "tier": 2, "dependencies": PackedStringArray(["cult_leaders"]),
		"choice_group_id": "cult_path", "purchased": false, "effect_type": "focused_conversion_choice", "effect_value": 1.0,
		"visible_by_default": true
	},
	{
		"id": "prophecy", "name": "Prophecy", "description": "Unlock prophet spawn boosts.",
		"cost": 380.0, "branch": "cult_power", "tier": 3, "dependencies": PackedStringArray(["cult_leaders"]),
		"choice_group_id": "", "purchased": false, "effect_type": "prophet_spawn_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "skeptic_hunt", "name": "Skeptic Hunt", "description": "Unlock anti-skeptic bonuses.",
		"cost": 420.0, "branch": "cult_power", "tier": 3, "dependencies": PackedStringArray(["cult_leaders"]),
		"choice_group_id": "", "purchased": false, "effect_type": "skeptic_bonus_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "divine_aura", "name": "Divine Aura", "description": "Unlock aura-based conversions.",
		"cost": 500.0, "branch": "late_game", "tier": 1, "dependencies": PackedStringArray(["cult_leaders"]),
		"choice_group_id": "", "purchased": false, "effect_type": "cursor_aura_convert_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "cult_expansion", "name": "Cult Expansion", "description": "Scales spawning in a controlled way.",
		"cost": 800.0, "branch": "late_game", "tier": 2, "dependencies": PackedStringArray(["sacred_ground", "divine_aura"]),
		"choice_group_id": "", "purchased": false, "effect_type": "npc_spawn_multiplier_big", "effect_value": 1.35,
		"visible_by_default": true
	},
	{
		"id": "worship_wave", "name": "Worship Wave", "description": "Run start mass conversion unlock.",
		"cost": 950.0, "branch": "late_game", "tier": 3, "dependencies": PackedStringArray(["cult_expansion"]),
		"choice_group_id": "", "purchased": false, "effect_type": "run_start_mass_conversion_unlock", "effect_value": true,
		"visible_by_default": true
	},
	{
		"id": "they_can_see_you", "name": "They Can See You", "description": "Final world shift unlock.",
		"cost": 1800.0, "branch": "late_game", "tier": 4, "dependencies": PackedStringArray(["worship_wave"]),
		"choice_group_id": "", "purchased": false, "effect_type": "final_world_shift_unlock", "effect_value": true,
		"visible_by_default": true
	}
]

var followers: int = 0
var faith: float = 0.0

var conversion_value: int = 1
var faith_per_follower: float = 0.008

var npc_spawn_interval: float = 2.2
var max_npc: int = 50

var current_dimension: int = 0
var divinity_level: int = 0
var passive_followers_per_second: float = 0.0

var attraction_radius: float = 60.0
var attraction_radius_bonus: float = 0.0
var mass_conversion_radius: float = 0.0
var max_followers_near_cursor: int = 30
var spawn_cluster_min: int = 2
var spawn_cluster_max: int = 4
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
var run_index: int = 0

var sacrifice_unlocked: bool = false
var sacrifice_efficiency_multiplier: float = 1.0

var auto_sacrifice_enabled: bool = false
var auto_sacrifice_interval: float = 10.0
var auto_sacrifice_percent: float = 0.10
var auto_sacrifice_min_followers: int = 40
var auto_sacrifice_min_amount: int = 10
var auto_sacrifice_max_amount: int = 80
var auto_sacrifice_follower_floor: int = 25
var auto_sacrifice_source_multiplier: float = 0.80
var auto_sacrifice_time_accumulator: float = 0.0

var chosen_upgrade_groups: Dictionary = {}

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
	chosen_upgrade_groups.clear()
	for definition: Dictionary in UPGRADE_TREE_DEFS:
		var entry: Dictionary = definition.duplicate(true)
		var id: String = String(entry.get("id", ""))
		if id.is_empty():
			continue
		entry["purchased"] = bool(entry.get("purchased", false))
		_upgrade_by_id[id] = entry
		if bool(entry["purchased"]):
			var group_id: String = String(entry.get("choice_group_id", ""))
			if not group_id.is_empty():
				chosen_upgrade_groups[group_id] = id

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
	run_index += 1
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

	var final_amount: int = amount
	if current_phase == RunPhase.GAMEPLAY:
		final_amount = max(1, int(round(float(amount) * get_run_multiplier())))

	followers += final_amount
	if current_phase == RunPhase.GAMEPLAY:
		run_followers_gained += final_amount
	if has_upgrade("overflow_faith") and max_npc > 0 and followers > 1000000:
		add_faith(float(final_amount) * 0.03)
	state_changed.emit()

func add_faith(amount: float) -> void:
	if amount <= 0.0:
		return
	if final_sequence_active:
		return

	var final_amount: float = amount
	if current_phase == RunPhase.GAMEPLAY:
		final_amount *= get_run_multiplier()

	faith += final_amount
	if current_phase == RunPhase.GAMEPLAY:
		run_faith_gained += final_amount
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
		entry["choice_locked"] = _is_upgrade_locked_by_choice(id)
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

func get_upgrade_choice_group(id: String) -> String:
	if not _upgrade_by_id.has(id):
		return ""
	return String(_upgrade_by_id[id].get("choice_group_id", ""))

func get_chosen_upgrade_for_group(group_id: String) -> String:
	if group_id.is_empty():
		return ""
	if not chosen_upgrade_groups.has(group_id):
		return ""
	return String(chosen_upgrade_groups[group_id])

func get_upgrade_name(id: String) -> String:
	if not _upgrade_by_id.has(id):
		return id
	return String(_upgrade_by_id[id].get("name", id))

func get_choice_lock_reason(id: String) -> String:
	var group_id: String = get_upgrade_choice_group(id)
	if group_id.is_empty():
		return ""
	var chosen_id: String = get_chosen_upgrade_for_group(group_id)
	if chosen_id.is_empty() or chosen_id == id:
		return ""
	return get_upgrade_name(chosen_id)

func _is_upgrade_locked_by_choice(id: String) -> bool:
	var group_id: String = get_upgrade_choice_group(id)
	if group_id.is_empty():
		return false
	var chosen_id: String = get_chosen_upgrade_for_group(group_id)
	if chosen_id.is_empty():
		return false
	return chosen_id != id

func can_purchase_upgrade(id: String) -> bool:
	if final_sequence_active:
		return false
	if not is_upgrade_phase():
		return false
	if not _upgrade_by_id.has(id):
		return false
	if has_upgrade(id):
		return false
	if _is_upgrade_locked_by_choice(id):
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

	var group_id: String = String(data.get("choice_group_id", ""))
	if not group_id.is_empty():
		chosen_upgrade_groups[group_id] = id
		upgrade_choice_locked.emit(group_id, id)

	var effect_type: String = String(data.get("effect_type", ""))
	var effect_value: Variant = data.get("effect_value", null)
	_apply_upgrade_effect(effect_type, effect_value)

	var payload: Dictionary = {
		"id": id,
		"name": String(data.get("name", id)),
		"cost": cost,
		"effect_type": effect_type,
		"effect_value": effect_value,
		"choice_group_id": group_id
	}
	upgrade_purchased.emit(payload)
	state_changed.emit()
	return true

func get_upgrade_display_state(id: String) -> String:
	if not _upgrade_by_id.has(id):
		return "locked"
	if has_upgrade(id):
		return "purchased"
	if _is_upgrade_locked_by_choice(id):
		return "choice_locked"
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
		"sacrifice_efficiency_multiplier":
			return sacrifice_efficiency_multiplier
		_:
			return null

func _apply_upgrade_effect(effect_type: String, effect_value: Variant) -> void:
	match effect_type:
		"conversion_speed_mult":
			_conversion_speed_mult *= float(effect_value)
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
			_conversion_radius_mult += float(effect_value) / MAX_CONVERSION_RADIUS
			_add_conversion_radius(float(effect_value))
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
			_add_conversion_radius(10.0)
		"npc_spawn_multiplier_big":
			_spawn_cluster_multiplier *= float(effect_value)
			spawn_cluster_bonus += 1
		"run_start_mass_conversion_unlock":
			_add_conversion_radius(12.0)
		"unlock_manual_sacrifice":
			sacrifice_unlocked = bool(effect_value)
		"sacrifice_efficiency_mult_add":
			sacrifice_efficiency_multiplier += float(effect_value)
		"unlock_auto_sacrifice":
			auto_sacrifice_enabled = bool(effect_value)
		"grand_offering_package":
			auto_sacrifice_max_amount += 40
			auto_sacrifice_source_multiplier = min(1.0, auto_sacrifice_source_multiplier + 0.10)
		"steady_worship_choice":
			_passive_faith_per_second += 0.25
			sacrifice_efficiency_multiplier = max(0.5, sacrifice_efficiency_multiplier - 0.10)
		"violent_faith_choice":
			sacrifice_efficiency_multiplier += 0.25
			_faith_gain_mult = max(0.5, _faith_gain_mult - 0.05)
		"growth_path_choice":
			_npc_spawn_rate_mult += 0.15
		"control_path_choice":
			attraction_radius += 16.0
			_npc_speed_mult *= 0.95
		"wide_influence_choice":
			_add_conversion_radius(6.0)
		"focused_conversion_choice":
			_conversion_speed_mult += 0.20
			_chain_conversion_chance = min(0.95, _chain_conversion_chance + 0.10)
		"final_world_shift_unlock":
			pass
		_:
			pass

func get_sacrifice_tier_multiplier(amount: int) -> float:
	if amount >= 400:
		return 1.50
	if amount >= 200:
		return 1.35
	if amount >= 100:
		return 1.20
	if amount >= 50:
		return 1.10
	return 1.00

func get_sacrifice_faith_preview(amount: int, source: String) -> float:
	if amount <= 0:
		return 0.0
	var base_faith: float = float(amount)
	var tier_multiplier: float = get_sacrifice_tier_multiplier(amount)
	var source_multiplier: float = _get_sacrifice_source_multiplier(source)
	return base_faith * tier_multiplier * sacrifice_efficiency_multiplier * source_multiplier

func get_manual_sacrifice_max_safe_amount() -> int:
	if not sacrifice_unlocked:
		return 0
	if not is_upgrade_phase():
		return 0
	return max(0, followers)

func perform_sacrifice(amount: int, source: String) -> float:
	if amount <= 0:
		return 0.0
	if not sacrifice_unlocked:
		return 0.0

	var requested: int = amount
	if source == "manual":
		if not is_upgrade_phase():
			return 0.0
		requested = min(requested, followers)
	elif source == "auto":
		if not is_gameplay_phase() or not auto_sacrifice_enabled:
			return 0.0
		if followers < auto_sacrifice_min_followers:
			return 0.0
		var safe_available: int = max(0, followers - auto_sacrifice_follower_floor)
		requested = min(requested, safe_available)
	else:
		return 0.0

	if requested <= 0:
		return 0.0

	followers -= requested
	var faith_gained: float = get_sacrifice_faith_preview(requested, source)
	faith += faith_gained
	if is_gameplay_phase():
		run_faith_gained += faith_gained
	sacrifice_performed.emit(requested, faith_gained, source)
	if source == "auto":
		auto_sacrifice_triggered.emit(requested, faith_gained)
	state_changed.emit()
	return faith_gained

func _get_sacrifice_source_multiplier(source: String) -> float:
	if source == "manual":
		return 1.0
	if source == "auto":
		return auto_sacrifice_source_multiplier
	return 1.0

func get_auto_sacrifice_seconds_until_next() -> float:
	if not auto_sacrifice_enabled or auto_sacrifice_interval <= 0.0:
		return 0.0
	return max(0.0, auto_sacrifice_interval - auto_sacrifice_time_accumulator)

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

func get_run_multiplier() -> float:
	var completed_runs: int = max(0, run_index - 1)
	return 1.0 + (float(completed_runs) * 0.05)

func _add_conversion_radius(amount: float) -> void:
	if amount <= 0.0:
		return
	mass_conversion_radius = min(MAX_CONVERSION_RADIUS, mass_conversion_radius + amount)

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
	return max(0, int(float(elapsed_msec) / 1000.0))

