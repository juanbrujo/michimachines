extends Node

var difficulty := 1
var selected_cat := 0

const CAT_PROFILES := [
	{"name": "Ñau", "description": "Rápido y resbaladizo", "fur": Color(0.48, 0.31, 0.25, 1), "accent": Color(1, 0.91, 0.72, 1), "visual": preload("res://assets/sprites/nau.png"), "speed": 1.08, "acceleration": 1.08, "turn": 0.96, "grip": 0.84, "bounce": 1.35, "impact_keep": 0.84},
	{"name": "Cajú", "description": "Pesada, firme en curvas", "fur": Color(0.46, 0.5, 0.56, 1), "accent": Color(0.82, 0.86, 0.9, 1), "visual": preload("res://assets/sprites/caju.png"), "speed": 0.88, "acceleration": 0.9, "turn": 1.08, "grip": 1.25, "bounce": 0.72, "impact_keep": 1.08},
	{"name": "Romeo", "description": "Muy rápido y liviano", "fur": Color(0.93, 0.42, 0.16, 1), "accent": Color(1, 0.77, 0.42, 1), "visual": preload("res://assets/sprites/romeo.png"), "speed": 1.1, "acceleration": 1.12, "turn": 0.94, "grip": 0.8, "bounce": 1.42, "impact_keep": 0.8},
	{"name": "Osama", "description": "Pesado, gran agarre", "fur": Color(0.1, 0.12, 0.17, 1), "accent": Color(0.42, 0.46, 0.54, 1), "visual": preload("res://assets/sprites/osama.png"), "speed": 0.86, "acceleration": 0.88, "turn": 1.06, "grip": 1.3, "bounce": 0.68, "impact_keep": 1.1},
]
const SAVE_PATH := "user://michi_machines_records.cfg"

var best_times: Dictionary = {}


func _ready() -> void:
	_load_records()


func set_difficulty(value: int) -> void:
	difficulty = clampi(value, 0, 2)


func set_selected_cat(value: int) -> void:
	selected_cat = clampi(value, 0, CAT_PROFILES.size() - 1)


func get_selected_profile() -> Dictionary:
	return CAT_PROFILES[selected_cat]


func register_best_time(cat_name: String, time_in_seconds: float) -> bool:
	var current_best: float = best_times.get(cat_name, INF)
	if time_in_seconds >= current_best:
		return false
	best_times[cat_name] = time_in_seconds
	var config := ConfigFile.new()
	config.set_value("records", cat_name, time_in_seconds)
	config.save(SAVE_PATH)
	return true


func get_best_time(cat_name: String) -> float:
	return best_times.get(cat_name, -1.0)


func format_time(time_in_seconds: float) -> String:
	if time_in_seconds < 0.0:
		return "—"
	return "%02d:%05.2f" % [int(time_in_seconds) / 60, fmod(time_in_seconds, 60.0)]


func _load_records() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	for cat_name in config.get_section_keys("records"):
		best_times[cat_name] = config.get_value("records", cat_name, -1.0)


func speed_multiplier() -> float:
	match difficulty:
		0:
			return 0.78
		2:
			return 1.16
	return 1.0


func acceleration_multiplier() -> float:
	match difficulty:
		0:
			return 0.82
		2:
			return 1.12
	return 1.0


func ai_skill_multiplier() -> float:
	match difficulty:
		0:
			return 0.76
		2:
			return 1.2
	return 1.0
