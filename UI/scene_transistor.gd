extends CanvasLayer

signal transition_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	
	if animation_player:
		print("scene_transistor: Animation player exists")
	

func start_transition_to() -> void:
	animation_player.play("change_scene_to_file")
	
func change_scene_to_file() -> void:
	# No usamos get_tree().change_scene_to_file porque manejamos las salas en Rooms.gd
	emit_signal("transition_finished")
