class_name CatRacer
extends CharacterBody2D

## Arcade controller for a top-down racing cat. Art and handling are independent
## so final sprites and per-cat stats can be added without changing race systems.

@export_category("Handling")
@export var max_forward_speed := 220.0
@export var max_reverse_speed := 72.0
@export var acceleration := 340.0
@export var braking := 390.0
@export var rolling_drag := 75.0
@export var turn_rate := 5.2
@export var traction := 16.0
@export var collision_bounce := 0.28
@export_range(0.0, 1.0) var collision_speed_loss := 0.68

@export_category("Appearance")
@export var fur_color := Color("f2a53a")
@export var accent_color := Color("fff1cc")
@export var racer_name := "Michi"
@export var ai_controlled := false

var drive_speed := 0.0
var last_impact := 0.0
var tail_time := 0.0
var recovery_time := 0.0
var recovery_turn := 1.0
var boost_time := 0.0
var stun_time := 0.0
var surface_id := 0
var surface_name := "Madera"
var surface_speed_multiplier := 1.0
var surface_traction_multiplier := 1.0


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	queue_redraw()


func _physics_process(delta: float) -> void:
	tail_time += delta
	boost_time = maxf(0.0, boost_time - delta)
	stun_time = maxf(0.0, stun_time - delta)
	var controls := _read_controls()
	if stun_time > 0.0:
		drive_speed = move_toward(drive_speed, 0.0, braking * delta)
		velocity = velocity.lerp(Vector2.ZERO, minf(1.0, 7.0 * delta))
		rotation += recovery_turn * 4.5 * delta
	elif recovery_time > 0.0:
		recovery_time -= delta
		drive_speed = move_toward(drive_speed, -max_reverse_speed * surface_speed_multiplier * 0.8, braking * delta)
		rotation += recovery_turn * turn_rate * 0.72 * delta
	else:
		_update_drive_speed(controls.accelerate, controls.brake, delta)
		_update_heading(controls.steer, delta)

	var forward := Vector2.RIGHT.rotated(rotation)
	var desired_velocity := forward * drive_speed
	velocity = velocity.lerp(desired_velocity, minf(1.0, traction * surface_traction_multiplier * delta))
	move_and_slide()
	_resolve_impacts()
	queue_redraw()


func _read_controls() -> Dictionary:
	var track := get_parent()
	if track != null and track.has_method("get_racer_input"):
		return track.get_racer_input(self)
	return {"accelerate": 0.0, "brake": 0.0, "steer": 0.0}


func _update_drive_speed(accelerate_input: float, brake_input: float, delta: float) -> void:
	var boost_multiplier := 1.45 if boost_time > 0.0 else 1.0
	var forward_speed_limit := max_forward_speed * surface_speed_multiplier * boost_multiplier
	var reverse_speed_limit := max_reverse_speed * surface_speed_multiplier
	if accelerate_input > 0.0:
		drive_speed = move_toward(drive_speed, forward_speed_limit, acceleration * accelerate_input * delta)
	elif brake_input > 0.0:
		drive_speed = move_toward(drive_speed, -reverse_speed_limit, braking * brake_input * delta)
	else:
		drive_speed = move_toward(drive_speed, 0.0, rolling_drag * delta)


func _update_heading(steer_input: float, delta: float) -> void:
	if is_zero_approx(steer_input):
		return
	var speed_ratio := clampf(absf(drive_speed) / max_forward_speed, 0.38, 1.0)
	var direction := 1.0 if drive_speed >= 0.0 else -1.0
	rotation += steer_input * turn_rate * speed_ratio * direction * delta


func _resolve_impacts() -> void:
	if get_slide_collision_count() == 0:
		last_impact = maxf(0.0, last_impact - 0.08)
		return
	var collision := get_last_slide_collision()
	if collision == null:
		return
	last_impact = minf(1.0, absf(drive_speed) / max_forward_speed)
	velocity = velocity.bounce(collision.get_normal()) * collision_bounce
	drive_speed *= collision_speed_loss
	if ai_controlled:
		recovery_time = 0.42
		recovery_turn = -1.0 if get_instance_id() % 2 == 0 else 1.0


func set_surface(new_surface_id: int, new_surface_name: String, new_speed_multiplier: float, new_traction_multiplier: float) -> void:
	surface_id = new_surface_id
	surface_name = new_surface_name
	surface_speed_multiplier = new_speed_multiplier
	surface_traction_multiplier = new_traction_multiplier


func clear_surface(leaving_surface_id: int) -> void:
	if leaving_surface_id != surface_id:
		return
	surface_id = 0
	surface_name = "Madera"
	surface_speed_multiplier = 1.0
	surface_traction_multiplier = 1.0


func activate_speed_boost(duration: float) -> void:
	boost_time = maxf(boost_time, duration)


func apply_quake(duration: float) -> void:
	stun_time = maxf(stun_time, duration)
	recovery_turn = -1.0 if get_instance_id() % 2 == 0 else 1.0


func _draw() -> void:
	# Placeholder cat rendered in code until final pixel sprites arrive.
	draw_circle(Vector2(1.5, 2.0), 6.2, Color(0.02, 0.03, 0.06, 0.34))
	var speed_ratio := absf(drive_speed) / max_forward_speed
	if speed_ratio > 0.32:
		var dust_alpha := minf(0.42, speed_ratio * 0.38)
		draw_circle(Vector2(-8.0, -3.0), 1.6, Color(0.91, 0.86, 0.69, dust_alpha))
		draw_circle(Vector2(-11.0, 2.5), 2.0, Color(0.91, 0.86, 0.69, dust_alpha * 0.75))
	draw_line(Vector2(-4.5, 0.0), Vector2(-10.5, sin(tail_time * 10.0) * 2.0), fur_color.darkened(0.2), 2.2, true)
	draw_circle(Vector2.ZERO, 6.0, fur_color)
	draw_circle(Vector2(3.0, 0.0), 4.8, accent_color)
	draw_colored_polygon(PackedVector2Array([Vector2(2.0, -3.0), Vector2(4.5, -8.0), Vector2(6.0, -2.0)]), fur_color)
	draw_colored_polygon(PackedVector2Array([Vector2(2.0, 3.0), Vector2(4.5, 8.0), Vector2(6.0, 2.0)]), fur_color)
	draw_circle(Vector2(5.4, -1.6), 0.7, Color("17202c"))
	draw_circle(Vector2(5.4, 1.6), 0.7, Color("17202c"))
	draw_line(Vector2(6.2, 0.0), Vector2(8.2, 0.0), Color("17202c"), 0.8, true)
	if last_impact > 0.05:
		draw_arc(Vector2.ZERO, 9.0, 0.0, TAU, 16, Color(1.0, 0.92, 0.45, last_impact), 1.0, false)
	if boost_time > 0.0:
		draw_arc(Vector2.ZERO, 10.5, 0.0, TAU, 16, Color(0.35, 0.92, 1.0, 0.8), 1.0, false)
	if stun_time > 0.0:
		draw_circle(Vector2(0.0, -10.0), 1.4, Color("ffcf65"))
