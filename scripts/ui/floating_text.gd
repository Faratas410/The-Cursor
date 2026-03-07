extends Node2D
class_name FloatingText

@onready var _label: Label = $Label

func show_text(text_position: Vector2, text: String) -> void:
	global_position = text_position
	_label.text = text

	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", text_position + Vector2(0.0, -36.0), 0.7)
	tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.7)
	tween.finished.connect(queue_free)