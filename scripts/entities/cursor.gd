extends Node2D
class_name CursorEntity

signal npc_detected(npc: Node)

enum InfluenceStrength {
	NONE,
	WEAK,
	MEDIUM,
	STRONG
}

static var CURSOR_TEXTURES: Dictionary = {
	"base": preload("res://assets/sprites/cursor/cursor_base.png"),
	"glow": preload("res://assets/sprites/cursor/cursor_glow.png"),
	"cult": preload("res://assets/sprites/cursor/cursor_cult.png"),
	"divine": preload("res://assets/sprites/cursor/cursor_divine.png"),
	"final": preload("res://assets/sprites/cursor/cursor_final.png")
}

const CURSOR_AURA_TEXTURE: Texture2D = preload("res://assets/vfx/cursor/cursor_aura.png")
const CURSOR_TRAIL_TEXTURE: Texture2D = preload("res://assets/vfx/cursor/cursor_trail.png")
const CURSOR_FLASH_TEXTURE: Texture2D = preload("res://assets/vfx/cursor/cursor_flash.png")
const CURSOR_RIPPLE_TEXTURE: Texture2D = preload("res://assets/vfx/cursor/cursor_ripple.png")
const MOMENTUM_MAX: float = 10.0
const MOMENTUM_DECAY_STEP: float = 1.0
const MOMENTUM_DECAY_INTERVAL: float = 2.0
const PRESSURE_MAX: float = 100.0
const PRESSURE_DECAY_STEP: float = 1.0
const PRESSURE_DECAY_INTERVAL: float = 4.0

@export var game_manager_path: NodePath
@export var attraction_radius: float = 60.0
@export var inner_ritual_radius: float = 40.0
@export var influence_radius: float = 120.0
@export var outer_awareness_radius: float = 200.0

@onready var _area: Area2D = $Area2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _aura: Sprite2D = $Aura
@onready var _aura_pulse: Sprite2D = $AuraPulse

var _game_manager: GameManager
var _last_position: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.UP
var _current_cursor_state: String = ""
var _world_vfx_layer: Node2D
var _aura_pulse_tween: Tween
var _aura_pulse_base_scale: float = 1.0
var _trail_accumulator: float = 0.0
var _trail_interval: float = 0.06
var cult_momentum: float = 0.0
var _momentum_decay_timer: float = 0.0
var cult_pressure: float = 0.0
var _pressure_decay_timer: float = 0.0
var _base_inner_ritual_radius: float = 40.0
var _base_influence_radius: float = 120.0
var _base_outer_awareness_radius: float = 200.0
var _base_attraction_radius: float = 60.0

func _ready() -> void:
	_game_manager = get_node_or_null(game_manager_path) as GameManager
	_last_position = global_position
	_area.body_entered.connect(_on_body_entered)
	_base_attraction_radius = attraction_radius
	_base_inner_ritual_radius = inner_ritual_radius
	_base_influence_radius = influence_radius
	_base_outer_awareness_radius = outer_awareness_radius
	_aura.texture = CURSOR_AURA_TEXTURE
	_aura_pulse.texture = CURSOR_AURA_TEXTURE
	_ensure_world_vfx_layer()
	if _game_manager != null:
		_game_manager.state_changed.connect(_on_game_state_changed)
		_game_manager.final_sequence_started.connect(_on_final_sequence_started)
		_game_manager.npc_converted.connect(_on_npc_converted)
	_update_cursor_visual_from_progress()
	_update_aura_visual()
	_restart_idle_aura_pulse()

func _process(delta: float) -> void:
	if _game_manager == null:
		return

	if _game_manager.is_gameplay_phase() and not _game_manager.cursor_locked:
		global_position = get_global_mouse_position()

	var delta_pos: Vector2 = global_position - _last_position
	var moved_distance: float = delta_pos.length()
	if moved_distance > 0.001:
		movement_direction = delta_pos.normalized()

	if moved_distance > 1.5 and _game_manager.is_gameplay_phase() and not _game_manager.cursor_locked:
		_trail_accumulator += delta
		if _trail_accumulator >= _trail_interval:
			_trail_accumulator = 0.0
			_spawn_movement_trail()
	else:
		_trail_accumulator = 0.0

	_last_position = global_position

	_update_momentum_decay(delta)
	_update_pressure_decay(delta)
	_base_attraction_radius = _game_manager.get_effective_attraction_radius()
	_update_dynamic_influence_fields()
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

	if _aura_pulse != null:
		var pulse_base: float = radius_scale * 0.92
		if abs(pulse_base - _aura_pulse_base_scale) > 0.01:
			_aura_pulse_base_scale = pulse_base
			_restart_idle_aura_pulse()
		var momentum_ratio: float = cult_momentum / MOMENTUM_MAX
		_aura_pulse.modulate = Color(0.92 + (momentum_ratio * 0.08), 0.78, 1.0, alpha * 0.35)

