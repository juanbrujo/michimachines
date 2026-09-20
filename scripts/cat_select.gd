extends Control

const CAT_BUTTONS := ["NauButton", "CajuButton", "RomeoButton", "OsamaButton"]


func _ready() -> void:
	for index in CAT_BUTTONS.size():
		var button := get_node("CatGrid/%s" % CAT_BUTTONS[index]) as Button
		button.pressed.connect(_select_cat.bind(index))
	$BackButton.pressed.connect(_back_to_menu)


func _select_cat(index: int) -> void:
	RaceSettings.set_selected_cat(index)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
