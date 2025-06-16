extends Character
class_name NPC

signal interacted(npc: NPC)

@export var dialogue_lines: Array[String] = ["¡Hola, viajero!"]  # Líneas de diálogo
var can_interact: bool = false
var interacting_player: Node = null

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	# Desactivar movimiento por física para NPCs estáticos
	set_physics_process(false)
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _input(_event: InputEvent) -> void:
	if can_interact and Input.is_action_just_pressed("ui_interact"):  # Crear "ui_interact" en Input Map
		interacted.emit(self)
		start_dialogue()

func start_dialogue() -> void:
	# Aquí integraremos un sistema de diálogo más adelante
	print("NPC dice:", dialogue_lines[0])

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = true
		interacting_player = body
		print("Player cerca de", name, "Presiona 'E' para interactuar")

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = false
		interacting_player = null
		print("Player salió del área de", name)
