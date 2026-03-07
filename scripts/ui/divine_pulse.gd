extends Node2D
class_name DivinePulse

const DIVINE_PULSE_TEXTURE: Texture2D = preload("res://assets/ui/effects/divine_pulse.png")

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_sprite.texture = DIVINE_PULSE_TEXTURE

func show_pulse(world_position: Vector2) -> void:
	global_position = world_position
	scale = Vector2(0.2, 0.2)
	_sprite.modulate = Color(1.0, 0.92, 0.55, 0.85)

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2.2, 2.2), 0.45)
	tween.parallel().tween_property(_sprite, "modulate:a", 0.0, 0.45)
	tween.finished.connect(queue_free)
