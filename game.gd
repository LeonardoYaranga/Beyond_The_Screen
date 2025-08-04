extends Node2D

@export var PlayerScene: PackedScene
@export var Player2Scene: PackedScene  # Nueva escena para Player2
@export var RoomsScene: PackedScene
@export var startRoom: String
@onready var ui: UI = $UI
@onready var camera: Camera2D = $Camera2D

var player: Character
var rooms: Node2D

func _ready() -> void:
	randomize()
	ui.main_menu.show()
	ui.menu_opened.connect(_on_ui_menu_opened)
	ui.menu_closed.connect(_on_ui_menu_closed)
	ui.quit_to_menu.connect(_on_ui_quit_to_menu)
	
func start_game() -> void:
	# Detener música del menú
	ui.main_menu.stop_music()
	# Instanciar Rooms
	rooms = RoomsScene.instantiate()
	add_child(rooms)
	# Instanciar Player
	player = PlayerScene.instantiate()
	initialize_player(player)
	# Conectar señal player_changed
	if not rooms.player_changed.is_connected(_on_player_changed):
		rooms.player_changed.connect(_on_player_changed)
	# Cargar la sala inicial
	rooms._load_room(startRoom)
	# Despausar el juego
	get_tree().paused = false 
	print("Game.gd: Juego iniciado, música del menú detenida, sala Room2_5 cargada")

func _on_ui_start_game() -> void:
	start_game() 

func _on_ui_menu_opened() -> void:
	get_tree().paused = true
	print("Game.gd: Menú abierto, juego pausado")
func _on_ui_menu_closed() -> void:
	get_tree().paused = false
	print("Game.gd: Menú cerrado, juego reanudado")

func _on_ui_quit_to_menu() -> void:
	if rooms:
		rooms.queue_free()
		rooms = null
	if player:
		player.queue_free()
		player = null
	ui.main_menu.play_music()
	get_tree().paused = false
	print("Game.gd: Volviendo al menú, música del menú reanudada")
	
func _on_player_changed() -> void:
	if(player):
		#new_player.hp = player.hp  # Mantener vida (se deberia pasar como parametro
		#new_player.position = player.position #manteenr posicion (igual deber ser pasada)
		remove_child(player)
		player.queue_free()
	player = Player2Scene.instantiate()
	initialize_player(player)
	print("Game.gd: Jugador cambiado a:", player.scene_file_path)
	
func initialize_player(new_player: Character) -> void:
	player = new_player	
	add_child(player)
	ui.initialize(player)
	rooms.initialize(player)
	player.activate_player_camera()
	print("Game.gd: Jugador inicializado.")
