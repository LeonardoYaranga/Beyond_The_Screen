extends CanvasLayer
#signal video_finished #si se necesita enviar una senial de terminacion del video para restabler un estado
@onready var video_player: VideoStreamPlayer = $VideoPlayerNode
@onready var transition_rect: ColorRect = $TransitionRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if video_player:
		video_player.finished.connect(_on_video_finished)
		print("VideoSceneTransistor: VideoStreamPlayer encontrado:", video_player.name)
	hide()  # Ocultar por defecto
	
func play_specific_video(video_path: String) -> void:
	if not FileAccess.file_exists(video_path):
		printerr("VideoPlayer: No se encontró el video en", video_path)
		return
	var video_stream = load(video_path) as VideoStream
	if video_stream:
		if not video_player:
			printerr("VideoPlayer: video_player es null, no se puede asignar el stream")
			return
		# Reiniciar el estado del VideoStreamPlayer
		video_player.stop()
		video_player.stream = null
		video_player.stream = video_stream
		if transition_rect and animation_player:
			animation_player.play("FadeIn")
			await animation_player.animation_finished
		video_player.play()
		show()
		print("VideoPlayer: Reproduciendo video", video_path)
	else:
		printerr("VideoPlayer: Error al cargar el video", video_path)

func _on_video_finished() -> void:
	video_player.stop()
	video_player.stream = null
	if transition_rect and animation_player:
		animation_player.play("FadeOut")
		await animation_player.animation_finished
	hide()
	print("VideoPlayer: Video terminado")
	
func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		video_player.stop()
		_on_video_finished()
