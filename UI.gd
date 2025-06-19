extends CanvasLayer
class_name UI

signal start_game()


const MIN_HEALTH: int = 23
var max_n_hp: int = 4

@onready var main_menu = %MainMenu


@onready var health_bar : TextureProgressBar = get_node("HealthBar")

func _ready() -> void:
	main_menu.start_game.connect(_on_main_menu_start_game)
	main_menu.show()
	health_bar.hide()  # Ocultar hasta que el juego comience
	
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
	main_menu.hide() #Is necessary?
