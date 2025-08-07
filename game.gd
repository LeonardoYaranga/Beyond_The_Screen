extends Node2D

@export var PlayerScene: PackedScene
@export var RoomsScene: PackedScene
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
	rooms._load_room("Room2_1")
	# Despausar el juego
	get_tree().paused = false #Esto no es necesario ya que nunca se pausa pero porsiacaso
		#Puede servir para otro menu, como el de pausa


func _on_ui_start_game() -> void:
	start_game() 

func _on_ui_menu_opened() -> void:
	get_tree().paused = true

func _on_ui_menu_closed() -> void:
	get_tree().paused = false

func _on_ui_quit_to_menu() -> void:
	if rooms:
		rooms.queue_free()
		rooms = null
	if player:
		player.queue_free()
		player = null
	get_tree().paused = false
