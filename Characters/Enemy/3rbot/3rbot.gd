extends Enemy

@export var MAX_DISTANCE_TO_PLAYER: float = 300.0  # Radio de detección
@export var MIN_DISTANCE_TO_ATTACK: float = 40.0   # Distancia para atacar
@export var ATTACK_SPEED_CHANGE_FACTOR: float = 0.3    # Factor de reducción de velocidad (50%)

var distance_to_player: float = INF
var selected_attack: int = -1  # 0: normal, 1: wide, 2: dissapear
var selected_action_type: int = -1 # 0: spawn, 1: dive_attack
var can_attack: bool = true
var attack_selection_done: bool = false
var can_move_in_disappear: bool = false  # Controla si puede moverse durante disappear
var action_selection_done : bool = false
var default_acceleration: float
var default_max_speed: float

@onready var hitbox_body: Area2D = $HitboxBody
@onready var normal_attack_hitbox: Area2D = $NormalMiniSword/Hitbox
@onready var special_sword_1_hitbox: Area2D = $SpecialSworlds/Hitbox
@onready var special_sword_2_hitbox: Area2D = $SpecialSworlds/Hitbox2
@onready var special_sword_3_hitbox: Area2D = $SpecialSworlds/Hitbox3
@onready var special_sword_4_hitbox: Area2D = $SpecialSworlds/Hitbox4
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var cannot_move_delay_timer: Timer = %CannotMoveDelayTimer

func _ready() -> void:
	super._ready()
	hitbox_body.monitoring = true
	normal_attack_hitbox.monitoring = false
	special_sword_1_hitbox.monitoring = false
	special_sword_2_hitbox.monitoring = false
	special_sword_3_hitbox.monitoring = false
	special_sword_4_hitbox.monitoring = false
	attack_timer.wait_time = 1.5
	attack_timer.start()
	cannot_move_delay_timer.wait_time = 0.5
	default_acceleration = acceleration
	default_max_speed = max_speed
	#print("3rbot _ready: Configuración completa, player válido:", is_instance_valid(player))

func _process(_delta: float) -> void:
	var normalized_velocity = velocity.normalized()
	hitbox_body.knockback_direction = normalized_velocity
	normal_attack_hitbox.knockback_direction = normalized_velocity
	special_sword_1_hitbox.knockback_direction = normalized_velocity
	special_sword_2_hitbox.knockback_direction = normalized_velocity
	special_sword_3_hitbox.knockback_direction = normalized_velocity
	special_sword_4_hitbox.knockback_direction = normalized_velocity
	#print("3rbot.gd _process: Estado actual:", state_machine.state, "mov_direction:", mov_direction)

func _on_path_timer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		#print("Distancia al jugador actualizada:", distance_to_player)
		if state_machine.state == state_machine.states.normal_move or state_machine.state == state_machine.states.normal_attack or state_machine.state == state_machine.states.disappear:
			_get_path_to_player()
	else:
		#print("Jugador no válido en PathTimer")
		distance_to_player = INF
		path_timer.stop()
		mov_direction = Vector2.ZERO

func select_attack() -> int:
	if not can_attack:
		#print("3rbot.gd: No se puede atacar, can_attack:", can_attack)
		return -1
	var rand = randf()
	var attack_type := -1
	if rand < 0.6:
		attack_type = 0  # Normal attack (60%)
	elif rand < 0.8:
		attack_type = 1  # Wide attack (30%)
	else:
		attack_type = 2 # Dissapear (20%)
	#print("3rbot.gd: Valor rand:", rand, ", Ataque:", attack_type)
	return attack_type

func select_action_after_dissapear() -> int:
	#if not can_attack:
		#print("3rbot.gd: No se puede atacar, can_attack:", can_attack)
		#return -1
	var rand = randf()
	var action_type:= -1
	if rand < 0.5:
		action_type = 0  # Respawn (60%)
	else:
		action_type = 1  # Dive Attack (30%)
	
	#print("3rbot.gd: Valor rand:", rand, ", Acción después de disappear:", action_type)
	return action_type

func normal_move() -> void:
	#print("3rbot.gd: Ejecutando normal_move()")
	chase()
	move()

func prepare_attack() -> void:
	normal_move()
	if not attack_selection_done:
		selected_attack = select_attack()
		#print("3rbot.gd: Selected attack:", selected_attack, "can_attack:", can_attack)	
		if selected_attack != -1:
			attack_selection_done = true
			attack_timer.start()
			#print("3rbot.gd: AttackTimer iniciado, can_attack:", can_attack)

func disappear() -> void:
	#print("3rbot.gd: Ejecutando disappear()")
	if not action_selection_done:
		selected_action_type = select_action_after_dissapear()
		action_selection_done = true
		can_move_in_disappear = false
		cannot_move_delay_timer.start()
		#print("3rbot.gd: CannotMoveDelayTimer iniciado, selected_action_type:", selected_action_type)
	if cannot_move_delay_timer.is_stopped() and can_move_in_disappear:
		#print("3rbot.gd: Persiguiendo al jugador en disappear")
		acceleration = default_acceleration / ATTACK_SPEED_CHANGE_FACTOR
		max_speed = default_max_speed / ATTACK_SPEED_CHANGE_FACTOR
		normal_move()
	else:
		mov_direction = Vector2.ZERO
		#print("3rbot.gd: mov_direction en ZERO durante disappear")
	if is_instance_valid(player):
		navigation_agent.target_position = player.global_position
		#print("3rbot.gd: Actualizando target_position a jugador en disappear")
		
func normal_attack() -> void:
	#print("3rbot.gd: Ejecutando normal attack()")
	acceleration = default_acceleration * ATTACK_SPEED_CHANGE_FACTOR
	max_speed = default_max_speed * ATTACK_SPEED_CHANGE_FACTOR
	normal_move()
	normal_attack_hitbox.monitoring = true


func _on_cannot_move_delay_timer_timeout() -> void:
	can_move_in_disappear = true
	#print("3rbot.gd: DisappearDelayTimer timeout, can_move_in_disappear:", can_move_in_disappear)

func _on_attack_timer_timeout() -> void:
	can_attack = true
	attack_selection_done = false  # Resetear para permitir nueva selección
	action_selection_done = false
	#print("3rbot.gd: AttackTimer timeout, can_attack:", can_attack, "attack_selection_done:", attack_selection_done)
	

func wide_attack() -> void:
	#print("3rbot.gd: Ejecutando wide_attack()")
	mov_direction = Vector2.ZERO
	special_sword_1_hitbox.monitoring = true
	special_sword_2_hitbox.monitoring = true
	special_sword_3_hitbox.monitoring = true
	special_sword_4_hitbox.monitoring = true

func dive_attack() -> void:
	#print("3rbot.gd: Ejecutando dive_attack()")
	mov_direction = Vector2.ZERO
	special_sword_1_hitbox.monitoring = true
	special_sword_2_hitbox.monitoring = true
	special_sword_3_hitbox.monitoring = true
	special_sword_4_hitbox.monitoring = true

func spawn() -> void:
	#print("3rbot.gd: Ejecutando spawn()")
	mov_direction = Vector2.ZERO
	
func get_distance_to_player() -> float:
	#print("3rbot.gd: Consultando distance_to_player:", distance_to_player)
	return distance_to_player
