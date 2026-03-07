extends Node

signal dimension_changed(level: int)

@export var game_manager_path: NodePath
@export var background_path: NodePath

var _game_manager: GameManager
var _background: Sprite2D

var _thresholds: PackedInt32Array = PackedInt32Array([100, 1000, 10000, 100000, 1000000])
var _dimension_colors: Array[Color] = [
	Color(0.18, 0.26, 0.42),
	Color(0.25, 0.40, 0.30),
	Color(0.45, 0.35, 0.22),
	Color(0.36, 0.26, 0.36),
	Color(0.50, 0.45, 0.20)
]

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_background = get_node_or_null(background_path) as Sprite2D
	if _game_manager == null:
		return

	_ensure_background_texture()
	_update_background_color(_game_manager.current_dimension)

func _process(_delta: float) -> void:
	if _game_manager == null:
		return

	var new_dimension: int = _calculate_dimension(_game_manager.followers)
	if new_dimension == _game_manager.current_dimension:
		return

	_game_manager.current_dimension = new_dimension
	_game_manager.max_npc = max(_game_manager.max_npc, 50 + (new_dimension * 30))
	var target_interval: float = max(0.5, 1.5 - (float(new_dimension) * 0.15))
	_game_manager.npc_spawn_interval = min(_game_manager.npc_spawn_interval, target_interval)

	_update_background_color(new_dimension)
	dimension_changed.emit(new_dimension)
	_game_manager.dimension_changed.emit(new_dimension)
	_game_manager.state_changed.emit()

func _calculate_dimension(follower_count: int) -> int:
	var level: int = 0
	for i: int in range(_thresholds.size()):
		if follower_count >= _thresholds[i]:
			level = i + 1
	return level

func _ensure_background_texture() -> void:
	if _background == null:
		return
	if _background.texture != null:
		return

	var image: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_background.texture = texture
	_background.centered = false
	_background.scale = get_viewport_rect().size

func _update_background_color(level: int) -> void:
	if _background == null:
		return
	var index: int = clamp(level, 0, _dimension_colors.size() - 1)
	_background.modulate = _dimension_colors[index]