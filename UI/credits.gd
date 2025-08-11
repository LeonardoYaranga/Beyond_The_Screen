extends Control

signal return_to_menu

@onready var rich_text_label: RichTextLabel = $Background/Margin/Text
@onready var back_button: TextureButton = $BackButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var auto_scroll_speed: float = 50.0  # Píxeles por segundo para desplazamiento automático
@export var manual_scroll_speed: float = 30.0  # Píxeles por evento de rueda
var is_auto_scrolling: bool = true  # Controla si el desplazamiento automático está activo

func _ready() -> void:
	# Configurar RichTextLabel
	rich_text_label.scroll_active = true
	rich_text_label.mouse_filter = MOUSE_FILTER_PASS  # Permitir eventos de ratón
	rich_text_label.focus_mode = FOCUS_ALL  # Permitir foco para teclas
	rich_text_label.bbcode_enabled = true  # Asegurar que BBCode esté habilitado
	
	# Asegurarse de que el texto sea desplazable
	var v_scroll_bar = rich_text_label.get_v_scroll_bar()
	print("Credits.gd: Inicializado, scroll max:", v_scroll_bar.max_value)

func _process(delta: float) -> void:
	if is_auto_scrolling:
		# Desplazamiento automático
		var v_scroll_bar = rich_text_label.get_v_scroll_bar()
		v_scroll_bar.value += auto_scroll_speed * delta
		# Detener al llegar al final
		if v_scroll_bar.value >= v_scroll_bar.max_value:
			is_auto_scrolling = false
			print("Credits.gd: Desplazamiento automático detenido (fin alcanzado)")

func _input(event: InputEvent) -> void:
	var v_scroll_bar = rich_text_label.get_v_scroll_bar()
	# Desplazamiento manual con rueda del ratón
	if event is InputEventMouseButton and rich_text_label.get_global_rect().has_point(event.global_position):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			v_scroll_bar.value -= manual_scroll_speed
			is_auto_scrolling = false  # Desactivar auto-scroll al interactuar
			print("Credits.gd: Desplazamiento manual hacia arriba")
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			v_scroll_bar.value += manual_scroll_speed
			is_auto_scrolling = false
			print("Credits.gd: Desplazamiento manual hacia abajo")
	
	# Desplazamiento con teclas
	if rich_text_label.has_focus():
		if event.is_action_pressed("ui_up"):
			v_scroll_bar.value -= manual_scroll_speed
			is_auto_scrolling = false
			print("Credits.gd: Desplazamiento manual con tecla arriba")
		elif event.is_action_pressed("ui_down"):
			v_scroll_bar.value += manual_scroll_speed
			is_auto_scrolling = false
			print("Credits.gd: Desplazamiento manual con tecla abajo")

func _on_back_button_pressed() -> void:
	print("Credits.gd: Botón Back presionado")
	if audio_stream_player:
		audio_stream_player.stop()
		print("Credits.gd: Música de créditos detenida")
	return_to_menu.emit()

func show_credits() -> void:
	show()
	rich_text_label.get_v_scroll_bar().value = 0  # Reiniciar desplazamiento
	is_auto_scrolling = true
	if audio_stream_player and audio_stream_player.stream:
		audio_stream_player.play()
	back_button.grab_focus()
	print("Credits.gd: Mostrando créditos")

func hide_menu() -> void:
	if audio_stream_player and audio_stream_player.stream:
		audio_stream_player.stop()
	hide()
