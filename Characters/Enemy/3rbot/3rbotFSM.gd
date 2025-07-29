extends FiniteStateMachine

func _init() -> void:
	_add_state("idle")
	_add_state("normal_move")
	_add_state("move_prepare_to_attack")
	_add_state("normal_attack")
	_add_state("wide_attack")
	_add_state("dive_attack")
	_add_state("disappear")
	_add_state("spawn")
	_add_state("return_to_idle")
	_add_state("hurt")
	_add_state("dead")


func _ready() -> void:
	set_state(states.idle)

func _state_logic(_delta: float) -> void:
	print("3rbotFSM.gd: Ejecutando _state_logic, estado actual:", state)
	match state:
		states.normal_move:
			parent.normal_move()
		states.move_prepare_to_attack:
			parent.prepare_attack()
		states.normal_attack:
			parent.normal_attack()
		states.wide_attack:
			parent.wide_attack()
		states.dive_attack:
			parent.dive_attack()
		states.disappear:
			parent.disappear()
		states.spawn:
			parent.spawn()

func _get_transition() -> int:
	print("3rbotFSM.gd: Evaluando transición, estado actual:", state, "distancia:", parent.distance_to_player, "can_attack:", parent.can_attack)
	match state:
		states.idle:
			if parent.distance_to_player <= parent.MIN_DISTANCE_TO_ATTACK and parent.can_attack:
				print("3rbotFSM.gd: Transición directa de idle a move_prepare_to_attack")
				return states.move_prepare_to_attack
			# Transición a normal_move si el jugador está fuera del rango de ataque pero dentro del rango de persecució
			elif parent.distance_to_player <= parent.MAX_DISTANCE_TO_PLAYER:
				print("3rbotFSM.gd: Transición de idle a normal_move, distancia:", parent.distance_to_player)
				return states.normal_move
		states.normal_move:
			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER:
				print("Transición de normal_move a idle, distancia:", parent.distance_to_player)
				return states.idle
			if parent.distance_to_player <= parent.MIN_DISTANCE_TO_ATTACK and parent.can_attack:
				print("Transición de normal_move a move_prepare_to_attack")
				return states.move_prepare_to_attack
		states.move_prepare_to_attack:
			if not animation_player.is_playing():
				print("3rbotFSM.gd: move_prepare_to_attack terminado, selected_attack:", parent.selected_attack)
				match parent.selected_attack:
					0:
						print("3rbotFSM.gd: Transición a normal_attack")
						return states.normal_attack
					1:
						print("3rbotFSM.gd: Transición a wide_attack")
						return states.wide_attack
					2:
						print("3rbotFSM.gd: Transición a disappear")
						return states.disappear
					_:
						print("3rbotFSM.gd: Sin ataque seleccionado, volviendo a idle")
						return states.idle
		states.normal_attack, states.wide_attack, states.dive_attack:
			if not animation_player.is_playing():
				print("3rbotFSM.gd: Ataque terminado, transición a return_to_idle")
				return states.return_to_idle
		states.disappear:
			if not animation_player.is_playing():
				print("3rbotFSM.gd: Transición de disappear a spawn")
				return states.spawn
		states.spawn:
			if not animation_player.is_playing():
				print("3rbotFSM.gd: Transición de spawn a dive_attack")
				return states.dive_attack
		states.return_to_idle:
			if not animation_player.is_playing():
				print("3rbotFSM.gd: Transición de return_to_idle a idle")
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				print("3rbotFSM.gd: Transición de hurt a idle")
				return states.idle
	return -1

func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			animation_player.play("idle")
		states.normal_move:
			animation_player.play("normal_move")
		states.move_prepare_to_attack:
			animation_player.play("move_prepare_to_attack")
		states.normal_attack:
			animation_player.play("normal_attack")
		states.wide_attack:
			animation_player.play("wide_attack")
		states.dive_attack:
			animation_player.play("dive_attack")
		states.disappear:
			animation_player.play("disappear")
		states.spawn:
			animation_player.play("spawn")
		states.return_to_idle:
			animation_player.play("return_to_idle")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			animation_player.play("dead")

func _exit_state(state_exited: int) -> void:
	print("3rbotFSM.gd: Saliendo de estado:", state_exited)
	match state_exited:
		states.normal_attack:
			parent.normal_attack_hitbox.monitoring = false
		states.wide_attack:
			parent.special_sworld_1_hitbox.monitoring = false
			parent.special_sworld_2_hitbox.monitoring = false
			parent.special_sworld_3_hitbox.monitoring = false
			parent.special_sworld_4_hitbox.monitoring = false
		states.dive_attack:
			parent.special_sworld_1_hitbox.monitoring = false
			parent.special_sworld_2_hitbox.monitoring = false
			parent.special_sworld_3_hitbox.monitoring = false
			parent.special_sworld_4_hitbox.monitoring = false
