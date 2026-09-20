extends Node2D

const LIFETIME := 5.5
const COLORS := [Color("ffcf65"), Color("74eaff"), Color("ff6b8a"), Color("a8ef7a"), Color("c59aff")]

var elapsed := 0.0


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	# HUD is scaled by two, so this is the 320×180 logical screen.
	for index in range(72):
		var x := fmod(float(index * 47 + 13), 324.0)
		var fall_speed := 26.0 + float(index % 5) * 8.0
		var y := fmod(float(index * 19) + elapsed * fall_speed, 202.0) - 10.0
		var sway := sin(elapsed * 5.0 + float(index) * 1.7) * 4.0
		var size := 1.5 + float(index % 3) * 0.7
		draw_rect(Rect2(Vector2(x + sway, y), Vector2(size, size * 1.8)), COLORS[index % COLORS.size()])
