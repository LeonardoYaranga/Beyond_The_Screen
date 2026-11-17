extends Control

signal start_game
signal continue_game
signal show_credits
@onready var buttons_v_box = %ButtonsVBox
@onready var texture_rect = $TextureRect
@onready var audio_stream_player = $AudioStreamPlayer
@onready var continue_button = $MarginContainer/VBoxContainer/ButtonsVBox/ContinueGameButton
@onready var start_button: Button = $MarginContainer/VBoxContainer/ButtonsVBox/StartGameButton

func _ready() -> void:
	texture_rect.modulate = Color(1, 1, 1, 0.6)
	# Ocultar ContinueButton por defecto
	verify_state_of_continue_button()
	
	focus_button()
	#print("MainMenu.gd: TextureRect texture:", texture_rect.texture, "size:", texture_rect.size)

func verify_state_of_continue_button() -> void:
	if continue_button:
		continue_button.hide()
	# Mostrar ContinueButton si hay progreso
	if GameManager.death_counter > 0 or not GameManager.visited_rooms.is_empty() or GameManager.last_room_visited != "":
		continue_button.show()
		print("MainMenu.gd: Mostrando ContinueButton (progreso detectado)")

func hide_menu() -> void:
	if audio_stream_player and audio_stream_player.stream:
		audio_stream_player.stop()
	hide()
	print("MainMenu.gd: Música del menú detenida y menu oculto")
	
func play_music() -> void:
	if not audio_stream_player.playing:
		audio_stream_player.play()
		print("MainMenu.gd: Reproduciendo música del menú")
	
func _on_start_game_button_pressed() -> void:
	print("MainMenu.gd: Boton Start pressed")
	hide_menu()
	start_game.emit()
	
func _on_continue_game_button_pressed() -> void:
	print("MainMenu.gd: Button continue pressed")
	hide_menu()
	continue_game.emit()
	
func _on_quit_button_pressed() -> void:
	print("MainMenu.gd: Botón Quit presionado")
	get_tree().quit()
	
func _on_visibility_changed() -> void:
	if visible:
		focus_button()

func focus_button() -> void:
	if buttons_v_box:
		# Priorizar ContinueButton si está visible, sino StartGameButton
		var button: Button = continue_button if continue_button.visible else start_button
		if button is Button:
			button.grab_focus()
			print("MainMenu.gd: Foco en botón:", button.name)
		else:
			printerr("MainMenu.gd: No se encontró botón válido en ButtonsVBox")


func _on_credits_button_pressed() -> void:
	print("MainMenu.gd: Credits button pressed")
	SceneTransistor.start_transition_to()
	show_credits.emit()
