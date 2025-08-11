extends CanvasLayer
class_name UI

signal start_game
signal continue_game
signal menu_opened
signal menu_closed
signal quit_to_menu
signal video_finished  # Nueva señal para notificar que el video terminó

const INVENTORY_ITEM_SCENE: PackedScene = preload("res://UI/invetory_item.tscn")

const MIN_HEALTH: int = 23
var max_n_hp: int = 4

@onready var main_menu = %MainMenu
@onready var game_menu = %GameMenu
@onready var good_end = %GoodEndMenu
@onready var normal_end = %NormalEndMenu
@onready var bad_end = %BadEndMenu
@onready var video_player = %VideoPlayer
@onready var credits_menu = %Credits
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var invetory_cotainer : PanelContainer = $PanelContainer
@onready var inventory: HBoxContainer = $PanelContainer/Inventory

func _ready() -> void:
	#main_menu.start_game.connect(_on_main_menu_start_game)
	#main_menu.continue_game.connect(_on_main_menu_continue_game)
	#game_menu.return_to_game.connect(_on_game_menu_return_to_game)
	#game_menu.main_menu.connect(_on_game_menu_main_menu)
	#
	good_end.show_credits.connect(_on_end_menu_show_credits)
	normal_end.show_credits.connect(_on_end_menu_show_credits)
	bad_end.show_credits.connect(_on_end_menu_show_credits)
	#if video_player:
		#video_player.video_finished.connect(_on_video_finished)
		#print("UI.gd: VideoPlayer conectado")
	#else:
		#printerr("UI.gd: Error - No se encontró VideoPlayer")
	show_main_menu()


func show_main_menu() -> void:
	hide_all()
	main_menu.show()
	main_menu.verify_state_of_continue_button()
	main_menu.play_music()
	visible = true
	print("UI.gd: Mostrando MainMenu, visible:",visible,"Main_menu.visible: ", main_menu.visible)

func show_game_menu() -> void:
	hide_all()
	game_menu.show()
	visible = true
	print("UI.gd: Mostrando GameMenu, visible:", visible)	

func show_game() -> void:
	hide_all()
	health_bar.show()
	invetory_cotainer.show()
	inventory.show()
	visible = true
	menu_closed.emit() #changed
	print("UI.gd: Mostrando juego, visible:", visible)
func show_credits() -> void:
	hide_all()
	SceneTransistor.change_scene_to_file()
	credits_menu.show_credits()
	visible = true
	print("UI.gd: Mostrando creditos, visible:", visible)
	
func show_end_menu(death_counter: int) -> void:
	hide_all()
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

func show_video(video_path: String) -> void:
	hide_all()
	if video_player:
		video_player.show()
		video_player.play_video(video_path)
		print("UI.gd: Mostrando video:", video_path)
	else:
		printerr("UI.gd: Error - No se encontró VideoPlayer")
		video_finished.emit()
	visible = true

func hide_all() -> void:
	main_menu.hide_menu()
	game_menu.hide()
	good_end.hide_menu()
	normal_end.hide_menu()
	bad_end.hide_menu()
	credits_menu.hide_menu()
	health_bar.hide()
	invetory_cotainer.hide()
	inventory.hide()
	if video_player:
		video_player.hide()
	visible = false
	print("UI.gd: Ocultando UI, visible:", visible)
	
func _input(event: InputEvent) -> void:
	if !main_menu.visible and !good_end.visible and !normal_end.visible and !bad_end.visible and !video_player.visible and event.is_action_pressed("ui_cancel"):
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
	if player.has_signal("weapon_switched"):
		player.weapon_switched.connect(_on_weapon_switched)
	if player.has_signal("weapon_picked_up"):
		player.weapon_picked_up.connect(_on_weapon_picked_up)
	if player.has_signal("weapon_droped"):
		player.weapon_droped.connect(_on_weapon_droped)
	# Limpiar inventario anterior
	for child in inventory.get_children():
		child.queue_free()
	show_game()
	
func _update_health_bar(new_value: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(health_bar, "value", new_value, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _on_player_hp_changed(new_hp: Variant) -> void:
	var new_health: int = int((100-MIN_HEALTH) *
	 float(new_hp) / max_n_hp) + MIN_HEALTH
	_update_health_bar(new_health)
	
func _on_weapon_switched(prev_index: int, new_index: int) -> void:
	if inventory.get_child_count() > prev_index: #new
		inventory.get_child(prev_index).deselect()
	if inventory.get_child_count() > new_index: #new
		inventory.get_child(new_index).select()

func _on_weapon_picked_up(weapon_texture: Texture2D) -> void:
	var new_inventory_item: TextureRect = INVENTORY_ITEM_SCENE.instantiate()
	inventory.add_child(new_inventory_item)
	new_inventory_item.initialize(weapon_texture)
	#print("UI.gd: Colocando textura", weapon_texture)

func _on_weapon_droped(index: int) -> void:
	if inventory.get_child_count() > index: #new
		inventory.get_child(index).queue_free()

func _on_main_menu_start_game() -> void:
	print("UI: Juego iniciando")
	start_game.emit()
	#main_menu.hide()
	
func _on_main_menu_continue_game() -> void:
	continue_game.emit()
	
func _on_game_menu_return_to_game() -> void:
	show_game()

func _on_game_menu_main_menu() -> void:
	quit_to_menu.emit()
	show_main_menu()
	
func _on_credits_return_to_menu() -> void:
	SceneTransistor.change_scene_to_file()
	quit_to_menu.emit()
	show_main_menu()
	
	
func _on_video_player_video_finished() -> void:
	print("UI.gd: Video terminado")
	video_finished.emit()
	#show_game()

func _on_main_menu_show_credits() -> void:
	show_credits()

func _on_end_menu_show_credits() -> void:
	print("UI.gd: mostrando creditos a partir de menu fin")
	show_credits()
