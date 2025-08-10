extends Enemy

@export var MAX_DISTANCE_TO_PLAYER: float = 200.0  # Radio de detección
@export var MIN_DISTANCE_TO_ATTACK: float = 10.0   # Distancia para atacar

var distance_to_player: float = INF

@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super._ready()  # Llama a _ready de Enemy.gd
	hitbox.monitoring = false

func _on_path_timer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		if state_machine.state == state_machine.states.move:
			_get_path_to_player()
	else:
		distance_to_player = INF
		path_timer.stop()
		mov_direction = Vector2.ZERO

func attack() -> void:
	mov_direction = Vector2.ZERO
	hitbox.monitoring = true
