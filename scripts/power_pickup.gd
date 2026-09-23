extends Area2D

const POWER_TEXTURES := {
	"speed": preload("res://assets/sprites/power_speed.png"),
	"quake": preload("res://assets/sprites/power_quake.png"),
	"oil": preload("res://assets/sprites/power_oil.png"),
}

@export_enum("speed", "quake", "oil") var power_type := "speed"
@export var respawn_seconds := 24.0
@export var initial_delay := 0.0

var available := true


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_add_power_visual()
	if initial_delay > 0.0:
		available = false
		set_deferred("monitoring", false)
		hide()
		get_tree().create_timer(initial_delay).timeout.connect(_respawn)
	queue_redraw()


func _add_power_visual() -> void:
	var visual := Sprite2D.new()
	visual.texture = POWER_TEXTURES[power_type]
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.scale = Vector2(0.29, 0.29)
	add_child(visual)


func _on_body_entered(body: Node2D) -> void:
	if not available or not body is CatRacer:
		return
	var race_controller := get_tree().get_first_node_in_group("race_controller")
	if race_controller == null:
		return
	if not race_controller.activate_power(body as CatRacer, power_type):
		return
	available = false
	set_deferred("monitoring", false)
	hide()
	get_tree().create_timer(respawn_seconds).timeout.connect(_respawn)


func _respawn() -> void:
	available = true
	set_deferred("monitoring", true)
	show()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 1.0, 1.0, 0.15))
