extends FiniteStateMachine

func _init() -> void:
	_add_state("walk")
	_add_state("hurt")
	_add_state("dead")
	
	
func _ready() -> void:
	set_state(states.walk)
	
	
func _state_logic(_delta: float) -> void:
	#print("Estado actual flyingCreatureFSM:", state)
	if state == states.walk:
		parent.chase()
		parent.move()
		
		
func _get_transition() -> int:
	match state:
		states.hurt:
			if not animation_player.is_playing():
				return states.walk
	return -1
	
	
func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.walk:
			animation_player.play("walk")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			animation_player.play("dead")
