extends Node2D

const ROOM_SCENES: Dictionary = {
	"Room1_1": preload("res://Rooms/Room1_1.tscn"),  # Prision (start)
	"Room1_2": preload("res://Rooms/Room1_2.tscn"),  # Town (hub)
	"Room1_3": preload("res://Rooms/Room1_3.tscn"),  # Forja
	"Room1_4": preload("res://Rooms/Room1_4.tscn"),  # Taberna
	"Room1_5": preload("res://Rooms/Room1_5.tscn"),  # Cueva
	"Room2_1": preload("res://Rooms/Room2_1.tscn"),
	"Room2_5": preload("res://Rooms/Room2_5.tscn"),
}

@onready var player: CharacterBody2D = get_parent().get_node("Player")
var current_room: Node2D = null
var current_room_name: String = ""

func _ready() -> void:
	# Instanciar la sala inicial (cárcel)
	_load_room("Room2_5")

func _load_room(room_name: String) -> void:
	if current_room:
		if current_room.has_signal("door_entered"):
			current_room.door_entered.disconnect(_on_door_entered)
		current_room.queue_free()
	
	current_room = ROOM_SCENES[room_name].instantiate()
	current_room_name = room_name
	call_deferred("_add_room_deferred")
	
func _add_room_deferred() -> void:
	add_child(current_room)
	
	var spawn_pos = current_room.get_node("PlayerSpawnPos").position
	player.position = spawn_pos
	
	if current_room.has_signal("door_entered"):
		print("Conectando door_entered para sala:", current_room_name)
		if not current_room.door_entered.is_connected(_on_door_entered):
			current_room.door_entered.connect(_on_door_entered)
			
func _on_door_entered(door: Node2D) -> void:
	# Determinar a qué sala lleva la puerta
	print("Rooms: Cambiando a sala:", door.target_room)
	var target_room = door.target_room
	if target_room:
		_load_room(target_room)
