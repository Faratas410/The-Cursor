extends Node

@export var game_manager_path: NodePath

var _game_manager: GameManager
var _passive_follower_buffer: float = 0.0

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager

func _process(delta: float) -> void:
	if _game_manager == null:
		return

	if _game_manager.passive_followers_per_second > 0.0:
		_passive_follower_buffer += _game_manager.passive_followers_per_second * delta
		var whole_followers: int = int(floor(_passive_follower_buffer))
		if whole_followers > 0:
			_game_manager.add_followers(whole_followers)
			_passive_follower_buffer -= float(whole_followers)

	var generated_faith: float = float(_game_manager.followers) * _game_manager.faith_per_follower * delta
	_game_manager.add_faith(generated_faith)