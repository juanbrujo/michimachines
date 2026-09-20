extends Control

@onready var start_button: Button = $MenuCard/Menu/StartButton
@onready var controls_label: Label = $MenuCard/Menu/ControlsLabel
@onready var difficulty_option: OptionButton = $MenuCard/Menu/DifficultyOption
@onready var cat_select_button: Button = $MenuCard/Menu/CatSelectButton


func _ready() -> void:
	start_button.pressed.connect(_start_race)
	$MenuCard/Menu/ControlsButton.pressed.connect(_toggle_controls)
	$MenuCard/Menu/QuitButton.pressed.connect(_quit_game)
	cat_select_button.pressed.connect(_open_cat_select)
	difficulty_option.select(RaceSettings.difficulty)
	difficulty_option.item_selected.connect(RaceSettings.set_difficulty)
	cat_select_button.text = "ELEGIR MICHI: %s" % RaceSettings.get_selected_profile().name
	start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		_start_race()


func _start_race() -> void:
	get_tree().change_scene_to_file("res://scenes/test_track.tscn")


func _toggle_controls() -> void:
	controls_label.visible = not controls_label.visible


func _open_cat_select() -> void:
	get_tree().change_scene_to_file("res://scenes/cat_select.tscn")


func _quit_game() -> void:
	get_tree().quit()
