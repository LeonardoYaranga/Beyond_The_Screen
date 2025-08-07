extends Node2D
signal player_changed # Nueva señal para notificar cambio de jugador
signal return_to_menu  # We need this signal? Needs to be checked.
signal show_end_menu(death_counter: int)

const ROOM_SCENES: Dictionary = {
	"Room1_1": preload("res://Rooms/Room1_1.tscn"),  # Prision (start)
	"Room1_2": preload("res://Rooms/Room1_2.tscn"),  # Town (hub)
	"Room1_3": preload("res://Rooms/Room1_3.tscn"),  # Forja
	"Room1_4": preload("res://Rooms/Room1_4.tscn"),  # Taberna
	"Room1_5": preload("res://Rooms/Room1_5.tscn"),  # Cueva
	"Room2_1": preload("res://Rooms/Room2_1.tscn"),
	"Room2_2": preload("res://Rooms/Room2_2.tscn"),
	"Room2_3": preload("res://Rooms/Room2_3.tscn"),
	"Room2_4": preload("res://Rooms/Room2_4.tscn"),
	"Room2_5": preload("res://Rooms/Room2_5.tscn"),
}

var player: Character = null
var current_room: Node = null
var current_room_name: String = ""
var current_music_player: AudioStreamPlayer = null
	
func initialize(player_node: Character) -> void:
	player = player_node
	print("Rooms.gd: Inicializado con player:", player.scene_file_path if player else "null")
	
func _load_room(room_name: String) -> void:
	# Detener música de la sala anterior
	if current_music_player:
		current_music_player.stop()
		print("Rooms.gd: Música de sala anterior detenida:", current_room_name)
	# Liberar sala actual
	if current_room:
		if current_room.has_signal("door_entered"):
			current_room.door_entered.disconnect(_on_door_entered)
		if current_room.has_signal("return_to_menu"):  #Is this neccesary?
			current_room.return_to_menu.disconnect(_on_return_to_menu)
		current_room.queue_free()
		print("Rooms.gd: Sala anterior liberada:", current_room_name)
		
	if room_name == "end":
		var death_counter = get_parent().death_counter  #Game.tscn is the parent of Rooms.tscn
		print("Rooms.gd: Detectado final, emitiendo show_end_menu, death_counter:", death_counter)
		if player:
			get_parent().remove_child(player)
			player.queue_free()
			player = null
			get_parent().ui.hide_all()
			print("Rooms.gd: Jugador eliminado y UI oculta para escena final")
		emit_signal("show_end_menu", death_counter)
		return
	# Cargar nueva sala
	current_room = ROOM_SCENES[room_name].instantiate()
	current_room_name = room_name
	# Cambiar instancia del jugador
	if room_name == "Room2_1" and player and player.scene_file_path != "res://Characters/Player/player2.tscn":
		print("Rooms.gd: Emitiendo player_changed para cambiar a Player2")
		emit_signal("player_changed")  # Notificar cambio de jugador		
	call_deferred("_add_room_deferred")
	print("Rooms.gd: Cargando sala:", room_name)
	
func _add_room_deferred() -> void:
	add_child(current_room)
	if player and current_room is Node2D and current_room.has_node("PlayerSpawnPos"):
		var spawn_pos = current_room.get_node("PlayerSpawnPos").position
		player.position = spawn_pos
		print("Rooms.gd: Player posicionado en:", spawn_pos)
	# Configurar música de la sala
	var music_player = current_room.get_node_or_null("BackgroundMusic")
	if music_player and music_player.stream:
		current_music_player = music_player
		current_music_player.play()
		print("Rooms.gd: Reproduciendo música de sala:", current_room_name)
	else:
		current_music_player = null
		print("Rooms.gd: No se encontró BackgroundMusic o stream en sala:", current_room_name)
	# Conectar señal de puerta
	if current_room.has_signal("door_entered"):
		print("Rooms.gd: Conectando door_entered para sala:", current_room_name)
		if not current_room.door_entered.is_connected(_on_door_entered):
			current_room.door_entered.connect(_on_door_entered)
	if current_room.has_signal("return_to_menu"):  #Is this necesary?
		print("Rooms.gd: Conectando return_to_menu para sala:", current_room_name)
		if not current_room.return_to_menu.is_connected(_on_return_to_menu):
			current_room.return_to_menu.connect(_on_return_to_menu)
			
func _on_door_entered(door: Node2D) -> void:
	# Determinar a qué sala lleva la puerta
	print("Rooms.gd: Cambiando a sala:", door.target_room)
	if door.target_room:
		print("Deberia estar en sala: ", door.target_room)
		_load_room(door.target_room)

func _on_return_to_menu() -> void:  #This gonna executed?
	print("Rooms.gd: Emitiendo return_to_menu")
	emit_signal("return_to_menu")
