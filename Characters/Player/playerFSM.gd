extends FiniteStateMachine
signal player_died  # Señal para notificar la muerte del jugador

func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("hurt")
	_add_state("dead")
	_add_state("paused")  # Nuevo estado para pausar al jugador
	
func _ready() -> void:
	set_state(states.idle)
	
func _state_logic(_delta: float) -> void:
	if state == states.idle or state == states.move:
		parent.get_input()
		parent.move()
	#no se hace nada en paused
	#if state == states.paused:
		#parent.set_process(false)  # Desactiva _process
		#parent.set_physics_process(false)  # Desactiva _physics_process 
		
func _get_transition() -> int:
	match state:
		states.idle:
			if parent.velocity.length() > 10:
				return states.move
		states.move:
			if parent.velocity.length() < 10:
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				return states.idle
		states.paused:
			print("PlayerFSM.gd: Player en estado paused")
			# No transicionamos automáticamente desde paused; el NPC controlará la salida
			pass
	return -1
	
func _enter_state(_previous_state: int, new_state: int) -> void:
	if new_state == states.paused:
		previous_state = _previous_state  # Guardar el estado anterior
		parent.is_paused = true  # Desactiva movimiento físico)
		print("PlayerFSM: Entrando en estado paused")
	elif _previous_state == states.paused:
		parent.is_paused = false  # Reactiva movimiento físico
		print("PlayerFSM: Saliendo de estado paused, restaurando a", new_state)
	match new_state:
		states.idle:
			animation_player.play("idle")
		states.move:
			animation_player.play("move")
		states.hurt:
			animation_player.play("hurt")
			#parent.cancel_attack()
		states.dead:
			animation_player.play("dead")
			emit_signal("player_died")
			print("PlayerFSM.gd: Jugador murió, emitiendo player_died")
			#parent.cancel_attack()
		states.paused:
			animation_player.play("idle")  # Usar animación idle mientras está pausado
