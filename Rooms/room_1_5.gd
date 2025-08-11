extends Room

func _open_doors() -> void:
	# Ejecutar el comportamiento original de abrir puertas
	super._open_doors()
	
	# Verificar si la sala ya fue visitada para evitar reproducir el video de nuevo
	var room_name = get_parent().current_room_name if get_parent() else name
	if not GameManager.has_visited_room(room_name):
		# Reproducir la animación del portal
		VideoSceneTransistor.play_specific_video("res://Videos/World1/portal_to_world_2.ogv")
		print("Room1_5.gd: Reproduciendo video portal_to_world_2.ogv en sala:", room_name)
	else:
		print("Room1_5.gd: Sala ya visitada, no se reproduce el video:", room_name)
