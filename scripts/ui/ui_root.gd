extends CanvasLayer

@export var game_manager_path: NodePath
@export var followers_label_path: NodePath
@export var faith_label_path: NodePath

var _game_manager: GameManager
var _followers_label: Label
var _faith_label: Label

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_followers_label = get_node_or_null(followers_label_path) as Label
	_faith_label = get_node_or_null(faith_label_path) as Label

	if _game_manager != null:
		_game_manager.state_changed.connect(_refresh_labels)
	_refresh_labels()

func _refresh_labels() -> void:
	if _game_manager == null:
		return
	if _followers_label != null:
		_followers_label.text = "Followers: %s / 1,000,000" % _format_int(_game_manager.followers)
	if _faith_label != null:
		_faith_label.text = "Faith: %.1f" % _game_manager.faith

func _format_int(value: int) -> String:
	var text: String = str(value)
	var out: String = ""
	var count: int = 0
	for i: int in range(text.length() - 1, -1, -1):
		out = text.substr(i, 1) + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return out