extends Node2D
class_name FloatingText

@onready var _label: Label = $Label

func show_text(text_position: Vector2, text: String) -> void:
	global_position = text_position
	_label.text = text
	_label.modulate = _color_for_text(text)

	var rise_target: Vector2 = text_position + Vector2(randf_range(-8.0, 8.0), -44.0)
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", rise_target, 0.72)
	tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.7)
	tween.finished.connect(queue_free)

func _color_for_text(text: String) -> Color:
	if text.contains("FAITH"):
		return Color(0.95, 0.82, 1.0, 1.0)
	if text.contains("CHAIN"):
		return Color(1.0, 0.92, 0.62, 1.0)
	return Color(1.0, 0.95, 0.6, 1.0)
