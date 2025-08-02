extends Node2D

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

#@onready var player: CharacterBody2D = get_parent().get_node("Player")
var player: Character = null
var current_room: Node2D = null
var current_room_name: String = ""
var current_music_player: AudioStreamPlayer = null
	
func initialize(player_node: Character) -> void:
	player = player_node
	print("Rooms.gd: Inicializado con player:", player)
	
func _load_room(room_name: String) -> void:
	# Detener música de la sala anterior
	if current_music_player:
		current_music_player.stop()
		print("Rooms.gd: Música de sala anterior detenida:", current_room_name)
	# Liberar sala actual
	if current_room:
		if current_room.has_signal("door_entered"):
			current_room.door_entered.disconnect(_on_door_entered)
		current_room.queue_free()
	# Cargar nueva sala
	current_room = ROOM_SCENES[room_name].instantiate()
	current_room_name = room_name
	call_deferred("_add_room_deferred")
	print("Rooms.gd: Cargando sala:", room_name)
	
func _add_room_deferred() -> void:
	add_child(current_room)
	if player:
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
			
func _on_door_entered(door: Node2D) -> void:
	# Determinar a qué sala lleva la puerta
	print("Rooms.gd: Cambiando a sala:", door.target_room)
	if door.target_room:
		print("Deberia estar en sala: ", door.target_room)
		_load_room(door.target_room)
