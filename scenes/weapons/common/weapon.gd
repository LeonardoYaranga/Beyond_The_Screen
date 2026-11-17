@icon("res://assets/art/packs/dungeon_crawler_16x16/heroes/knight/weapon_sword_1.png")

extends Node2D
class_name Weapon

@export var on_floor: bool = false

@export var ranged_weapon: bool = false
@export var rotation_offset: int = 0

var can_active_ability: bool = true

var tween: Tween = null
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var hitbox: Area2D = get_node("Node2D/Sprite2D/Hitbox")
@onready var charge_particles: GPUParticles2D = get_node("Node2D/Sprite2D/ChargeParticles")
@onready var player_detector: Area2D = get_node("PlayerDetector")
@onready var cool_down_timer: Timer = get_node("CoolDownTimer")
@onready var ui: CanvasLayer = get_node("UI")
@onready var ability_icon: TextureProgressBar = ui.get_node("AbilityIcon")


func _ready() -> void:
	if not on_floor:
		player_detector.set_collision_mask_value(1, false)
		player_detector.set_collision_mask_value(2, false)
	else:
		if ability_icon:
			ability_icon.hide()

	connect("draw", _on_show)
	connect("hidden", _on_hide)


func get_input() -> void:
	if Input.is_action_just_pressed("ui_attack") and not animation_player.is_playing():
		animation_player.play("charge")
	elif Input.is_action_just_released("ui_attack"):
		if animation_player.is_playing() and animation_player.current_animation == "charge":
			animation_player.play("attack")
		elif charge_particles.emitting:
			animation_player.play("strong_attack")
	elif Input.is_action_just_pressed("ui_active_ability") and animation_player.has_animation("active_ability") and not is_busy() and can_active_ability:
		can_active_ability = false
		cool_down_timer.start()
		ui.recharge_ability_animation(cool_down_timer.wait_time)
		animation_player.play("active_ability")


func move(mouse_direction: Vector2) -> void:
	if ranged_weapon:
		rotation_degrees = rad_to_deg(mouse_direction.angle()) + rotation_offset
	else:
		if not animation_player.is_playing() or animation_player.current_animation == "charge":
			rotation = mouse_direction.angle()
			hitbox.knockback_direction = mouse_direction
			if scale.y == 1 and mouse_direction.x < 0:
				scale.y = -1
			elif scale.y == -1 and mouse_direction.x > 0:
				scale.y = 1


func cancel_attack() -> void:
	animation_player.play("RESET")


func is_busy() -> bool:
	if animation_player.is_playing() or charge_particles.emitting:
		return true
	return false

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body != null and body.is_in_group("player") and body.has_method("pick_up_weapon"):
		on_floor = false
		player_detector.set_collision_mask_value(1, false)
		player_detector.set_collision_mask_value(2, false)
		body.pick_up_weapon(self)
		position = Vector2.ZERO
	elif body == null:
		if tween:
			tween.kill()
		player_detector.set_collision_mask_value(2, true)
	
func interpolate_pos(initial_pos: Vector2, final_pos: Vector2) -> void:
	position = initial_pos
	tween = create_tween()
	tween.tween_property(self, "position", final_pos, 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.connect("finished", _on_Tween_tween_completed)
	player_detector.set_collision_mask_value(1, true)


func _on_Tween_tween_completed() -> void:
	player_detector.set_collision_mask_value(2, true)


func _on_cool_down_timer_timeout() -> void:
	can_active_ability = true


func _on_show() -> void:
	if not on_floor and ability_icon:
		ability_icon.show()


func _on_hide() -> void:
	ability_icon.hide()


func get_texture() -> Texture2D:
	#print("weapon.gd: Obteniendo textura de arma: ", get_node("Node2D/Sprite2D").texture)
	return get_node("Node2D/Sprite2D").texture
