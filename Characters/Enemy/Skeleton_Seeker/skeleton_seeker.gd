@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/goblin/goblin_idle_anim_f0.png")

extends Character
class_name skeletonSeeker

@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")
@onready var path_timer: Timer = get_node("PathTimer")
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")


func _ready() -> void:
	var __ = connect("tree_exited", Callable(get_parent(), "_on_enemy_killed"))
	animation_player.play("idle")
 
func chase() -> void:
	if not navigation_agent.is_target_reached():
		var vector_to_next_point: Vector2 = navigation_agent.get_next_path_position() - global_position
		mov_direction = vector_to_next_point
		#print("Dirección de movimiento enemy.gd:", mov_direction)
		if vector_to_next_point.x > 0 and animated_sprite.flip_h:
			animated_sprite.flip_h = false
		elif vector_to_next_point.x < 0 and not animated_sprite.flip_h:
			animated_sprite.flip_h = true

func _get_path_to_player() -> void:
	navigation_agent.target_position = player.position

func _on_path_timer_timeout() -> void:
	#print("Actualizando camino")
	if is_instance_valid(player):
		_get_path_to_player()
	else:
		path_timer.stop()
		mov_direction = Vector2.ZERO
