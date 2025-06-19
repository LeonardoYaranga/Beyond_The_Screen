extends Character

@onready var sword: Node2D = get_node("Sword")
@onready var sword_hitbox: Area2D = get_node("Sword/Node2D/Sprite2D/Hitbox")
@onready var sword_animation_player: AnimationPlayer = sword.get_node("SwordAnimationPlayer")


func _process(_delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position()-global_position).normalized()
	sword.rotation = mouse_direction.angle()
	sword_hitbox.knockback_direction = mouse_direction
	if mouse_direction.x > 0 and animated_sprite.flip_h and sword.scale.y == -1:
		animated_sprite.flip_h = false
		sword.scale.y = 1
	elif  mouse_direction.x < 0 and not animated_sprite.flip_h and sword.scale.y == 1:
		animated_sprite.flip_h = true
		sword.scale.y = -1
	
func get_input() -> void:
	mov_direction=Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		mov_direction+= Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		mov_direction+= Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		mov_direction+= Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		mov_direction+= Vector2.UP
	if Input.is_action_just_pressed("ui_attack") and not sword_animation_player.is_playing(): #Se creo el ui_attack como un Input map en Project/ProjectSettings/ 2D Physics 
		sword_animation_player.play("attack")	#El attack es una animacion que se creo en el SwordAnimationPlayer

func activate_player_camera() -> void:
	var player_camera = $Camera2D
	if player_camera is Camera2D:
		player_camera.make_current()
		print("Player Camera2D activated, is current?: ", player_camera.is_current())
	else:
		print("No se encontró la Camera2D del Player.")

func switch_camera() -> void:
	var main_scene_camera = get_parent().get_node("Camera2D")
	if main_scene_camera is Camera2D:
		main_scene_camera.position = position
		main_scene_camera.make_current()
		print($Camera2D.get_class()," is current?: ", $Camera2D.is_current())
	else:
		print("No se encontró una Camera2D válida.")
