extends Node2D

## Phase 1 playground. Temporary touch controls feed the same abstract actions
## as keyboard input, so this scene can be tested on desktop and phone.

const VIRTUAL_BUTTONS := {
	"steer_left": Vector2(31, 151),
	"steer_right": Vector2(69, 151),
	"brake": Vector2(251, 151),
	"accelerate": Vector2(289, 151),
}
const TOUCH_RADIUS := 17.0
const AI_WAYPOINTS := [
	Vector2(118, 31), Vector2(248, 31), Vector2(284, 65), Vector2(284, 121),
	Vector2(230, 150), Vector2(80, 150), Vector2(35, 114), Vector2(35, 64), Vector2(74, 31),
]
const CHECKPOINT_POSITIONS := [
	Vector2(118, 31), Vector2(248, 31), Vector2(284, 93), Vector2(230, 150), Vector2(80, 150), Vector2(35, 85),
]
const OilSpill := preload("res://scripts/oil_spill.gd")
const VictoryConfetti := preload("res://scripts/victory_confetti.gd")
const KitchenArt := preload("res://assets/cocina.png")

var active_touches: Dictionary = {}

@onready var michi: CatRacer = $Michi
@onready var speed_label: Label = $HUD/SpeedPanel/SpeedLabel
@onready var race_label: Label = $HUD/RacePanel/RaceLabel
@onready var race_manager: Node = $RaceManager
@onready var start_label: Label = $HUD/StartLabel
@onready var result_panel: PanelContainer = $HUD/ResultPanel
@onready var result_label: Label = $HUD/ResultPanel/ResultLabel
@onready var hint_label: Label = $HUD/Hint
@onready var power_label: Label = $HUD/PowerPanel/PowerLabel
@onready var standings_label: Label = $HUD/StandingsPanel/StandingsLabel
@onready var race_camera: Camera2D = $Michi/RaceCamera

var ai_waypoint_by_racer: Dictionary = {}
var is_paused := false
var touch_controls_visible := false
var player_won := false
var new_record := false
var ai_safety_by_racer: Dictionary = {}

const AI_LANE_BY_RACER := {"Nube": -8.0, "Tigre": 0.0, "Luna": 8.0}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("race_controller")
	touch_controls_visible = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	hint_label.text = "WASD / flechas / mando" if not touch_controls_visible else "Controles táctiles abajo"
	_configure_input_actions()
	_configure_racers_from_selection()
	_apply_difficulty()
	race_manager.call("setup",
		[$Michi, $Nube, $Tigre, $Luna],
		[$Checkpoints/Finish, $Checkpoints/Checkpoint1, $Checkpoints/Checkpoint2, $Checkpoints/Checkpoint3, $Checkpoints/Checkpoint4, $Checkpoints/Checkpoint5],
	)
	race_manager.racer_finished.connect(_on_racer_finished)
	for racer: CatRacer in [$Nube, $Tigre, $Luna]:
		# All rivals begin on the same first straight, already facing its entry.
		ai_waypoint_by_racer[racer.get_instance_id()] = 0
		racer.rotation = racer.position.angle_to_point(AI_WAYPOINTS[0])
	for racer: CatRacer in [$Nube, $Tigre, $Luna]:
		ai_safety_by_racer[racer.get_instance_id()] = {"position": racer.position, "stuck_time": 0.0}
	queue_redraw()


func _apply_difficulty() -> void:
	for racer: CatRacer in [$Nube, $Tigre, $Luna]:
		racer.max_forward_speed *= RaceSettings.speed_multiplier()
		racer.acceleration *= RaceSettings.acceleration_multiplier()


func _configure_racers_from_selection() -> void:
	var profiles: Array = RaceSettings.CAT_PROFILES.duplicate()
	var selected: Dictionary = RaceSettings.get_selected_profile()
	_configure_racer($Michi, selected, true)
	profiles.remove_at(RaceSettings.selected_cat)
	for index in profiles.size():
		_configure_racer([$Nube, $Tigre, $Luna][index], profiles[index], false)


