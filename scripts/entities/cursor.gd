extends Node2D
class_name CursorEntity

signal npc_detected(npc: Node)

static var CURSOR_TEXTURES: Dictionary = {
	"base": preload("res://assets/sprites/cursor/cursor_base.png"),
	"glow": preload("res://assets/sprites/cursor/cursor_glow.png"),
	"cult": preload("res://assets/sprites/cursor/cursor_cult.png"),
	"divine": preload("res://assets/sprites/cursor/cursor_divine.png"),
	"final": preload("res://assets/sprites/cursor/cursor_final.png")
}

const CURSOR_AURA_TEXTURE: Texture2D = preload("res://assets/ui/effects/cursor_aura.png")

@export var game_manager_path: NodePath
@export var attraction_radius: float = 60.0

@onready var _area: Area2D = $Area2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _aura: Sprite2D = $Aura

var _game_manager: GameManager
var _last_position: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.UP
var _current_cursor_state: String = ""

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_last_position = global_position
	_area.body_entered.connect(_on_body_entered)
	_aura.texture = CURSOR_AURA_TEXTURE
	if _game_manager != null:
		_game_manager.state_changed.connect(_on_game_state_changed)
		_game_manager.final_sequence_started.connect(_on_final_sequence_started)
	_update_cursor_visual_from_progress()
	_update_aura_visual()

func _process(_delta: float) -> void:
	if _game_manager == null:
		return

	if not _game_manager.cursor_locked:
		global_position = get_global_mouse_position()

	var delta_pos: Vector2 = global_position - _last_position
	if delta_pos.length() > 0.001:
		movement_direction = delta_pos.normalized()
	_last_position = global_position

	attraction_radius = _game_manager.get_effective_attraction_radius()
	_update_aura_visual()

func set_cursor_visual(state: String) -> void:
	if _sprite == null:
		return
	if not CURSOR_TEXTURES.has(state):
		return
	_sprite.texture = CURSOR_TEXTURES[state] as Texture2D

func _update_cursor_visual_from_progress() -> void:
	if _game_manager == null:
		return

	var next_state: String = "base"
	if _game_manager.final_sequence_active or _game_manager.cursor_locked:
		next_state = "final"
	elif _game_manager.followers >= 100000:
		next_state = "divine"
	elif _game_manager.followers >= 10000:
		next_state = "cult"
	elif _game_manager.followers >= 1000:
		next_state = "glow"

	if next_state == _current_cursor_state:
		return

	_current_cursor_state = next_state
	set_cursor_visual(next_state)

func _update_aura_visual() -> void:
	if _aura == null:
		return

	var radius_scale: float = max(0.4, attraction_radius / 64.0)
	_aura.scale = Vector2(radius_scale, radius_scale)
	var alpha: float = clamp(0.2 + (attraction_radius / 420.0), 0.25, 0.7)
	_aura.modulate = Color(1.0, 1.0, 1.0, alpha)

func _on_game_state_changed() -> void:
	_update_cursor_visual_from_progress()
	_update_aura_visual()

func _on_final_sequence_started() -> void:
	if _current_cursor_state != "final":
		_current_cursor_state = "final"
		set_cursor_visual("final")

func _on_body_entered(body: Node) -> void:
	if _game_manager != null and _game_manager.final_sequence_active:
		return
	if body.is_in_group("npc"):
		npc_detected.emit(body)
