extends Node2D

@export var PlayerScene: PackedScene
@export var Player2Scene: PackedScene
@export var RoomsScene: PackedScene
@export var start_room: String
@onready var ui: UI = $UI
@onready var camera: Camera2D = $Camera2D

var player: Character
var rooms: Node2D

func _ready() -> void:
	randomize()
	ui.main_menu.show()
	#ui.menu_opened.connect(_on_ui_menu_opened)
	#ui.menu_closed.connect(_on_ui_menu_closed)
	#ui.quit_to_menu.connect(_on_ui_quit_to_menu)
	
	#ui.start_game.connect(_on_ui_start_game)
	#ui.continue_game.connect(_on_ui_continue_game)
	#ui.video_finished.connect(_on_ui_video_finished)
	SceneTransistor.transition_finished.connect(_on_transition_finished)
	print("Game.gd: Inicializado, mostrando MainMenu")
	
func free_sources() -> void:
	if rooms:
		rooms.queue_free()
		rooms = null
	if player:
		player.queue_free()
		player = null
		
func start_game(is_new_game: bool = true) -> void:
	ui.hide_all()
	# Liberar recursos anteriores
	free_sources()
	#Instanciar rooms
	rooms = RoomsScene.instantiate()
	add_child(rooms)
	# Conectar show_video
	if not rooms.show_video.is_connected(_on_rooms_show_video):
		rooms.show_video.connect(_on_rooms_show_video)
	# Instanciar Player
	player = PlayerScene.instantiate()
	player.visible = false  # Ocultar jugador al inicio
	initialize_player(player)
	if not rooms.player_changed.is_connected(_on_player_changed):
		rooms.player_changed.connect(_on_player_changed)
	if not rooms.show_end_menu.is_connected(_on_rooms_show_end_menu):
		rooms.show_end_menu.connect(_on_rooms_show_end_menu)
	# Cargar la sala
	
	if is_new_game:
		GameManager.reset_game()
		rooms._load_room(start_room)
		print("Game.gd: Nuevo juego iniciado, sala:", start_room)
	else:
		var room_to_load = GameManager.last_room_visited if GameManager.last_room_visited else start_room
		rooms._load_room(room_to_load)
		print("Game.gd: Continuando juego, sala:", room_to_load)
	#get_tree().paused = false 

func _on_ui_start_game() -> void:
	print("Game.gd: Señal start_game recibida")
	start_game(true) 
	
func _on_ui_continue_game() -> void:
	print("Game.gd: Señal continue_game recibida")
	start_game(false)
	
func _on_ui_menu_opened() -> void:
	get_tree().paused = true

func _on_ui_menu_closed() -> void:
	get_tree().paused = false

func _on_ui_quit_to_menu() -> void:
	free_sources()
	ui.show_main_menu() #Es necesario para que se muestre  cuando voy de una EscenaFinal hacia el MainMenu
	get_tree().paused = false
	print("Game.gd: Volviendo al menú, música del menú reanudada")

func _on_rooms_show_end_menu(death_counter: int) -> void: #This nees to be sended like GameManager.death_counter from Rooms.gd
	free_sources()
	ui.show_end_menu(death_counter)
	get_tree().paused = false
	print("Game.gd: Mostrando menú final, death_counter:", death_counter)

func _on_rooms_show_video(video_path: String, room_name: String) -> void:
	if player:
		player.visible = false
		print("Game.gd: Jugador oculto para video")
	ui.show_video(video_path)
	print("Game.gd: Mostrando video para sala", room_name, ":", video_path)

func _on_ui_video_finished() -> void:
	if player:
		player.visible = true
	if rooms:
		rooms._on_video_finished()
		ui.show_game()
		print("Game.gd: Video terminado, notificando a Rooms y mostrando juego")

func _on_transition_finished() -> void:
	if player:
		player.visible = true
	if rooms:
		rooms._on_transition_finished()
		ui.show_game()
		print("Game.gd: Transición terminada, notificando a Rooms y mostrando juego")

func _on_player_changed() -> void:
	if(player):
		remove_child(player)
		player.queue_free()
	player = Player2Scene.instantiate()
	initialize_player(player)
	print("Game.gd: Jugador cambiado a:", player.scene_file_path)
	
func initialize_player(new_player: Character) -> void:
	player = new_player
	if player:
		add_child(player)
		player.visible = false  # Ocultar hasta que la sala esté lista
		ui.initialize(player)
		rooms.initialize(player)
		player.activate_player_camera()
		player.get_node("FiniteStateMachine").player_died.connect(_on_player_died)  # Conectar señal
		print("Game.gd: Jugador inicializado.")
	else:
		ui.hide_all()
		print("Game.gd: No hay jugador, UI oculta.")
	
func _on_player_died() -> void:
	GameManager.increment_death_counter()
	print("Game.gd: Jugador murió,avisando al GameManager.gd")
	free_sources()
	ui.show_main_menu()
	# Reiniciar sala actual
	#rooms._load_room(rooms.current_room_name)  #hay que tener en cuenta que al jugador se lo debe reiniciar tambien