func _configure_racer(racer: CatRacer, profile: Dictionary, is_player: bool) -> void:
	racer.racer_name = profile.name
	racer.fur_color = profile.fur
	racer.accent_color = profile.accent
	racer.max_forward_speed *= profile.speed
	racer.acceleration *= profile.acceleration
	racer.turn_rate *= profile.turn
	racer.traction *= profile.grip
	racer.collision_bounce *= profile.bounce
	racer.collision_speed_loss *= profile.impact_keep
	racer.set_visual(profile.visual)
	racer.refresh_name_tag()
	racer.queue_redraw()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		_set_race_paused(not is_paused)
	if is_paused:
		start_label.text = "PAUSA"
		return
	_update_ai_safety(delta)

	speed_label.text = "%03d MIAU" % roundi(absf(michi.drive_speed))
	race_label.text = race_manager.call("get_status", michi)
	_update_standings()
	start_label.text = race_manager.call("get_banner", michi)
	_update_power_hud()
	result_panel.visible = race_manager.call("is_race_complete")
	if result_panel.visible:
		result_label.text = race_manager.call("get_result_text", michi)
		if player_won:
			result_label.text += "\n%s" % ("NUEVO RÉCORD" if new_record else "RÉCORD: %s" % RaceSettings.format_time(RaceSettings.get_best_time(michi.racer_name)))
	if Input.is_action_just_pressed(&"reset"):
		_respawn_racer(michi)
	if Input.is_action_just_pressed(&"restart") and not race_manager.call("can_drive", michi):
		get_tree().reload_current_scene()
	queue_redraw()


func _set_race_paused(should_pause: bool) -> void:
	# Do not pause SceneTree itself: this root must still read Escape, and
	# inherited process modes can otherwise leave CharacterBody2D nodes asleep.
	is_paused = should_pause
	get_tree().paused = false
	race_manager.race_paused = should_pause
	for racer: CatRacer in [$Michi, $Nube, $Tigre, $Luna]:
		racer.race_paused = should_pause


func _on_racer_finished(racer: CatRacer, place: int) -> void:
	racer.celebrate_win()
	_focus_winner(racer)
	if racer != michi or place != 1:
		return
	player_won = true
	new_record = RaceSettings.register_best_time(michi.racer_name, race_manager.call("get_elapsed_time"))
	var confetti := VictoryConfetti.new()
	$HUD.add_child(confetti)


func _focus_winner(racer: CatRacer) -> void:
	if race_camera.get_parent() != racer:
		race_camera.reparent(racer)
	race_camera.position = Vector2.ZERO
	race_camera.rotation = 0.0


func get_drive_input() -> Dictionary:
	var accelerate := Input.get_action_strength(&"accelerate")
	var brake := Input.get_action_strength(&"brake")
	var steer := Input.get_axis(&"steer_left", &"steer_right")
	var gamepad_input := _get_gamepad_input()
	accelerate = maxf(accelerate, gamepad_input.accelerate)
	brake = maxf(brake, gamepad_input.brake)
	if absf(gamepad_input.steer) > absf(steer):
		steer = gamepad_input.steer
	for touch_position: Vector2 in active_touches.values():
		for action: String in VIRTUAL_BUTTONS:
			if touch_position.distance_to(VIRTUAL_BUTTONS[action]) > TOUCH_RADIUS:
				continue
			match action:
				"accelerate": accelerate = 1.0
				"brake": brake = 1.0
				"steer_left": steer = -1.0
				"steer_right": steer = 1.0
	return {"accelerate": accelerate, "brake": brake, "steer": steer}


