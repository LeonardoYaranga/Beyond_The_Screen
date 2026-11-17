extends Character
class_name NPC

signal interacted(npc: NPC)

@export var timeline_name: String = ""  # Nombre de la timeline de Dialogic 2 a reproducir

var can_interact: bool = false
var is_dialogue_active: bool = false
var interacting_player: Node = null

@onready var interaction_area: Area2D = $InteractionArea
@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine

func _ready() -> void:
	# Desactivar movimiento por física para NPCs estáticos
	set_physics_process(false)
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	else:
		printerr("NPC: No se encontró InteractionArea en ", name)

func _input(_event: InputEvent) -> void:
	if can_interact and Input.is_action_just_pressed("ui_interact") and not is_dialogue_active and not GameManager.is_in_dialogue:
		var local_player = interacting_player
		if not local_player:
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				local_player = players[0]

		if local_player:
			interacted.emit(self)
			if finite_state_machine and "talk" in finite_state_machine.states:
				finite_state_machine.set_state(finite_state_machine.states.talk)
			start_dialogue(local_player)
		else:
			printerr("NPC: No hay interacting_player al presionar 'ui_interact'")

func start_dialogue(player: Node = null) -> void:
	if timeline_name.is_empty():
		printerr("NPC: No se ha asignado timeline_name para ", name)
		return

	is_dialogue_active = true
	interacting_player = player
	if interaction_area:
		interaction_area.monitoring = false
		interaction_area.monitorable = false

	DialogicBridge.start_dialogue(timeline_name, player, self)

## Invocado por DialogicBridge cuando la timeline termina
func _on_dialogue_finished_by_bridge() -> void:
	is_dialogue_active = false
	if interaction_area:
		interaction_area.monitoring = true
		interaction_area.monitorable = true
	if finite_state_machine and "idle" in finite_state_machine.states:
		finite_state_machine.set_state(finite_state_machine.states.idle)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = true
		interacting_player = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = false
		if not is_dialogue_active:
			interacting_player = null
