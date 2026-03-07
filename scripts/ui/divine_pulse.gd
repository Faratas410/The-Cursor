extends Node2D
class_name DivinePulse

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_ensure_texture()

func show_pulse(world_position: Vector2) -> void:
	global_position = world_position
	scale = Vector2(0.2, 0.2)
	_sprite.modulate = Color(1.0, 0.92, 0.55, 0.85)

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2.2, 2.2), 0.45)
	tween.parallel().tween_property(_sprite, "modulate:a", 0.0, 0.45)
	tween.finished.connect(queue_free)

func _ensure_texture() -> void:
	if _sprite.texture != null:
		return

	var size: int = 96
	var image: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(float(size) * 0.5, float(size) * 0.5)
	var radius: float = float(size) * 0.5

	for y: int in range(size):
		for x: int in range(size):
			var pos: Vector2 = Vector2(float(x), float(y))
			var dist: float = center.distance_to(pos)
			if dist > radius:
				image.set_pixel(x, y, Color(1, 1, 1, 0))
				continue
			var edge: float = dist / radius
			var alpha: float = max(0.0, 1.0 - edge)
			alpha = alpha * alpha
			image.set_pixel(x, y, Color(1, 1, 1, alpha))

	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_sprite.texture = texture