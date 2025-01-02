extends Control

signal leave_lobby

@onready var lobby_label = $LobbyIDLabel
@onready var user_list = $ScrollContainer/VBoxContainer
@onready var leave_button = $LeaveButton

var lobby_id: int = -1

func _ready():
	leave_button.connect("pressed", Callable(self, "_on_leave_button_pressed"))

func update_lobby(lobby_id: int, users: Array):
	self.lobby_id = lobby_id
	lobby_label.text = "Lobby ID: %d" % lobby_id

	for child in user_list.get_children():
		child.queue_free()

	for user in users:
		var label = Label.new()
		label.text = str(user)
		user_list.add_child(label)

func _on_leave_button_pressed():
	emit_signal("leave_lobby", lobby_id)
