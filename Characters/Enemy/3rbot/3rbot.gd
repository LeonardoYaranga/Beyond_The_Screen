extends Enemy

@export var MAX_DISTANCE_TO_PLAYER: float = 300.0  # Radio de detección
@export var MIN_DISTANCE_TO_ATTACK: float = 30.0   # Distancia para atacar

var distance_to_player: float = INF
var selected_attack: int = -1  # 0: normal, 1: wide, 2: dive
var can_attack: bool = true
var attack_selection_done: bool = false

@onready var hitbox_body: Area2D = $HitboxBody
@onready var normal_attack_hitbox: Area2D = $NormalMiniSworld/Hitbox
@onready var special_sworld_1_hitbox: Area2D = $SpecialSworlds/Hitbox
@onready var special_sworld_2_hitbox: Area2D = $SpecialSworlds/Hitbox2
@onready var special_sworld_3_hitbox: Area2D = $SpecialSworlds/Hitbox3
@onready var special_sworld_4_hitbox: Area2D = $SpecialSworlds/Hitbox4
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
	super._ready()
	hitbox_body.monitoring = true
	normal_attack_hitbox.monitoring = false
	special_sworld_1_hitbox.monitoring = false
	special_sworld_2_hitbox.monitoring = false
	special_sworld_3_hitbox.monitoring = false
	special_sworld_4_hitbox.monitoring = false
	attack_timer.wait_time = 2.0
	attack_timer.start()
	print("3rbot _ready: Configuración completa, player válido:", is_instance_valid(player))

func _process(_delta: float) -> void:
	var normalized_velocity = velocity.normalized()
	hitbox_body.knockback_direction = normalized_velocity
	normal_attack_hitbox.knockback_direction = normalized_velocity
	special_sworld_1_hitbox.knockback_direction = normalized_velocity
	special_sworld_2_hitbox.knockback_direction = normalized_velocity
	special_sworld_3_hitbox.knockback_direction = normalized_velocity
	special_sworld_4_hitbox.knockback_direction = normalized_velocity

func _on_path_timer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		#print("Distancia al jugador actualizada:", distance_to_player)
		if state_machine.state == state_machine.states.normal_move or state_machine.state == state_machine.states.disappear:
			_get_path_to_player()
	else:
		print("Jugador no válido en PathTimer")
		distance_to_player = INF
		path_timer.stop()
		mov_direction = Vector2.ZERO

func select_attack() -> int:
	if not can_attack:
		print("3rbot.gd: No se puede atacar, can_attack:", can_attack)
		return -1
	var rand = randf()
	var attack_type := -1
	if rand < 0.6:
		attack_type = 0  # Normal attack (60%)
	elif rand < 0.8:
		attack_type = 1  # Wide attack (30%)
	else:
		attack_type = 2 # Dive attack (20%)
	print("Valor rand:", rand, ", Ataque:", attack_type)
	return attack_type

func normal_move() -> void:
	print("3rbot.gd: Ejecutando normal_move()")
	chase()
	move()

func prepare_attack() -> void:
	mov_direction = Vector2.ZERO
	if not attack_selection_done:
		selected_attack = select_attack()
		print("3rbot.gd: Selected attack:", selected_attack, "can_attack:", can_attack)	
		if selected_attack != -1:
			attack_selection_done = true
			can_attack = false
			print("3rbot.gd: AttackTimer iniciado, can_attack:", can_attack)

func normal_attack() -> void:
	print("3rbot.gd: Ejecutando normal attack()")
	mov_direction = Vector2.ZERO
	normal_attack_hitbox.monitoring = true

func wide_attack() -> void:
	print("3rbot.gd: Ejecutando wide_attack()")
	mov_direction = Vector2.ZERO
	special_sworld_1_hitbox.monitoring = true
	special_sworld_2_hitbox.monitoring = true
	special_sworld_3_hitbox.monitoring = true
	special_sworld_4_hitbox.monitoring = true

func dive_attack() -> void:
	print("3rbot.gd: Ejecutando dive_attack()")
	mov_direction = Vector2.ZERO
	special_sworld_1_hitbox.monitoring = true
	special_sworld_2_hitbox.monitoring = true
	special_sworld_3_hitbox.monitoring = true
	special_sworld_4_hitbox.monitoring = true

func disappear() -> void:
	print("3rbot.gd: Ejecutando disappear()")
	mov_direction = Vector2.ZERO
	collision_shape.disabled = true
	animated_sprite.visible = false
	if is_instance_valid(player):
		navigation_agent.target_position = player.global_position
		print("3rbot.gd: Navegando a player en disappear")

func spawn() -> void:
	print("3rbot.gd: Ejecutando spawn()")
	collision_shape.disabled = false
	animated_sprite.visible = true

func _on_attack_timer_timeout() -> void:
	can_attack = true
	attack_selection_done = false  # Resetear para permitir nueva selección
	print("3rbot.gd: AttackTimer timeout, can_attack:", can_attack, "attack_selection_done:", attack_selection_done)
	
func get_distance_to_player() -> float:
	print("3rbot.gd: Consultando distance_to_player:", distance_to_player)
	return distance_to_player
