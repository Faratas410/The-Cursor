extends VBoxContainer

class Upgrade:
	var name: String
	var cost: float
	var effect_type: StringName
	var effect_value: float

	func _init(upgrade_name: String, upgrade_cost: float, upgrade_effect_type: StringName, upgrade_effect_value: float) -> void:
		name = upgrade_name
		cost = upgrade_cost
		effect_type = upgrade_effect_type
		effect_value = upgrade_effect_value

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
		Upgrade.new("Conversion Aura", 50.0, &"conversion_value", 1.0),
		Upgrade.new("Missionaries", 100.0, &"passive_followers", 1.0),
		Upgrade.new("Divine Presence", 200.0, &"spawn_interval", 0.1)
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
	if index < 0 or index >= _upgrades.size():
		return

	var upgrade: Upgrade = _upgrades[index]
	if not _game_manager.spend_faith(upgrade.cost):
		return

	_game_manager.apply_upgrade(upgrade.effect_type, upgrade.effect_value)

	var payload: Dictionary = {
		"name": upgrade.name,
		"cost": upgrade.cost,
		"effect_type": String(upgrade.effect_type),
		"effect_value": upgrade.effect_value
	}
	upgrade_purchased.emit(payload)
	_game_manager.upgrade_purchased.emit(payload)

	upgrade.cost *= 1.75
	_update_button_text(index)
	_refresh_button_states()

func _update_button_text(index: int) -> void:
	if index < 0 or index >= _upgrades.size() or index >= _buttons.size():
		return

	var upgrade: Upgrade = _upgrades[index]
	var button: Button = _buttons[index]
	button.text = "%s  (Cost: %.1f Faith)" % [upgrade.name, upgrade.cost]

func _refresh_button_states() -> void:
	if _game_manager == null:
		return

	for i: int in range(_buttons.size()):
		var button: Button = _buttons[i]
		var upgrade: Upgrade = _upgrades[i]
		button.disabled = _game_manager.faith < upgrade.cost
		_update_button_text(i)