func _get_gamepad_input() -> Dictionary:
	var result := {"accelerate": 0.0, "brake": 0.0, "steer": 0.0}
	for device in Input.get_connected_joypads():
		var steering: float = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
		if absf(steering) > 0.16:
			result.steer = steering
		if Input.is_joy_button_pressed(device, JOY_BUTTON_A) or Input.is_joy_button_pressed(device, JOY_BUTTON_RIGHT_SHOULDER):
			result.accelerate = 1.0
		if Input.is_joy_button_pressed(device, JOY_BUTTON_B) or Input.is_joy_button_pressed(device, JOY_BUTTON_LEFT_SHOULDER):
			result.brake = 1.0
	return result


func get_racer_input(racer: CatRacer) -> Dictionary:
	if not race_manager.call("can_drive", racer):
		return {"accelerate": 0.0, "brake": 0.0, "steer": 0.0}
	if racer == michi:
		return get_drive_input()
	return _get_ai_input(racer)


func activate_power(racer: CatRacer, power_type: String) -> bool:
	if not race_manager.call("can_drive", racer):
		return false
	match power_type:
		"speed":
			racer.activate_speed_boost(4.0)
		"quake":
			for other_racer: CatRacer in [$Michi, $Nube, $Tigre, $Luna]:
				if other_racer != racer:
					other_racer.apply_quake(1.35)
		"oil":
			var spill: Area2D = OilSpill.new()
			add_child(spill)
			spill.position = racer.position - Vector2.RIGHT.rotated(racer.rotation) * 13.0
	_update_power_hud()
	return true


func _update_power_hud() -> void:
	if michi.boost_time > 0.0:
		power_label.text = "RAPIDEZ %.1fs" % michi.boost_time
	else:
		power_label.text = "PODER AUTO"


func _update_standings() -> void:
	var lines: PackedStringArray = []
	var standings: Array[CatRacer] = race_manager.call("get_standings")
	for index in standings.size():
		lines.append("%d.º %s" % [index + 1, standings[index].racer_name])
	standings_label.text = "LUGAR\n%s" % "\n".join(lines)


func _get_ai_input(racer: CatRacer) -> Dictionary:
	var waypoint_index: int = ai_waypoint_by_racer.get(racer.get_instance_id(), 0)
	var waypoint: Vector2 = AI_WAYPOINTS[waypoint_index]
	var distance_to_waypoint := racer.position.distance_to(waypoint)
	if distance_to_waypoint < 18.0:
		waypoint_index = (waypoint_index + 1) % AI_WAYPOINTS.size()
		ai_waypoint_by_racer[racer.get_instance_id()] = waypoint_index
		waypoint = AI_WAYPOINTS[waypoint_index]
		distance_to_waypoint = racer.position.distance_to(waypoint)

	var skill := RaceSettings.ai_skill_multiplier()
	var skill_progress := clampf((skill - 0.76) / 0.44, 0.0, 1.0)
	var next_waypoint: Vector2 = AI_WAYPOINTS[(waypoint_index + 1) % AI_WAYPOINTS.size()]
	var anticipation_distance := lerpf(38.0, 68.0, skill_progress)
	var curve_progress := clampf(1.0 - distance_to_waypoint / anticipation_distance, 0.0, 1.0)
	var target := waypoint.lerp(next_waypoint, curve_progress * 0.48)
	var path_direction := waypoint.direction_to(next_waypoint)
	var lane_offset: float = AI_LANE_BY_RACER.get(racer.name, 0.0)
	var overtake_offset := _get_overtake_offset(racer, path_direction, skill_progress)
	lane_offset = clampf(lane_offset + overtake_offset, -11.0, 11.0)
	target += path_direction.rotated(PI * 0.5) * lane_offset

	var avoidance := Vector2.ZERO
	for other: CatRacer in [$Michi, $Nube, $Tigre, $Luna]:
		if other == racer:
			continue
		var separation := racer.position.distance_to(other.position)
		if separation > 0.1 and separation < 20.0:
			avoidance += other.position.direction_to(racer.position) * (20.0 - separation) * 0.42
	target += avoidance.limit_length(7.0)

	var forward := Vector2.RIGHT.rotated(racer.rotation)
	var desired_direction := racer.position.direction_to(target)
	var steering := clampf(forward.cross(desired_direction) * lerpf(2.2, 3.4, skill / 1.2), -1.0, 1.0)
	var angle_error := absf(forward.angle_to(desired_direction))
	var speed_ratio := absf(racer.drive_speed) / maxf(1.0, racer.max_forward_speed)
	var accelerate := 1.0
	var brake := 0.0
	if angle_error > 1.1:
		accelerate = 0.18
		brake = 1.0 if speed_ratio > lerpf(0.34, 0.48, skill / 1.2) else 0.0
	elif angle_error > 0.62:
		accelerate = 0.5
		brake = 0.35 if speed_ratio > lerpf(0.56, 0.72, skill / 1.2) else 0.0
	elif not is_zero_approx(overtake_offset) and speed_ratio < 0.9:
		# A clean straight lets the rival commit to the passing lane.
		accelerate = 1.0
	return {
		"accelerate": accelerate,
		"brake": brake,
		"steer": steering,
	}


