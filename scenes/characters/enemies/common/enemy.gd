@icon("res://assets/art/packs/dungeon_crawler_16x16/enemies/goblin/goblin_idle_anim_f_0.png")

extends Character
class_name Enemy


@onready var path_timer: Timer = get_node("PathTimer")
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
var player: CharacterBody2D = null
var _room: Node = null
var _has_reported_death: bool = false

func _ready() -> void:
	_room = _find_room()
	if not tree_exiting.is_connected(_on_tree_exiting):
		tree_exiting.connect(_on_tree_exiting)
	update_player_reference()

func _on_tree_exiting() -> void:
	if hp <= 0 and not _has_reported_death:
		var room: Node = _room if is_instance_valid(_room) else _find_room()
		if is_instance_valid(room) and not _is_node_or_ancestor_queued_for_deletion(room) and room.has_method("_on_enemy_killed"):
			_has_reported_death = true
			room._on_enemy_killed()

func _is_node_or_ancestor_queued_for_deletion(node: Node) -> bool:
	var current: Node = node
	while is_instance_valid(current):
		if current.is_queued_for_deletion():
			return true
		current = current.get_parent()
	return false

func _find_room() -> Node:
	var p = get_parent()
	while p:
		if p.has_method("_on_enemy_killed"):
			return p
		p = p.get_parent()
	return null

func update_player_reference() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]  # Tomar el primer nodo en el grupo "player"
		print("Enemy.gd: Jugador encontrado:", player.scene_file_path)
	else:
		player = null
		print("Enemy.gd: No se encontró jugador en el grupo 'player'")
		
func chase() -> void:
	if not navigation_agent.is_target_reached():
		var next_point: Vector2 = navigation_agent.get_next_path_position()
		var vector_to_next_point: Vector2 = (next_point - global_position).normalized()
		mov_direction = vector_to_next_point
		#print("Dirección de movimiento enemy.gd:", mov_direction)
		if vector_to_next_point.x > 0 and animated_sprite.flip_h:
			animated_sprite.flip_h = false
		elif vector_to_next_point.x < 0 and not animated_sprite.flip_h:
			animated_sprite.flip_h = true

func _get_path_to_player() -> void:
	navigation_agent.target_position = player.position

func _on_path_timer_timeout() -> void:
	if is_instance_valid(player):
		_get_path_to_player()
	else:
		path_timer.stop()
		mov_direction = Vector2.ZERO
