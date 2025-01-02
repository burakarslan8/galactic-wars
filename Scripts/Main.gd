extends Control

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_SettingsButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")

func _on_ExitButton_pressed():
	get_tree().quit()