func _get_overtake_offset(racer: CatRacer, path_direction: Vector2, skill_progress: float) -> float:
	var overtake_range := lerpf(18.0, 34.0, skill_progress)
	var closest_distance := INF
	for other: CatRacer in [$Michi, $Nube, $Tigre, $Luna]:
		if other == racer:
			continue
		var relative := other.position - racer.position
		var forward_distance := path_direction.dot(relative)
		var lateral_distance := absf(path_direction.cross(relative))
		if forward_distance > 2.0 and forward_distance < overtake_range and lateral_distance < 11.0:
			closest_distance = minf(closest_distance, forward_distance)
	if is_inf(closest_distance):
		return 0.0
	# Each rival has a stable preferred side, avoiding left/right indecision.
	var side := -1.0 if racer.get_instance_id() % 2 == 0 else 1.0
	return side * lerpf(4.5, 8.0, skill_progress)


func _update_ai_safety(delta: float) -> void:
	for racer: CatRacer in [$Nube, $Tigre, $Luna]:
		var safety: Dictionary = ai_safety_by_racer.get(racer.get_instance_id(), {"position": racer.position, "stuck_time": 0.0})
		var moved := racer.position.distance_to(safety.position)
		if race_manager.call("can_drive", racer) and absf(racer.drive_speed) > 22.0 and moved < 0.35:
			safety.stuck_time += delta
		else:
			safety.stuck_time = 0.0
		if safety.stuck_time > 0.65:
			racer.start_recovery(0.44)
			safety.stuck_time = 0.0
		safety.position = racer.position
		ai_safety_by_racer[racer.get_instance_id()] = safety


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			active_touches[touch.index] = to_local(touch.position)
		else:
			active_touches.erase(touch.index)
		queue_redraw()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		active_touches[drag.index] = to_local(drag.position)
		queue_redraw()


func _configure_input_actions() -> void:
	_ensure_action(&"accelerate", [KEY_W, KEY_UP])
	_ensure_action(&"brake", [KEY_S, KEY_DOWN])
	_ensure_action(&"steer_left", [KEY_A, KEY_LEFT])
	_ensure_action(&"steer_right", [KEY_D, KEY_RIGHT])
	_ensure_action(&"pause", [KEY_ESCAPE])
	_ensure_action(&"reset", [KEY_BACKSPACE])
	_ensure_action(&"restart", [KEY_R])


func _respawn_racer(racer: CatRacer) -> void:
	var checkpoint_index: int = race_manager.call("get_last_checkpoint_index", racer)
	var spawn_position: Vector2 = CHECKPOINT_POSITIONS[checkpoint_index]
	var next_position: Vector2 = CHECKPOINT_POSITIONS[(checkpoint_index + 1) % CHECKPOINT_POSITIONS.size()]
	racer.position = spawn_position + (next_position - spawn_position).normalized() * 17.0
	racer.rotation = spawn_position.angle_to_point(next_position)
	racer.velocity = Vector2.ZERO
	racer.drive_speed = 0.0


