class_name RaceManager
extends Node

signal racer_finished(racer: CatRacer, place: int)
signal race_started
signal race_completed

@export var laps_to_win := 3

var racers: Array[CatRacer] = []
var checkpoints: Array[Area2D] = []
var progress_by_racer: Dictionary = {}
var finish_order: Array[CatRacer] = []
var countdown := 3.0
var elapsed_time := 0.0
var race_active := false
var race_complete := false
var race_paused := false
var winner: CatRacer
var start_flash := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func setup(race_racers: Array, race_checkpoints: Array) -> void:
	racers.clear()
	checkpoints.clear()
	for race_racer in race_racers:
		racers.append(race_racer as CatRacer)
	for race_checkpoint in race_checkpoints:
		checkpoints.append(race_checkpoint as Area2D)
	for checkpoint_index in checkpoints.size():
		checkpoints[checkpoint_index].body_entered.connect(_on_checkpoint_entered.bind(checkpoint_index))
	for racer in racers:
		# Racers start before the finish line and must visit checkpoints 1..N first.
		progress_by_racer[racer.get_instance_id()] = {"lap": 0, "next_checkpoint": 1, "finished": false}


func _process(delta: float) -> void:
	if race_paused:
		return
	if race_complete:
		return
	if not race_active:
		countdown -= delta
		if countdown <= 0.0:
			race_active = true
			start_flash = 0.8
			race_started.emit()
		return
	start_flash = maxf(0.0, start_flash - delta)
	elapsed_time += delta


func can_drive(racer: CatRacer) -> bool:
	var data: Dictionary = progress_by_racer.get(racer.get_instance_id(), {})
	return race_active and not race_complete and not data.get("finished", false)


func get_banner(player: CatRacer) -> String:
	if race_complete:
		return "META"
	if not race_active:
		return "%d\nPREPÁRATE" % ceili(countdown)
	if start_flash > 0.0:
		return "¡YA!"
	return _format_time(elapsed_time)


func is_race_complete() -> bool:
	return race_complete


func get_result_text(player: CatRacer) -> String:
	var standings := get_standings()
	var player_place := standings.find(player) + 1
	var outcome := "GANASTE" if winner == player else "GANÓ %s" % winner.racer_name
	var player_result := "TÚ: %d.º" % player_place
	if player_place >= racers.size():
		player_result = "TÚ: ÚLTIMO"
	var podium_names: PackedStringArray = []
	for index in min(3, standings.size()):
		podium_names.append(standings[index].racer_name)
	return "%s\n%s · %s\nPODIO: %s\nR PARA REINTENTAR" % [outcome, player_result, _format_time(elapsed_time), " · ".join(podium_names)]


func get_elapsed_time() -> float:
	return elapsed_time


func get_last_checkpoint_index(racer: CatRacer) -> int:
	var data: Dictionary = progress_by_racer.get(racer.get_instance_id(), {})
	return posmod(data.get("next_checkpoint", 1) - 1, checkpoints.size())


func get_status(racer: CatRacer) -> String:
	var data: Dictionary = progress_by_racer.get(racer.get_instance_id(), {})
	if data.is_empty():
		return "Preparando carrera"
	if data.finished:
		return "META · %d.º" % (finish_order.find(racer) + 1)
	return "Vuelta %d/%d · %d.º" % [data.lap + 1, laps_to_win, get_position(racer)]


func get_position(racer: CatRacer) -> int:
	var ordered := racers.duplicate()
	ordered.sort_custom(func(a: CatRacer, b: CatRacer) -> bool: return _progress_score(a) > _progress_score(b))
	return ordered.find(racer) + 1


func get_standings() -> Array[CatRacer]:
	var ordered := racers.duplicate()
	ordered.sort_custom(func(a: CatRacer, b: CatRacer) -> bool: return _progress_score(a) > _progress_score(b))
	return ordered


func _progress_score(racer: CatRacer) -> float:
	var data: Dictionary = progress_by_racer.get(racer.get_instance_id(), {})
	if data.is_empty():
		return 0.0
	var completed_checkpoint := posmod(data.next_checkpoint - 1, checkpoints.size())
	return data.lap * checkpoints.size() + completed_checkpoint


func _on_checkpoint_entered(body: Node2D, checkpoint_index: int) -> void:
	if not body is CatRacer:
		return
	var racer := body as CatRacer
	var data: Dictionary = progress_by_racer.get(racer.get_instance_id(), {})
	if data.is_empty() or data.finished or data.next_checkpoint != checkpoint_index:
		return

	if checkpoint_index == 0:
		data.lap += 1
		if data.lap >= laps_to_win:
			data.finished = true
			finish_order.append(racer)
			progress_by_racer[racer.get_instance_id()] = data
			racer_finished.emit(racer, finish_order.size())
			winner = racer
			race_complete = true
			race_active = false
			race_completed.emit()
			return
	data.next_checkpoint = (checkpoint_index + 1) % checkpoints.size()
	progress_by_racer[racer.get_instance_id()] = data


func _format_time(time_in_seconds: float) -> String:
	var minutes := int(time_in_seconds) / 60
	var seconds := fmod(time_in_seconds, 60.0)
	return "%02d:%05.2f" % [minutes, seconds]
