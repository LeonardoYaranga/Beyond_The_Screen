extends Node2D
signal player_changed # Nueva señal para notificar cambio de jugador

signal show_end_menu(death_counter: int)
signal show_video(video_path: String, room_name: String)  # Nueva señal

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
const VIDEO_MAP: Dictionary = {
	"Room1_1": "res://Videos/World1/knight_room1_1.ogv",
	"Room1_2": "res://Videos/World1/exiting_the_cave_now_in_town.ogv",
	"Room1_3": "res://Videos/World1/blacksmith.ogv",
	"Room1_5": "res://Videos/World1/Room1_5_knight_entering_to_cave.ogv",
	"Room2_1": "res://Videos/changing_player.ogv",
	"Room2_5": "res://Videos/World2/3rbot_preparing_for_combat.ogv"
}
var player: Character = null
var current_room: Node2D = null
var current_room_name: String = ""
var current_music_player: AudioStreamPlayer = null
var pending_room: String = ""  # Almacena la sala a cargar después del video

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
		current_room.queue_free()
		print("Rooms.gd: Sala anterior liberada:", current_room_name)
	
	if room_name == "end":
		print("Rooms.gd: Detectado final, emitiendo show_end_menu, death_counter:", GameManager.death_counter)
		if player:
			get_parent().remove_child(player)
			player.queue_free()
			player = null
			get_parent().ui.hide_all()
			print("Rooms.gd: Jugador eliminado y UI oculta para escena final")
		emit_signal("show_end_menu", GameManager.death_counter)
		return
	current_room_name = room_name
	GameManager.update_last_room(current_room_name)
	print("Rooms.gd: Actualizado last_room_visited:", GameManager.last_room_visited)
	
	if room_name == "Room2_1" and player and player.scene_file_path != "res://Characters/Player/player2.tscn":
		print("Rooms.gd: Emitiendo player_changed para cambiar a Player2")
		emit_signal("player_changed")
	
	var video_path: String = VIDEO_MAP.get(room_name, "")
	if video_path != "" and FileAccess.file_exists(video_path) and not GameManager.has_visited_room(room_name):
		pause_player_if_exist(player)
		pending_room = room_name
		emit_signal("show_video", video_path, room_name)
		_load_room_async(room_name)
		print("Rooms.gd: Iniciando video como pantalla de carga para", room_name)
	else:
		pause_player_if_exist(player)
		pending_room = room_name
		SceneTransistor.start_transition_to()
		_load_room_async(room_name)
		print("Rooms.gd: Transicion generica")
		
func pause_player_if_exist(player: CharacterBody2D) -> void:
	if player:
		var player_fsm = player.get_node("FiniteStateMachine")
		if player_fsm:
			print("Rooms.gd: Cambiando estado del jugador a paused")
			player_fsm.set_state(player_fsm.states.paused)
		else:
			print("Rooms.gd: No se encontró la FSM del jugador")
	else:
		print("Rooms.gd: No hay player en rooms que poner el estado pause")
		
func restore_the_state_of_player_if_exist(player : CharacterBody2D) -> void:
	if player:
			var player_fsm = player.get_node("FiniteStateMachine")
			if player_fsm:
				var previous_state = player_fsm.previous_state if player_fsm.previous_state != -1 else player_fsm.states.idle
				print("Rooms.gd: Restaurando estado del jugador a", previous_state)
				player_fsm.set_state(previous_state)
			else:
				print("Rooms.gd: No se encontró la FSM del jugador al restaurar")
	else:
		print("Rooms.gd: No hay player en rooms que restaurar su estado")
				
func _load_room_async(room_name: String) -> void:
	if ROOM_SCENES.has(room_name):
		current_room = ROOM_SCENES[room_name].instantiate()
		print("Rooms.gd: Sala", room_name, "instanciada en segundo plano")
	else:
		printerr("Rooms.gd: Error al cargar la sala", room_name)
		
func _on_video_finished() -> void:
	restore_the_state_of_player_if_exist(player)
	if pending_room and current_room:
		current_room_name = pending_room
		pending_room = ""
		call_deferred("_add_room_deferred")
		print("Rooms.gd: Video terminado, añadiendo sala:", current_room_name)
	else:
		printerr("Rooms.gd: No hay sala cargada para", current_room_name)
		
func _on_transition_finished() -> void:
	restore_the_state_of_player_if_exist(player)
	if pending_room and current_room:
		current_room_name = pending_room
		pending_room = ""
		call_deferred("_add_room_deferred")
		print("Rooms.gd: Transición terminada, añadiendo sala:", current_room_name)
	else:
		printerr("Rooms.gd: No hay sala cargada para", current_room_name)
		emit_signal("return_to_menu")
		
func _load_room_directly(room_name: String) -> void:
	if ROOM_SCENES.has(room_name):
		current_room = ROOM_SCENES[room_name].instantiate()
		current_room_name = room_name
		call_deferred("_add_room_deferred")
		print("Rooms.gd: Sala", room_name, "cargada directamente")
	else:
		printerr("Rooms.gd: Error al cargar la sala", room_name)
		emit_signal("return_to_menu")
		
func _add_room_deferred() -> void:
	add_child(current_room)
	if player and current_room is Node2D:
		var spawn_pos = current_room.get_spawn_position() if current_room.has_method("get_spawn_position") else Vector2.ZERO
		player.position = spawn_pos
		player.visible = true
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
		# Registrar la sala actual como visitada antes de cambiar
		if current_room_name:
			GameManager.add_visited_room(current_room_name)
			print("Rooms.gd: Sala marcada como visitada:", current_room_name)
		print("Rooms.gd: Debería estar en sala:", door.target_room)
		_load_room(door.target_room)