func _on_game_state_changed() -> void:
	_update_cursor_visual_from_progress()
	_update_aura_visual()

func _on_final_sequence_started() -> void:
	if _current_cursor_state != "final":
		_current_cursor_state = "final"
		set_cursor_visual("final")

func _on_body_entered(body: Node) -> void:
	if _game_manager != null and (_game_manager.final_sequence_active or not _game_manager.is_gameplay_phase()):
		return
	if body.is_in_group("npc"):
		npc_detected.emit(body)

func _on_npc_converted() -> void:
	if _game_manager == null:
		return
	if _game_manager.final_sequence_active:
		return
	_apply_momentum_gain(1.0)
	_apply_pressure_gain(1.0)
	_update_dynamic_influence_fields()
	var intensity: float = _get_momentum_fx_intensity()
	_spawn_conversion_flash(global_position, intensity)
	_spawn_conversion_ripple(global_position, intensity)

func _restart_idle_aura_pulse() -> void:
	if _aura_pulse == null:
		return
	if _aura_pulse_tween != null and _aura_pulse_tween.is_running():
		_aura_pulse_tween.kill()
	var base_scale: Vector2 = Vector2(_aura_pulse_base_scale, _aura_pulse_base_scale)
	_aura_pulse.scale = base_scale
	_aura_pulse_tween = create_tween()
	_aura_pulse_tween.set_loops()
	_aura_pulse_tween.tween_property(_aura_pulse, "scale", base_scale * 1.08, 0.6)
	_aura_pulse_tween.tween_property(_aura_pulse, "scale", base_scale, 0.6)

func _ensure_world_vfx_layer() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	var existing: Node = parent_node.get_node_or_null("CursorVFXLayer")
	if existing is Node2D:
		_world_vfx_layer = existing as Node2D
		return
	var layer: Node2D = Node2D.new()
	layer.name = "CursorVFXLayer"
	layer.z_index = -1
	parent_node.call_deferred("add_child", layer)
	_world_vfx_layer = layer

func _spawn_movement_trail() -> void:
	if _world_vfx_layer == null:
		_ensure_world_vfx_layer()
	if _world_vfx_layer == null:
		return
	var trail: Sprite2D = Sprite2D.new()
	trail.texture = CURSOR_TRAIL_TEXTURE
	trail.global_position = global_position
	trail.modulate = Color(0.92, 0.78, 1.0, 0.26)
	trail.scale = Vector2(0.42, 0.42)
	trail.z_index = -1
	_world_vfx_layer.add_child(trail)
	var tween: Tween = trail.create_tween()
	tween.tween_property(trail, "scale", Vector2(0.2, 0.2), 0.3)
	tween.parallel().tween_property(trail, "modulate:a", 0.0, 0.3)
	tween.finished.connect(_queue_free_if_valid.bind(trail))

func _spawn_conversion_flash(world_position: Vector2, intensity: float = 1.0) -> void:
	if _world_vfx_layer == null:
		_ensure_world_vfx_layer()
	if _world_vfx_layer == null:
		return
	var flash: Sprite2D = Sprite2D.new()
	flash.texture = CURSOR_FLASH_TEXTURE
	flash.global_position = world_position
	flash.modulate = Color(1.0, 0.92, 0.62, 1.0)
	flash.scale = Vector2(0.8, 0.8) * intensity
	flash.z_index = 1
	_world_vfx_layer.add_child(flash)
	var tween: Tween = flash.create_tween()
	tween.tween_property(flash, "scale", Vector2(1.4, 1.4) * intensity, 0.25)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, 0.25)
	tween.finished.connect(_queue_free_if_valid.bind(flash))

