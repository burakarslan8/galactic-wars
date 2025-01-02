extends Control

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_HSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


func _on_OptionButton_item_selected(index):
	print("Option selected:", index)
