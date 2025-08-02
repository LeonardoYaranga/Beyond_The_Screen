extends Node2D

@export var PlayerScene: PackedScene
@export var RoomsScene: PackedScene
@export var StartRoom: String
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
	add_child(player)
	
	ui.initialize(player) 
	rooms.initialize(player)
	# Configurar la cámara
	player.activate_player_camera()
	# Cargar la sala inicial
	rooms._load_room(StartRoom)
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
