extends Character
class_name NPC

signal interacted(npc: NPC)

@export var dialogue_file: Resource  # Para seleccionar el archivo .dialogue en el editor
var can_interact: bool = false

var is_dialogue_active: bool = false  # Indica si el diálogo está en curso
var interacting_player: Node = null
var current_balloon: Node = null  # Referencia al globo de diálogo actual

@onready var interaction_area: Area2D = $InteractionArea
@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine

func _ready() -> void:
	# Desactivar movimiento por física para NPCs estáticos
	set_physics_process(false)
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)
		# Depurar la configuración de InteractionArea
		var collision_shape = interaction_area.get_node("CollisionShape2D")
		if collision_shape:
			if collision_shape.shape is CircleShape2D:
				print("NPC: InteractionArea usa círculo, radio:", collision_shape.shape.radius)
			elif collision_shape.shape is RectangleShape2D:
				print("NPC: InteractionArea usa rectángulo, tamaño:", collision_shape.shape.size)
		else:
			print("Error: No se encontró CollisionShape2D en InteractionArea")
		print("NPC: InteractionArea conectada correctamente")
	else:
		print("Error: No se encontró InteractionArea en", name)
		
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _input(_event: InputEvent) -> void:
	if can_interact and Input.is_action_just_pressed("ui_interact") and not is_dialogue_active:
		print("NPC: Iniciando interacción con", name, "interacting_player:", interacting_player)
		# Guardar interacting_player localmente para evitar que se borre
		var local_player = interacting_player
		# Desactivar el área de interacción para evitar eventos de salida
		if interaction_area:
			interaction_area.monitoring = false
			interaction_area.monitorable = false
			print("NPC: Área de interacción desactivada")
		else:
			print("Error: interaction_area es null")
		if local_player:
			interacted.emit(self)
			finite_state_machine.set_state(finite_state_machine.states.talk)  # Cambiar al estado talk pal NPC
			start_dialogue(local_player)
		else:
			print("Error: interacting_player es null al presionar 'E'")

func start_dialogue(player: Node) -> void:
	if dialogue_file == null:
		print("Error: No se ha asignado un archivo de diálogo para", name)
		is_dialogue_active = false
		if interaction_area:
			interaction_area.monitoring = true
			interaction_area.monitorable = true
		return
	
	is_dialogue_active = true
	interacting_player = player # Restaurar interacting_player
	print("NPC: Iniciando diálogo con archivo", dialogue_file.resource_path)
	# Iniciar el diálogo con Dialogue Manager
	current_balloon = await DialogueManager.show_dialogue_balloon(dialogue_file, "start")
	print("NPC: current_balloon asignado:", current_balloon)
	
	pause_player_if_exist(interacting_player)
	
	# Esperamos a dialogue_ended para limpiar
	
func pause_player_if_exist(interacting_player: CharacterBody2D) -> void:
	if interacting_player:
		var player_fsm = interacting_player.get_node("FiniteStateMachine")
		if player_fsm:
			print("NPC: Cambiando estado del jugador a paused")
			player_fsm.set_state(player_fsm.states.paused)
		else:
			print("Error: No se encontró la FSM del jugador")
	else:
		print("Error: No hay interacting_player asignado en start_dialogue")
		is_dialogue_active = false
		if interaction_area:
			interaction_area.monitoring = true
			interaction_area.monitorable = true
		return
		
func restore_the_state_of_player_if_exist(interacting_player : CharacterBody2D) -> void:
	if interacting_player:
			var player_fsm = interacting_player.get_node("FiniteStateMachine")
			if player_fsm:
				var previous_state = player_fsm.previous_state if player_fsm.previous_state != -1 else player_fsm.states.idle
				print("NPC: Restaurando estado del jugador a", previous_state)
				player_fsm.set_state(previous_state)
			else:
				print("Error: No se encontró la FSM del jugador al restaurar")
				
func _on_dialogue_ended(_resource: DialogueResource) -> void:
	if is_dialogue_active:
		print("NPC: Diálogo terminado (señal dialogue_ended)")
		is_dialogue_active = false
		if current_balloon:
			current_balloon.queue_free()
			current_balloon = null
		if interaction_area:
			interaction_area.monitoring = true
			interaction_area.monitorable = true
			print("NPC: Área de interacción reactivada") 
		# Restaurar el estado del jugador
		restore_the_state_of_player_if_exist(interacting_player)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_interact = true
		interacting_player = body
		print("Player cerca de", name, "Presiona 'E' para interactuar, body:", body.name)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("NPC: Jugador salió del área de", name, "is_dialogue_active:", is_dialogue_active)
		can_interact = false
			
func _on_dialogue_started(dialogue) -> void:
	is_dialogue_active = true
	
