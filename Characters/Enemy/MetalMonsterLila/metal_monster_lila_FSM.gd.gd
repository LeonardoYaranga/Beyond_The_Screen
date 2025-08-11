extends FiniteStateMachine

func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("attack")
	_add_state("hurt")
	_add_state("dead")

func _ready() -> void:
	set_state(states.idle)

func _state_logic(delta: float) -> void:
	match state:
		states.move:
			parent.chase()
			parent.move()
		states.attack:
			parent.attack()

func _get_transition() -> int:
	match state:
		states.idle:
			if parent.distance_to_player <= parent.MAX_DISTANCE_TO_PLAYER and parent.distance_to_player >= parent.MIN_DISTANCE_TO_ATTACK:
				return states.move
		states.move:
			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER:
				return states.idle
			if parent.distance_to_player <= parent.MIN_DISTANCE_TO_ATTACK:
				return states.attack
		states.attack:
			if not animation_player.is_playing():
				if parent.distance_to_player > parent.MIN_DISTANCE_TO_ATTACK:
					return states.move
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				return states.idle
		states.dead:
			if not animation_player.is_playing():
				parent.queue_free()
	return -1

func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			animation_player.play("idle")
		states.move:
			animation_player.play("move")
		states.attack:
			animation_player.play("attack")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			animation_player.play("dead")

func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.attack:
			parent.hitbox.monitoring = false
