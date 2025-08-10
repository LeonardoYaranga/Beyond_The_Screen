extends Control

signal return_to_menu
@onready var buttons_v_box = %ButtonsVBox
@onready var texture_rect = $TextureRect
@onready var audio_stream_player = $BackgroundMusic
func _ready() -> void:
	texture_rect.modulate = Color(1, 1, 1, 0.6)
	focus_button()
	print("EndScene.gd: TextureRect texture:", texture_rect.texture, "size:", texture_rect.size, "visible:", texture_rect.visible)
func stop_music() -> void:
	audio_stream_player.stop()
	print("EndScene.gd: Música del menú detenida")

func play_music() -> void:
	audio_stream_player.play()
	print("EndScene.gd: Reproduciendo música del menú")
	
func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		focus_button()

func _on_quit_game_button_pressed() -> void:
	stop_music()
	get_tree().quit()

func _on_restart_button_pressed() -> void:
	stop_music()
	emit_signal("return_to_menu")
	print("EndScene.gd: Botón de reinicio presionado")
