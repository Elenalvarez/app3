extends Control

@onready var options = $Panel

func _ready():
	if "--server" in OS.get_cmdline_args():
		_on_play_button_pressed()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_exit_button_pressed():
	get_tree().quit()

func _on_options_button_pressed():
	options.visible = true

func _on_close_button_pressed():
	options.visible = false
