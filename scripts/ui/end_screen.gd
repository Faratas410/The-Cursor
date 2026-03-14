extends Control
class_name EndScreen

const PANEL_TEXTURE: Texture2D = preload("res://assets/ui/panels/panel_popup.png")
const BUTTON_PRIMARY_TEXTURE: Texture2D = preload("res://assets/ui/buttons/button_primary.png")
const BUTTON_SECONDARY_TEXTURE: Texture2D = preload("res://assets/ui/buttons/button_secondary.png")
const BUTTON_SMALL_TEXTURE: Texture2D = preload("res://assets/ui/buttons/button_small.png")

@onready var _followers_value: Label = $Panel/VBoxContainer/FollowersValue
@onready var _playtime_value: Label = $Panel/VBoxContainer/PlaytimeValue
@onready var _return_button: Button = $Panel/VBoxContainer/ReturnButton
@onready var _panel: Panel = $Panel

func _ready() -> void:
	_apply_visual_styles()
	_return_button.pressed.connect(_on_return_pressed)

func _apply_visual_styles() -> void:
	var panel_style: StyleBoxTexture = StyleBoxTexture.new()
	panel_style.texture = PANEL_TEXTURE
	panel_style.set_texture_margin_all(12.0)
	panel_style.content_margin_left = 14.0
	panel_style.content_margin_top = 12.0
	panel_style.content_margin_right = 14.0
	panel_style.content_margin_bottom = 12.0
	_panel.add_theme_stylebox_override("panel", panel_style)

	var normal: StyleBoxTexture = StyleBoxTexture.new()
	normal.texture = BUTTON_PRIMARY_TEXTURE
	normal.set_texture_margin_all(10.0)
	var hover: StyleBoxTexture = StyleBoxTexture.new()
	hover.texture = BUTTON_SECONDARY_TEXTURE
	hover.set_texture_margin_all(10.0)
	var disabled: StyleBoxTexture = StyleBoxTexture.new()
	disabled.texture = BUTTON_SMALL_TEXTURE
	disabled.set_texture_margin_all(10.0)
	_return_button.add_theme_stylebox_override("normal", normal)
	_return_button.add_theme_stylebox_override("hover", hover)
	_return_button.add_theme_stylebox_override("pressed", hover)
	_return_button.add_theme_stylebox_override("disabled", disabled)

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
	var minutes: int = int(seconds / 60.0)
	var rem_seconds: int = seconds % 60
	return "%02d:%02d" % [minutes, rem_seconds]


