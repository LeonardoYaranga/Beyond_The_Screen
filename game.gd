extends Node2D

@export var PlayerScene: PackedScene
@export var Player2Scene: PackedScene
@export var RoomsScene: PackedScene
@export var startRoom: String
@onready var ui: UI = $UI
@onready var camera: Camera2D = $Camera2D

var player: Character
var rooms: Node2D
var death_counter: int = 0
const SAVE_PATH: String = "user://game_save.json"

func _ready() -> void:
	randomize()
	load_game() #Cargar contenido del archivo game_save.json
	ui.main_menu.show()
	ui.menu_opened.connect(_on_ui_menu_opened)
	ui.menu_closed.connect(_on_ui_menu_closed)
	ui.quit_to_menu.connect(_on_ui_quit_to_menu)
	
	ui.start_game.connect(_on_ui_start_game)
	ui.video_finished.connect(_on_ui_video_finished)
	SceneTransistor.transition_finished.connect(_on_transition_finished)
	
func start_game() -> void:
	ui.hide_all()
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
	#if not rooms.return_to_menu.is_connected(_on_ui_quit_to_menu):
		#rooms.return_to_menu.connect(_on_ui_quit_to_menu)
	if not rooms.show_end_menu.is_connected(_on_rooms_show_end_menu):
		rooms.show_end_menu.connect(_on_rooms_show_end_menu)
	# Cargar la sala inicial
	rooms._load_room(startRoom)

	get_tree().paused = false 
	print("Game.gd: Juego iniciado, música del menú detenida, sala", startRoom, " cargada")

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
	ui.show_main_menu() #Es necesario para que se muestre  cuando voy de una EscenaFinal hacia el MainMenu
	get_tree().paused = false
	print("Game.gd: Volviendo al menú, música del menú reanudada")

func _on_rooms_show_end_menu(death_counter: int) -> void:
	if rooms:
		rooms.queue_free()
		rooms = null
	if player:
		player.queue_free()
		player = null
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
		#if player.has_node("Camera2D"):
			#player.get_node("Camera2D").enabled = true
		#print("game.gd: Returning the camera")
	if rooms:
		rooms._on_video_finished()
		ui.show_game()
		print("Game.gd: Video terminado, notificando a Rooms y mostrando juego")

func _on_transition_finished() -> void:
	if player:
		player.visible = true
	if rooms:
		rooms._on_transition_finished()
		#if player.has_node("Camera2D"):
			#player.get_node("Camera2D").enabled = true
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
		#new
		#if player.has_node("Camera2D"):
			#player.get_node("Camera2D").enabled = false
		#/new
		ui.initialize(player)
		rooms.initialize(player)
		player.activate_player_camera()
		player.get_node("FiniteStateMachine").player_died.connect(_on_player_died)  # Conectar señal
		#ui.show_game() Llamarlo luego del video mejor
		print("Game.gd: Jugador inicializado.")
	else:
		ui.hide_all()
		print("Game.gd: No hay jugador, UI oculta.")
	
func _on_player_died() -> void:
	death_counter += 1
	save_game()
	print("Game.gd: Jugador murió, contador de muertes:", death_counter)
	# Reiniciar sala actual
	#rooms._load_room(rooms.current_room_name)  #hay que tener en cuenta que al jugador se lo debe reiniciar tambien

func save_game() -> void:
	var save_data = {
		"death_counter": death_counter
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game.gd: Juego guardado, death_counter:", death_counter)
	else:
		printerr("Game.gd: Error al guardar el juego")
		
func load_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			file.close()
			if text.is_empty():
				print("Game.gd: Archivo de guardado vacío, inicializando death_counter a 0")
				death_counter = 0
				save_game()  # Crear archivo con valor inicial
			else:
				var json = JSON.parse_string(file.get_as_text())
				if json and json is Dictionary:
					death_counter = json.get("death_counter", 0)
					print("Game.gd: Juego cargado, death_counter:", death_counter)
				else:
					printerr("Game.gd: Formato JSON inválido en", SAVE_PATH)
					death_counter = 0
					save_game()
		else:
			printerr("Game.gd: Error al abrir el archivo de guardado")
			death_counter = 0
			save_game()
	else:
		death_counter = 0
		save_game()  # Crear archivo inicial
		print("Game.gd: No se encontró archivo de guardado, death_counter inicializado a 0")
