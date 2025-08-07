extends CanvasLayer
class_name UI

signal start_game
signal menu_opened
signal menu_closed
signal quit_to_menu

const MIN_HEALTH: int = 23
var max_n_hp: int = 4

@onready var main_menu = %MainMenu
@onready var game_menu = %GameMenu
@onready var good_end = %GoodEndMenu
@onready var normal_end = %NormalEndMenu
@onready var bad_end = %BadEndMenu
@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	main_menu.start_game.connect(_on_main_menu_start_game)
	game_menu.return_to_game.connect(_on_game_menu_return_to_game)
	game_menu.main_menu.connect(_on_game_menu_main_menu)
	#new
	good_end.return_to_menu.connect(_on_end_menu_return_to_menu)
	normal_end.return_to_menu.connect(_on_end_menu_return_to_menu)
	bad_end.return_to_menu.connect(_on_end_menu_return_to_menu)
	#new
	show_main_menu()


func show_main_menu() -> void:
	main_menu.show()
	main_menu.play_music()
	game_menu.hide()
	good_end.hide()
	normal_end.hide()
	bad_end.hide()
	health_bar.hide()  # Ocultar hasta que el juego comience
	visible = true
	print("UI.gd: Mostrando MainMenu, visible:",visible,"Main_menu.visible: ", main_menu.visible)

func show_game_menu() -> void:
	main_menu.hide()
	game_menu.show()
	good_end.hide()
	normal_end.hide()
	bad_end.hide()
	health_bar.hide()
	visible = true
	print("UI.gd: Mostrando GameMenu, visible:", visible)	

func show_game() -> void:
	main_menu.hide()
	game_menu.hide()
	good_end.hide()
	normal_end.hide()
	bad_end.hide()
	health_bar.show()
	visible = true
	menu_closed.emit() #changed
	print("UI.gd: Mostrando juego, visible:", visible)
	
func show_end_menu(death_counter: int) -> void:
	main_menu.hide()
	game_menu.hide()
	health_bar.hide()
	if death_counter < 1:
		good_end.show()
		good_end.play_music()
		print("UI.gd: Mostrando GoodEnd, death_counter:", death_counter)
	elif death_counter < 2:
		normal_end.show()
		normal_end.play_music()
		print("UI.gd: Mostrando NormalEnd, death_counter:", death_counter)
	else:
		bad_end.show()
		bad_end.play_music()
		print("UI.gd: Mostrando BadEnd, death_counter:", death_counter)
	visible = true
	
func hide_all() -> void:
	main_menu.hide()
	game_menu.hide()
	good_end.hide()
	normal_end.hide()
	bad_end.hide()
	health_bar.hide()
	visible = false
	print("UI.gd: Ocultando UI, visible:", visible)
	
func _input(event: InputEvent) -> void:
	if !main_menu.visible and !good_end.visible and !normal_end.visible and !bad_end.visible and event.is_action_pressed("ui_cancel"):
		if game_menu.visible:
			show_game()
		else:
			show_game_menu()
			menu_opened.emit()

func initialize(player: Character) -> void:
	max_n_hp = player.hp
	_update_health_bar(100)
	if player.has_signal("hp_changed"):
		player.hp_changed.connect(_on_player_hp_changed)
	show_game()

func _update_health_bar(new_value: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(health_bar, "value", new_value, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _on_player_hp_changed(new_hp: Variant) -> void:
	var new_health: int = int((100-MIN_HEALTH) *
	 float(new_hp) / max_n_hp) + MIN_HEALTH
	_update_health_bar(new_health)

func _on_main_menu_start_game() -> void:
	print("UI: Juego iniciando")
	start_game.emit()
	#main_menu.hide()
	
func _on_game_menu_return_to_game() -> void:
	show_game()

func _on_game_menu_main_menu() -> void:
	quit_to_menu.emit()
	show_main_menu()

func _on_end_menu_return_to_menu() -> void:
	quit_to_menu.emit()
	show_main_menu()
