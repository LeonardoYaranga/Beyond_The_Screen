extends Node2D

@export var PlayerScene: PackedScene
@export var RoomsScene: PackedScene
@onready var ui: UI = $UI
@onready var camera: Camera2D = $Camera2D

var player: Character
var rooms: Node2D

func start_game() -> void:
	# Instanciar Rooms
	rooms = RoomsScene.instantiate()
	add_child(rooms)
	
	# Instanciar Player
	player = PlayerScene.instantiate()
	add_child(player)
	
	ui.initialize(player) #Quiz esto hace q salga 2 players?
	rooms.initialize(player)
	# Conectar HealthBar al Player
	
	# Configurar la cámara
	player.activate_player_camera()
	
	# Cargar la sala inicial
	rooms._load_room("Room1_1")  # Cárcel como sala inicial
	
	# Despausar el juego
	get_tree().paused = false #Esto no es necesario ya que nunca se pausa pero porsiacaso
		#Puede servir para otro menu, como el de pausa
	
func _ready() -> void:
	randomize()
	ui.main_menu.show()  # Asegurar que el MainMenu sea visible


func _on_ui_start_game() -> void:
	start_game() 
