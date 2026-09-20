extends Area2D

const LIFETIME := 6.0


func _ready() -> void:
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 18.0
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()
	get_tree().create_timer(LIFETIME).timeout.connect(_expire)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_surface"):
		body.set_surface(get_instance_id(), "Aceite", 0.56, 0.22)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("clear_surface"):
		body.clear_surface(get_instance_id())


func _expire() -> void:
	for body: Node2D in get_overlapping_bodies():
		if body.has_method("clear_surface"):
			body.clear_surface(get_instance_id())
	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 17.0, Color(0.08, 0.07, 0.13, 0.72))
	draw_circle(Vector2(7, -4), 8.0, Color(0.12, 0.1, 0.19, 0.72))
	draw_circle(Vector2(-8, 5), 7.0, Color(0.12, 0.1, 0.19, 0.72))
	draw_arc(Vector2.ZERO, 13.0, 3.6, 5.4, 9, Color(0.58, 0.43, 0.83, 0.65), 1.0, true)
