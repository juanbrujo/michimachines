extends Area2D

@export_enum("speed", "quake", "oil") var power_type := "speed"
@export var respawn_seconds := 24.0
@export var initial_delay := 0.0

var available := true


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if initial_delay > 0.0:
		available = false
		set_deferred("monitoring", false)
		hide()
		get_tree().create_timer(initial_delay).timeout.connect(_respawn)
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if not available or not body is CatRacer:
		return
	var race_controller := get_tree().get_first_node_in_group("race_controller")
	if race_controller == null:
		return
	race_controller.activate_power(body as CatRacer, power_type)
	available = false
	set_deferred("monitoring", false)
	hide()
	get_tree().create_timer(respawn_seconds).timeout.connect(_respawn)


func _respawn() -> void:
	available = true
	set_deferred("monitoring", true)
	show()


func _draw() -> void:
	var glow := Color("74eaff") if power_type == "speed" else Color("ffb14d") if power_type == "quake" else Color("242130")
	draw_circle(Vector2.ZERO, 8.0, Color(1.0, 1.0, 1.0, 0.18))
	draw_circle(Vector2.ZERO, 5.5, glow)
	match power_type:
		"speed":
			draw_colored_polygon(PackedVector2Array([Vector2(-1, -6), Vector2(5, -1), Vector2(1, -1), Vector2(3, 6), Vector2(-5, 1), Vector2(-1, 1)]), Color("efffff"))
		"quake":
			draw_line(Vector2(-5, 1), Vector2(-2, -3), Color("fff0c2"), 1.5)
			draw_line(Vector2(-2, -3), Vector2(1, 3), Color("fff0c2"), 1.5)
			draw_line(Vector2(1, 3), Vector2(5, -2), Color("fff0c2"), 1.5)
		"oil":
			draw_circle(Vector2.ZERO, 3.3, Color("55506a"))
