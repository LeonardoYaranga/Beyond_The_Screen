@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/heroes/knight/knight_idle_anim_f0.png")

extends CharacterBody2D
class_name Character

const FRICTION: float = 0.15

@export var max_hp: int = 4
@export var hp: int = max_hp : set = set_hp
signal hp_changed(new_hp)

@export var acceleration:int = 40
@export var max_speed: int = 100

@onready var state_machine: Node = get_node("FiniteStateMachine")
@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

var mov_direction: Vector2 = Vector2.ZERO

# Se ejecuta cada frame físico
func _physics_process(_delta: float) -> void:
	move_and_slide()
	velocity= lerp(velocity,Vector2.ZERO,FRICTION)
	
func move() -> void:
	#print("Moviendo con mov_direction:", mov_direction)
	mov_direction = mov_direction.normalized()
	velocity += mov_direction * acceleration
	velocity = velocity.limit_length(max_speed)
	
func take_damage(dam: int , dir: Vector2, force: int) -> void:
		self.hp-= dam
		if hp > 0:
			state_machine.set_state(state_machine.states.hurt)
			velocity += dir * force
		else:
			state_machine.set_state(state_machine.states.dead)
			velocity += dir * force * 2
			
func set_hp(new_hp: int) -> void:
	hp = clamp(new_hp, 0, max_hp)
	emit_signal("hp_changed", hp)