func _ensure_action(action: StringName, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for keycode: int in keycodes:
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)


func _draw() -> void:
	# Kitchen countertop and blue placemat used as the first temporary race circuit.
	draw_texture_rect_region(KitchenArt, Rect2(Vector2.ZERO, Vector2(320, 180)), Rect2(40, 54, 940, 440))
	draw_rect(Rect2(Vector2(12, 12), Vector2(296, 156)), Color("375777"))
	draw_rect(Rect2(Vector2(17, 17), Vector2(286, 146)), Color("203b59"))
	for y in range(28, 152, 16):
		draw_circle(Vector2(36, y), 1.3, Color("bad5dc"))
		draw_circle(Vector2(286, y), 1.3, Color("bad5dc"))
	# Board, pan and mug are rendered by their pixel-art Sprite2D children.
	# Fork decoration; it is intentionally non-blocking in this first course.
	draw_line(Vector2(42, 57), Vector2(77, 57), Color("d9e8ed"), 2.0)
	for tine_y in range(52, 63, 4):
		draw_line(Vector2(42, tine_y), Vector2(52, tine_y), Color("d9e8ed"), 1.0)
	# Temporary kitchen materials. These correspond to the handling zones in the scene.
	draw_rect(Rect2(Vector2(47, 104), Vector2(82, 28)), Color("a94a50"))
	draw_rect(Rect2(Vector2(50, 107), Vector2(76, 22)), Color("cb6260"), false, 1.0)
	draw_circle(Vector2(236, 118), 25.0, Color(0.86, 0.94, 0.98, 0.5))
	draw_circle(Vector2(252, 112), 11.0, Color(0.9, 0.96, 1.0, 0.35))
	for crumb_x in range(173, 211, 8):
		draw_circle(Vector2(crumb_x, 43 + (crumb_x % 3) * 3), 1.5, Color("dfb45b"))
	# Visible checkpoint gates mirror their collision shapes. The gold gate is the finish line.
	draw_line(Vector2(118, 17), Vector2(118, 57), Color("f3e7bd"), 2.0)
	draw_line(Vector2(248, 17), Vector2(248, 57), Color("7ee6ef", 0.8), 2.0)
	draw_line(Vector2(263, 93), Vector2(305, 93), Color("7ee6ef", 0.8), 2.0)
	draw_line(Vector2(230, 133), Vector2(230, 167), Color("7ee6ef", 0.8), 2.0)
	draw_line(Vector2(80, 133), Vector2(80, 167), Color("7ee6ef", 0.8), 2.0)
	draw_line(Vector2(18, 85), Vector2(52, 85), Color("7ee6ef", 0.8), 2.0)
	if touch_controls_visible:
		_draw_touch_controls()


func _draw_touch_controls() -> void:
	for action: String in VIRTUAL_BUTTONS:
		var center: Vector2 = VIRTUAL_BUTTONS[action]
		var active := _is_virtual_button_active(action)
		draw_circle(center, TOUCH_RADIUS, Color(0.62, 0.76, 0.87, 0.34 if active else 0.16))
		draw_arc(center, TOUCH_RADIUS, 0.0, TAU, 20, Color(0.85, 0.93, 0.98, 0.65), 1.0, true)
		var glyph: String = {"steer_left": "<", "steer_right": ">", "brake": "B", "accelerate": "+"}[action]
		draw_string(ThemeDB.fallback_font, center + Vector2(-3.0, 3.0), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color("edf7ff"))


func _is_virtual_button_active(action: String) -> bool:
	for touch_position: Vector2 in active_touches.values():
		if touch_position.distance_to(VIRTUAL_BUTTONS[action]) <= TOUCH_RADIUS:
			return true
	return false
