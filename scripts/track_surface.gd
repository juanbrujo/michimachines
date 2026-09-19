extends Area2D

## A reusable handling zone. Tracks can combine these without coupling their art
## to vehicle physics: e.g. rugs slow, spills reduce traction, wood is neutral.

@export var surface_name := "Madera"
@export_range(0.2, 1.2) var speed_multiplier := 1.0
@export_range(0.1, 1.5) var traction_multiplier := 1.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_surface"):
		body.set_surface(get_instance_id(), surface_name, speed_multiplier, traction_multiplier)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("clear_surface"):
		body.clear_surface(get_instance_id())
