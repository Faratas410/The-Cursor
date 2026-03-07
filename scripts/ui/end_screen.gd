extends Control
class_name EndScreen

@onready var _followers_value: Label = $Panel/VBoxContainer/FollowersValue
@onready var _playtime_value: Label = $Panel/VBoxContainer/PlaytimeValue
@onready var _return_button: Button = $Panel/VBoxContainer/ReturnButton

func _ready() -> void:
	_return_button.pressed.connect(_on_return_pressed)

func set_results(follower_count: int, playtime_seconds: int) -> void:
	_followers_value.text = "Followers converted: %s" % _format_int(follower_count)
	_playtime_value.text = "Playtime: %s" % _format_time(playtime_seconds)

func _on_return_pressed() -> void:
	get_tree().reload_current_scene()

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

func _format_time(seconds: int) -> String:
	var minutes: int = int(seconds / 60)
	var rem_seconds: int = seconds % 60
	return "%02d:%02d" % [minutes, rem_seconds]

