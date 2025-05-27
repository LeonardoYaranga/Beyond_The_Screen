extends Character

@onready var sword: Node2D = get_node("Sword")
@onready var sword_animation_player: AnimationPlayer = sword.get_node("SwordAnimationPlayer")
func _process(_delta: float) -> void:
	var mouse_direction: Vector2 = (get_global_mouse_position()-global_position).normalized()
	
	sword.rotation = mouse_direction.angle()
	
	if mouse_direction.x > 0 and animated_sprite.flip_h and sword.scale.y == -1:
		animated_sprite.flip_h = false
		sword.scale.y = 1
	elif  mouse_direction.x < 0 and not animated_sprite.flip_h and sword.scale.y == 1:
		animated_sprite.flip_h = true
		sword.scale.y = -1
	
	if Input.is_action_just_pressed("ui_attack") and not sword_animation_player.is_playing(): #Se creo el ui_attack como un Input map en Project/ProjectSettings/ 2D Physics 
		sword_animation_player.play("attack")	#El attack es una animacion que se creo en el SwordAnimationPlayer
	
	
		
	
	 
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
	
