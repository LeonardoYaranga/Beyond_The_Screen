extends StaticBody2D

signal door_entered(door: Node2D)

@export var target_room: String = ""  # Sala destino (por ejemplo, "room1_5")
var is_open: bool = false

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var detector: Area2D = get_node("Detector")

func _ready() -> void:
	if detector:
		detector.body_entered.connect(_on_detector_body_entered)
	else:
		printerr("Error: Nodo 'Detector' (Area2D) no encontrado en Door")
	if is_open:
		collision_shape.disabled = true

func open() -> void:
	if not is_open:
		is_open = true
		animation_player.play("open")

func _on_detector_body_entered(body: Node2D) -> void:
	print("Cuerpo en puerta detectado")
	if body.is_in_group("player") and is_open:
		print("Door: Player cruzó la puerta, destino:", target_room)
		door_entered.emit(self)
