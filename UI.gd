extends CanvasLayer
class_name UI

signal start_game()
signal menu_opened()
signal menu_closed()
signal quit_to_menu()

const MIN_HEALTH: int = 23
var max_n_hp: int = 4

@onready var main_menu = %MainMenu
@onready var game_menu = %GameMenu

@onready var health_bar : TextureProgressBar = get_node("HealthBar")

func _ready() -> void:
	main_menu.start_game.connect(_on_main_menu_start_game)
	game_menu.return_to_game.connect(_on_game_menu_return_to_game)
	game_menu.main_menu.connect(_on_game_menu_main_menu)
	main_menu.show()
	game_menu.hide()
	health_bar.hide()  # Ocultar hasta que el juego comience
func _input(event: InputEvent) -> void:
	if !main_menu.visible and event.is_action_pressed("ui_cancel"):
		game_menu.visible = !game_menu.visible
		if game_menu.visible:
			menu_opened.emit()
			health_bar.hide()  # Ocultar hasta que el juego comience
		else:
			menu_closed.emit()	
			
func initialize(player: Character) -> void:
	max_n_hp = player.hp
	_update_health_bar(100)
	if player.has_signal("hp_changed"):
		player.hp_changed.connect(_on_player_hp_changed)
	health_bar.show()

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
	main_menu.hide()
	
func _on_game_menu_return_to_game() -> void:
	game_menu.hide()
	health_bar.show()
	menu_closed.emit()

func _on_game_menu_main_menu() -> void:
	game_menu.hide()
	quit_to_menu.emit()
	main_menu.show()
