extends Control

signal video_finished

@onready var video_player: VideoStreamPlayer = $VideoPlayerNode
@onready var transition_rect: ColorRect = $TransitionRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if video_player:
		video_player.finished.connect(_on_video_finished)
		print("VideoPlayer: VideoStreamPlayer encontrado:", video_player.name)
	else:
		printerr("VideoPlayer: Error - No se encontró VideoStreamPlayer en $VideoPlayerNode")
	hide()  # Ocultar por defecto

func play_video(video_path: String) -> void:
	if not FileAccess.file_exists(video_path):
		printerr("VideoPlayer: No se encontró el video en", video_path)
		video_finished.emit()
		return
	var video_stream = load(video_path) as VideoStream
	if video_stream:
		if not video_player:
			printerr("VideoPlayer: video_player es null, no se puede asignar el stream")
			video_finished.emit()
			return
		# Reiniciar el estado del VideoStreamPlayer
		video_player.stop()
		video_player.stream = null
		if transition_rect and animation_player:
			animation_player.play("FadeIn")
			await animation_player.animation_finished
		video_player.stream = video_stream
		video_player.play()
		show()
		print("VideoPlayer: Reproduciendo video", video_path)
	else:
		printerr("VideoPlayer: Error al cargar el video", video_path)
		video_finished.emit()

func _on_video_finished() -> void:
	if transition_rect and animation_player:
		animation_player.play("FadeOut")
		await animation_player.animation_finished
	video_player.stop()  # Asegurar que el video se detenga
	hide()
	print("VideoPlayer: Video terminado")
	video_finished.emit()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		if video_player:
			video_player.stop()
		_on_video_finished()
