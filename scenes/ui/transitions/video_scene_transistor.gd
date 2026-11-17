extends CanvasLayer

signal video_finished

@onready var video_player: VideoStreamPlayer = $VideoPlayerNode
@onready var transition_rect: ColorRect = $TransitionRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _is_playing: bool = false

func _ready() -> void:
	if video_player:
		video_player.finished.connect(_on_video_finished)
		print("VideoSceneTransistor: VideoStreamPlayer encontrado:", video_player.name)
	hide()  # Ocultar por defecto
	
func play_specific_video(video_path: String) -> void:
	if not FileAccess.file_exists(video_path):
		printerr("VideoPlayer: No se encontró el video en", video_path)
		video_finished.emit()
		return
	var video_stream = load(video_path) as VideoStream
	if not video_stream:
		printerr("VideoPlayer: Error al cargar el video", video_path)
		video_finished.emit()
		return
	if not video_player:
		printerr("VideoPlayer: video_player es null, no se puede asignar el stream")
		video_finished.emit()
		return

	_is_playing = true
	# Reiniciar el estado del VideoStreamPlayer
	video_player.stop()
	video_player.stream = video_stream
	show()
	if transition_rect and animation_player and animation_player.has_animation("FadeIn"):
		animation_player.play("FadeIn")
		await animation_player.animation_finished
	video_player.play()
	print("VideoPlayer: Reproduciendo video", video_path)

func _on_video_finished() -> void:
	if not _is_playing:
		return
	_is_playing = false
	if video_player:
		video_player.stop()
		video_player.stream = null
	if transition_rect and animation_player and animation_player.has_animation("FadeOut"):
		animation_player.play("FadeOut")
		await animation_player.animation_finished
	hide()
	print("VideoPlayer: Video terminado")
	video_finished.emit()
	
func _input(event: InputEvent) -> void:
	if _is_playing and visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_video_finished()

