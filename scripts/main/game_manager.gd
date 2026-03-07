extends Node
class_name GameManager

signal npc_converted()
signal upgrade_purchased(upgrade: Dictionary)
signal dimension_changed(level: int)
signal state_changed()

var followers: int = 0
var faith: float = 0.0

var conversion_value: int = 1
var faith_per_follower: float = 0.01

var npc_spawn_interval: float = 1.5
var max_npc: int = 50

var current_dimension: int = 0
var passive_followers_per_second: float = 0.0

func add_followers(amount: int) -> void:
	if amount <= 0:
		return
	followers += amount
	state_changed.emit()

func add_faith(amount: float) -> void:
	if amount <= 0.0:
		return
	faith += amount
	state_changed.emit()

func spend_faith(cost: float) -> bool:
	if faith < cost:
		return false
	faith -= cost
	state_changed.emit()
	return true

func apply_upgrade(effect_type: StringName, effect_value: float) -> void:
	match effect_type:
		&"conversion_value":
			conversion_value += int(effect_value)
		&"passive_followers":
			passive_followers_per_second += effect_value
		&"spawn_interval":
			npc_spawn_interval = max(0.2, npc_spawn_interval - effect_value)
		_:
			return
	state_changed.emit()