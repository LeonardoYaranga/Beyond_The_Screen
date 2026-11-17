extends Node

## Puente entre Dialogic 2, GameManager, Player y VideoSceneTransistor.
## Autoload: DialogicBridge

signal dialogue_started(timeline_name: String)
signal dialogue_ended(timeline_name: String)

var _is_dialogue_active: bool = false
var _current_timeline: String = ""
var _active_player: Node = null
var _active_npc: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_dialogic.call_deferred()

func _connect_dialogic() -> void:
	if is_instance_valid(Dialogic):
		if not Dialogic.timeline_ended.is_connected(_on_dialogic_timeline_ended):
			Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)
	else:
		push_warning("[DialogicBridge] Autoload Dialogic no encontrado.")

func is_dialogue_active() -> bool:
	return _is_dialogue_active

## Inicia una línea de tiempo de Dialogic y bloquea el control del jugador.
func start_dialogue(timeline_name: String, player: Node = null, npc: Node = null) -> bool:
	if not is_instance_valid(Dialogic):
		printerr("[DialogicBridge] Dialogic no es válido!")
		return false
	
	if _is_dialogue_active:
		push_warning("[DialogicBridge] Ya hay un diálogo en curso: %s" % _current_timeline)
		return false

	_is_dialogue_active = true
	_current_timeline = timeline_name
	_active_npc = npc
	GameManager.is_in_dialogue = true

	# Asignar o buscar jugador
	if player:
		_active_player = player
	else:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			_active_player = players[0]
		else:
			_active_player = null

	_pause_player(_active_player)
	dialogue_started.emit(timeline_name)

	Dialogic.start(timeline_name)
	return true

func _on_dialogic_timeline_ended() -> void:
	var ended_timeline := _current_timeline
	_current_timeline = ""
	_is_dialogue_active = false
	GameManager.is_in_dialogue = false

	_restore_player(_active_player)
	_active_player = null

	if is_instance_valid(_active_npc) and _active_npc.has_method("_on_dialogue_finished_by_bridge"):
		_active_npc._on_dialogue_finished_by_bridge()
	_active_npc = null

	dialogue_ended.emit(ended_timeline)

func _pause_player(player_node: Node) -> void:
	if is_instance_valid(player_node):
		var fsm = player_node.get_node_or_null("FiniteStateMachine")
		if fsm and fsm.has_method("set_state") and "states" in fsm and "paused" in fsm.states:
			fsm.set_state(fsm.states.paused)
		elif "is_paused" in player_node:
			player_node.is_paused = true

func _restore_player(player_node: Node) -> void:
	if is_instance_valid(player_node):
		var fsm = player_node.get_node_or_null("FiniteStateMachine")
		if fsm and fsm.has_method("set_state") and "states" in fsm and "idle" in fsm.states:
			fsm.set_state(fsm.states.idle)
		elif "is_paused" in player_node:
			player_node.is_paused = false

## Método para ejecutar videos cinemáticos dentro de Dialogic esperando a que terminen.
## Uso en timeline: do DialogicBridge.play_dialogue_video("res://assets/videos/...")
func play_dialogue_video(video_path: String) -> void:
	if not FileAccess.file_exists(video_path):
		printerr("[DialogicBridge] Archivo de video no encontrado: ", video_path)
		return

	# Ocultar la interfaz de Dialogic mientras reproduce el video
	var layout = Dialogic.Styles.get_layout_node()
	if is_instance_valid(layout):
		layout.hide()

	VideoSceneTransistor.play_specific_video(video_path)
	await VideoSceneTransistor.video_finished

	if is_instance_valid(layout):
		layout.show()