func _spawn_conversion_ripple(world_position: Vector2, intensity: float = 1.0) -> void:
	if _world_vfx_layer == null:
		_ensure_world_vfx_layer()
	if _world_vfx_layer == null:
		return
	var ripple: Sprite2D = Sprite2D.new()
	ripple.texture = CURSOR_RIPPLE_TEXTURE
	ripple.global_position = world_position
	ripple.modulate = Color(0.86, 0.72, 1.0, 0.8)
	ripple.scale = Vector2.ONE * max(0.75, intensity * 0.92)
	ripple.z_index = 0
	_world_vfx_layer.add_child(ripple)
	var tween: Tween = ripple.create_tween()
	tween.tween_property(ripple, "scale", Vector2(2.5, 2.5) * intensity, 0.4)
	tween.parallel().tween_property(ripple, "modulate:a", 0.0, 0.4)
	tween.finished.connect(_queue_free_if_valid.bind(ripple))

func spawn_conversion_ripple(world_position: Vector2) -> void:
	_spawn_conversion_ripple(world_position, _get_momentum_fx_intensity())

func get_influence_strength_for_position(world_position: Vector2) -> int:
	var distance_to_cursor: float = global_position.distance_to(world_position)
	if distance_to_cursor < inner_ritual_radius:
		return InfluenceStrength.STRONG
	if distance_to_cursor < influence_radius:
		return InfluenceStrength.MEDIUM
	if distance_to_cursor < outer_awareness_radius:
		return InfluenceStrength.WEAK
	return InfluenceStrength.NONE

func _apply_momentum_gain(amount: float) -> void:
	cult_momentum = clamp(cult_momentum + amount, 0.0, MOMENTUM_MAX)
	_momentum_decay_timer = 0.0

func _update_momentum_decay(delta: float) -> void:
	if cult_momentum <= 0.0:
		return
	_momentum_decay_timer += delta
	if _momentum_decay_timer < MOMENTUM_DECAY_INTERVAL:
		return
	_momentum_decay_timer = 0.0
	cult_momentum = max(0.0, cult_momentum - MOMENTUM_DECAY_STEP)

func _apply_pressure_gain(amount: float) -> void:
	cult_pressure = clamp(cult_pressure + amount, 0.0, PRESSURE_MAX)
	_pressure_decay_timer = 0.0

func _update_pressure_decay(delta: float) -> void:
	if cult_pressure <= 0.0:
		return
	_pressure_decay_timer += delta
	if _pressure_decay_timer < PRESSURE_DECAY_INTERVAL:
		return
	_pressure_decay_timer = 0.0
	cult_pressure = max(0.0, cult_pressure - PRESSURE_DECAY_STEP)

func _update_dynamic_influence_fields() -> void:
	var momentum_ratio: float = cult_momentum / MOMENTUM_MAX
	var pressure_ratio: float = cult_pressure / PRESSURE_MAX
	var attraction_bonus: float = max(0.0, (cult_momentum * 3.5) - (cult_pressure * 0.10))
	var influence_bonus: float = max(0.0, (cult_momentum * 5.0) - (cult_pressure * 0.20))
	attraction_radius = _base_attraction_radius + attraction_bonus
	inner_ritual_radius = _base_inner_ritual_radius + (influence_bonus * 0.35)
	influence_radius = _base_influence_radius + influence_bonus
	outer_awareness_radius = _base_outer_awareness_radius + (influence_bonus * 0.75)
	if _aura_pulse != null:
		var pulse_r: float = 0.92 + (momentum_ratio * 0.08) + (pressure_ratio * 0.05)
		var pulse_g: float = 0.78 - (pressure_ratio * 0.08)
		_aura_pulse.modulate = Color(pulse_r, pulse_g, 1.0, _aura_pulse.modulate.a)

func get_civilian_pressure_modifier() -> float:
	return clamp(1.0 - ((cult_pressure / PRESSURE_MAX) * 0.35), 0.65, 1.0)

func get_skeptic_pressure_modifier() -> float:
	return clamp(1.0 + ((cult_pressure / PRESSURE_MAX) * 0.50), 1.0, 1.5)

func get_cultist_tightening_modifier() -> float:
	return clamp(1.0 - ((cult_pressure / PRESSURE_MAX) * 0.20), 0.8, 1.0)

func get_pressure_ratio() -> float:
	return cult_pressure / PRESSURE_MAX

func _get_momentum_fx_intensity() -> float:
	return 1.0 + (cult_momentum * 0.05)

func _queue_free_if_valid(node: Node) -> void:
	if node != null and is_instance_valid(node):
		node.queue_free()





















