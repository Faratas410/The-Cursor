extends VBoxContainer

class Upgrade:
	var name: String
	var effect_type: StringName
	var effect_value: float
	var cost: float
	var cost_multiplier: float
	var max_level: int
	var current_level: int
	var tier_values: Array
	var tier_costs: Array

	func _init(
		upgrade_name: String,
		upgrade_effect_type: StringName,
		upgrade_effect_value: float,
		upgrade_cost: float,
		upgrade_cost_multiplier: float,
		upgrade_max_level: int,
		upgrade_tier_values: Array,
		upgrade_tier_costs: Array
	) -> void:
		name = upgrade_name
		effect_type = upgrade_effect_type
		effect_value = upgrade_effect_value
		cost = upgrade_cost
		cost_multiplier = upgrade_cost_multiplier
		max_level = upgrade_max_level
		current_level = 0
		tier_values = upgrade_tier_values
		tier_costs = upgrade_tier_costs

	func is_tiered() -> bool:
		return tier_values.size() > 0 and tier_costs.size() > 0

	func is_maxed() -> bool:
		if max_level < 0:
			return false
		return current_level >= max_level

	func get_current_cost() -> float:
		if is_tiered() and current_level < tier_costs.size():
			return float(tier_costs[current_level])
		return cost

	func get_current_effect_value() -> float:
		if is_tiered() and current_level < tier_values.size():
			return float(tier_values[current_level])
		return effect_value

	func register_purchase() -> void:
		current_level += 1
		if not is_tiered():
			cost *= cost_multiplier

signal upgrade_purchased(upgrade: Dictionary)

@export var game_manager_path: NodePath
@export var upgrade_button_scene: PackedScene

var _game_manager: GameManager
var _upgrades: Array[Upgrade] = []
var _buttons: Array[Button] = []

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_build_upgrade_data()
	_build_buttons()

	if _game_manager != null:
		_game_manager.state_changed.connect(_refresh_button_states)
	_refresh_button_states()

func _build_upgrade_data() -> void:
	_upgrades = [
		Upgrade.new("Conversion Aura", &"attraction_radius", 0.0, 0.0, 1.0, 3, [80.0, 120.0, 180.0], [50.0, 120.0, 260.0]),
		Upgrade.new("Mass Conversion", &"mass_conversion", 0.0, 0.0, 1.0, 1, [40.0], [350.0]),
		Upgrade.new("Missionaries", &"passive_followers", 1.0, 100.0, 1.75, -1, [], []),
		Upgrade.new("Divine Presence", &"spawn_interval", 0.1, 200.0, 1.75, -1, [], [])
	]

func _build_buttons() -> void:
	for child: Node in get_children():
		child.queue_free()
	_buttons.clear()

	for i: int in range(_upgrades.size()):
		var button: Button = _create_button(i)
		add_child(button)
		_buttons.append(button)

func _create_button(index: int) -> Button:
	var button: Button
	if upgrade_button_scene != null:
		button = upgrade_button_scene.instantiate() as Button
	else:
		button = Button.new()

	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(_on_upgrade_pressed.bind(index))
	_update_button_text(index)
	return button

func _on_upgrade_pressed(index: int) -> void:
	if _game_manager == null:
		return
	if _game_manager.final_sequence_active:
		return
	if index < 0 or index >= _upgrades.size():
		return

	var upgrade: Upgrade = _upgrades[index]
	if upgrade.is_maxed():
		return

	var current_cost: float = upgrade.get_current_cost()
	if not _game_manager.spend_faith(current_cost):
		return

	var applied_value: float = upgrade.get_current_effect_value()
	_game_manager.apply_upgrade(upgrade.effect_type, applied_value)

	var payload: Dictionary = {
		"name": upgrade.name,
		"cost": current_cost,
		"effect_type": String(upgrade.effect_type),
		"effect_value": applied_value,
		"level": upgrade.current_level + 1
	}
	upgrade_purchased.emit(payload)
	_game_manager.upgrade_purchased.emit(payload)
	play_upgrade_sound()

	upgrade.register_purchase()
	_update_button_text(index)
	_refresh_button_states()

func _update_button_text(index: int) -> void:
	if index < 0 or index >= _upgrades.size() or index >= _buttons.size():
		return

	var upgrade: Upgrade = _upgrades[index]
	var button: Button = _buttons[index]
	if upgrade.is_maxed():
		button.text = "%s  (MAX)" % upgrade.name
		return

	var cost: float = upgrade.get_current_cost()
	if upgrade.max_level > 0:
		button.text = "%s  L%d/%d  (Cost: %.1f Faith)" % [upgrade.name, upgrade.current_level + 1, upgrade.max_level, cost]
	else:
		button.text = "%s  (Cost: %.1f Faith)" % [upgrade.name, cost]

func _refresh_button_states() -> void:
	if _game_manager == null:
		return

	var lock_upgrades: bool = _game_manager.final_sequence_active
	for i: int in range(_buttons.size()):
		var button: Button = _buttons[i]
		var upgrade: Upgrade = _upgrades[i]
		if lock_upgrades:
			button.disabled = true
		elif upgrade.is_maxed():
			button.disabled = true
		else:
			button.disabled = _game_manager.faith < upgrade.get_current_cost()
		_update_button_text(i)

func play_upgrade_sound() -> void:
	pass