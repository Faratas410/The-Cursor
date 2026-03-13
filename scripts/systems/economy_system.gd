extends Node

@export var game_manager_path: NodePath

var _game_manager: GameManager
var _passive_follower_buffer: float = 0.0

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager

func _process(delta: float) -> void:
	if _game_manager == null:
		return
	if _game_manager.final_sequence_active or not _game_manager.is_gameplay_phase():
		return

	if _game_manager.passive_followers_per_second > 0.0:
		_passive_follower_buffer += _game_manager.passive_followers_per_second * delta
		var whole_followers: int = int(floor(_passive_follower_buffer))
		if whole_followers > 0:
			_game_manager.add_followers(whole_followers)
			_passive_follower_buffer -= float(whole_followers)

	var multiplier: float = _game_manager.get_faith_gain_multiplier()
	var follower_count: float = float(_game_manager.followers)
	var base_faith_per_second: float = (follower_count * _game_manager.faith_per_follower) / (1.0 + (follower_count / 200.0))
	var generated_faith: float = (base_faith_per_second * multiplier * delta)
	generated_faith += _game_manager.get_passive_faith_per_second() * delta
	_game_manager.add_faith(generated_faith)

	_process_auto_sacrifice(delta)

func _process_auto_sacrifice(delta: float) -> void:
	if not _game_manager.auto_sacrifice_enabled:
		return
	if _game_manager.auto_sacrifice_interval <= 0.0:
		return

	_game_manager.auto_sacrifice_time_accumulator += delta
	if _game_manager.auto_sacrifice_time_accumulator < _game_manager.auto_sacrifice_interval:
		return

	while _game_manager.auto_sacrifice_time_accumulator >= _game_manager.auto_sacrifice_interval:
		_game_manager.auto_sacrifice_time_accumulator -= _game_manager.auto_sacrifice_interval
		_try_auto_sacrifice_once()

func _try_auto_sacrifice_once() -> void:
	if _game_manager.followers < _game_manager.auto_sacrifice_min_followers:
		return

	var computed_amount: int = int(floor(float(_game_manager.followers) * _game_manager.auto_sacrifice_percent))
	computed_amount = max(computed_amount, _game_manager.auto_sacrifice_min_amount)
	computed_amount = min(computed_amount, _game_manager.auto_sacrifice_max_amount)
	var safe_available: int = max(0, _game_manager.followers - _game_manager.auto_sacrifice_follower_floor)
	computed_amount = min(computed_amount, safe_available)
	if computed_amount < _game_manager.auto_sacrifice_min_amount:
		return

	_game_manager.perform_sacrifice(computed_amount, "auto")
