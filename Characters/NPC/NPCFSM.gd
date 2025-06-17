extends FiniteStateMachine

func _init() -> void:
	_add_state("idle")
	_add_state("talk")

func _ready() -> void:
	set_state(states.idle)

func _state_logic(_delta: float) -> void:
	pass

func _get_transition() -> int:
	return -1

func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			animation_player.play("idle")
		states.talk:
			animation_player.play("talk")
