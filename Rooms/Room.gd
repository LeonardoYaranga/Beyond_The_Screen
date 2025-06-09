extends Node2D

const SPAWN_EXPLOSION_SCENE: PackedScene = preload("res://Characters/Enemy/spawn_explosion.tscn")

const ENEMY_SCENES: Dictionary = {
	"FLYING_CREATURE": preload("res://Characters/Enemy/FlyingCreature/FlyingCreature.tscn"),
	#More types of enemies.
	#"GOBLIN": preload("res://Characters/Enemies/Goblin/Goblin.tscn"), "SLIME_BOSS": preload("res://Characters/Enemies/Bosses/SlimeBoss.tscn")
}

var num_enemies: int

@onready var tilemap: TileMapLayer = get_node("TileMapLayer2")
@onready var entrance: Node2D = get_node("Entrance")
@onready var door_container: Node2D = get_node("Doors")
@onready var enemy_positions_container: Node2D = get_node("EnemyPositions")
@onready var player_detector: Area2D = get_node("PlayerDetector")
	
func _ready() -> void:
	num_enemies = enemy_positions_container.get_child_count()

func _on_enemy_killed() -> void:
	num_enemies -= 1
	if num_enemies == 0:
		_open_doors()

func _open_doors() -> void:
	for door in door_container.get_children():
		door.open()
		
#Put the specific tile of TileSet in the coordinates of the children Markers2D of Entrance Node Father in the Room0 Scene
func _close_entrance() -> void:
	for entry_position in entrance.get_children():
		var cell_pos = tilemap.local_to_map(entry_position.position)
		print("Cerrando entrada en celda:", cell_pos, "Posición mundo:", entry_position.position)
		tilemap.set_cell(cell_pos, 0, Vector2i(2, 7))  # Ajusta source_id y atlas_coords
		#tilemap.set_cell(cell_pos + Vector2i.DOWN, 0, Vector2i(2, 7))  # Ajusta
		print("Tile en", cell_pos, ":", tilemap.get_cell_source_id(cell_pos))

func _spawn_enemies() -> void:
	for enemy_position in enemy_positions_container.get_children():
		var enemy: CharacterBody2D
		enemy = ENEMY_SCENES.FLYING_CREATURE.instantiate()
		enemy.position = enemy_position.position 
		call_deferred("add_child", enemy)
		
		var spawn_explosion: AnimatedSprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
		spawn_explosion.position = enemy_position.position
		call_deferred("add_child", spawn_explosion)


func _on_player_detector_body_entered(body: Node2D) -> void:
	print("Cuerpo detectado:", body, "Nombre:", body.name, "Clase:", body.get_class())
	print("It isn't player")
	if body.is_in_group("player"):
		print("It is player")
		player_detector.queue_free()
		_close_entrance()
		_spawn_enemies()
	
	#if num_enemies > 0:
		#_close_entrance()
		#_spawn_enemies()
	#else:
		#_close_entrance()
		#_open_doors()
