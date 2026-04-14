extends Control

signal return_to_game()
signal main_menu()

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX") #SFX
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music") #Music
@onready var buttons_v_box = %ButtonsVBox
@onready var music_slider = %MusicSlider
@onready var sfx_slider = %SFXSlider

func _ready():
	# Inicializar sliders con valores por defecto
	if music_slider:
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(MUSIC_BUS_ID))
	if sfx_slider:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SFX_BUS_ID))

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.05)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.05)

func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		focus_button()

func _on_return_to_game_button_pressed() -> void:
	return_to_game.emit()

func _on_main_menu_button_pressed() -> void:
	main_menu.emit()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
