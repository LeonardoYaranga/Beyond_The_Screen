extends Control

signal start_game()
@onready var buttons_v_box = %ButtonsVBox

func _on_start_game_button_pressed() -> void:
	print("MainMenu: Boton Start pressed")
	start_game.emit()
	hide()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

		
func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		focus_button()
