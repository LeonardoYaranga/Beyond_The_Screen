extends Node2D

class_name Room
signal door_entered(door: Node2D)

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemy/spawn_explosion.tscn")

const ENEMY_SCENES: Dictionary = {
	"FLYING_CREATURE": preload("res://Characters/Enemy/FlyingCreature/FlyingCreature.tscn"),
	"GOBLIN": preload("res://Characters/Enemy/Goblin/Goblin.tscn")
}

@export var entrance_tile_source_id: int = 0  # ID del tileset para cerrar la entrada
@export var entrance_tile_atlas_coords: Vector2i = Vector2i(2, 7)  # Coordenadas del tile
@export var use_alternative_spawn: bool = false  # Usar PlayerSpawnPosAlternative si está visitada

var num_enemies: int

@onready var tilemap: TileMapLayer = get_node("TileMapLayer2")
@onready var entrance: Node2D = get_node("Entrance")
@onready var door_container: Node2D = get_node("Doors")
@onready var enemy_positions_container: Node2D = get_node("EnemyPositions")
@onready var enemies_container: Node2D = $Enemies
@onready var player_detector: Area2D = get_node("PlayerDetector")
#new
@onready var player_spawn_pos: Node2D = get_node_or_null("PlayerSpawnPos")
@onready var player_spawn_pos_alternative: Node2D = get_node_or_null("PlayerSpawnPosAlternative")
#\new
func _ready() -> void:
	# Verificar si la sala ya fue visitada
	var room_name = get_parent().current_room_name if get_parent() else name
	if GameManager.has_visited_room(room_name):
		# Desactivar PlayerDetector
		use_alternative_spawn = true
		if player_detector:
			var collision_shape = player_detector.get_node_or_null("CollisionShape2D")
			if collision_shape:
				collision_shape.disabled = true
				print("Room.gd: PlayerDetector desactivado para sala visitada:", room_name)
			else:
				printerr("Room.gd: No se encontró CollisionShape2D en PlayerDetector")
		# No contar enemigos si la sala ya fue visitada
		num_enemies = 0
		print("Room.gd: Sala visitada, num_enemies establecido a 0")
		# Opcional: Eliminar nodos de EnemyPositions
		for enemy_position in enemy_positions_container.get_children():
			enemy_position.queue_free()
		enemy_positions_container.queue_free()
		print("Room.gd: EnemyPositions eliminado para sala visitada:", room_name)
	else:
		num_enemies = enemy_positions_container.get_child_count() + enemies_container.get_child_count()
		use_alternative_spawn = false
		print("Room.gd: Se cuenta lo enemigos")
		
	print("Room.gd: num_enemies:", num_enemies)
	if num_enemies == 0:
		_open_doors()
	if not player_detector.body_entered.is_connected(_on_player_detector_body_entered):
		player_detector.body_entered.connect(_on_player_detector_body_entered)
	for door in door_container.get_children():
		if door.has_signal("door_entered"):
			if not door.door_entered.is_connected(_on_door_entered):
				door.door_entered.connect(_on_door_entered)
					
func _on_enemy_killed() -> void:
	num_enemies -= 1
	if num_enemies == 0:
		_open_doors()

func _open_doors() -> void:
	for door in door_container.get_children():
		door.open()
		print("Room.gd: Puerta abierta:", door.name)
		
#Put the specific tile of TileSet in the coordinates of the children Markers2D of Entrance Node Father in the Room0 Scene
func _close_entrance() -> void:
	for entry_position in entrance.get_children():
		var cell_pos = tilemap.local_to_map(entry_position.position)
		print("Room.gd: Cerrando entrada en celda:", cell_pos, "Posición mundo:", entry_position.position)
		tilemap.set_cell(cell_pos, entrance_tile_source_id, entrance_tile_atlas_coords)  # Ajusta source_id y atlas_coords
		print("Room.gd: Tile en", cell_pos, ":", tilemap.get_cell_source_id(cell_pos))

func _spawn_enemies() -> void:
	for enemy_position in enemy_positions_container.get_children():
		var enemy: CharacterBody2D
		if randi()%2 == 0:
			enemy = ENEMY_SCENES.FLYING_CREATURE.instantiate()
		else:
			enemy = ENEMY_SCENES.GOBLIN.instantiate()
			
		enemy.position = enemy_position.global_position 
		call_deferred("add_child", enemy)
		
		var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
		spawn_explosion.position = enemy_position.position
		call_deferred("add_child", spawn_explosion)
		print("Room.gd: Enemigo generado en posición:", enemy_position.position)

func _on_player_detector_body_entered(body: Node2D) -> void:
	print("Room.gd: Cuerpo detectado:", body, "Nombre:", body.name, "Clase:", body.get_class())
	if body.is_in_group("player"):
		print("Room.gd: It is player")
		player_detector.queue_free()
		if num_enemies > 0:
			_close_entrance()
			_spawn_enemies()
		else:
			_close_entrance()
			_open_doors()
			
func _on_door_entered(door: Node2D) -> void:
	print("Room: Señal door_entered recibida en Room, puerta:", door.name, "destino:", door.target_room)
	if door.is_open and door.target_room:
		door_entered.emit(door)
		
func get_spawn_position() -> Vector2:
	# Usar PlayerSpawnPosAlternative si la sala fue visitada y está habilitado
	var room_name = get_parent().current_room_name if get_parent() else name
	if use_alternative_spawn and GameManager.has_visited_room(room_name) and player_spawn_pos_alternative:
		print("Room.gd: Usando PlayerSpawnPosAlternative para sala visitada:", room_name)
		return player_spawn_pos_alternative.position
	elif player_spawn_pos:
		print("Room.gd: Usando PlayerSpawnPos para sala:", room_name)
		return player_spawn_pos.position
	else:
		printerr("Room.gd: No se encontró PlayerSpawnPos ni PlayerSpawnPosAlternative")
		return Vector2.ZERO
		
