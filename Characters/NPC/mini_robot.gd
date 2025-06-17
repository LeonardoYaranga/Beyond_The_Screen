extends NPC

func _ready() -> void:
	super._ready()
	dialogue_lines = ["Ayudanos :c", "Sigue adelante"]

func start_dialogue() -> void:
	# Ejemplo: Mostrar diálogo y ofrecer mejora
	print("Mini robot dice:", dialogue_lines[0])
	# Más adelante, integrar con un sistema de diálogo y comercio
	#if interacting_player and interacting_player.has_method("upgrade_sword"):
		#if interacting_player.coins >= 10:  # Suponiendo que Player tiene "coins"
			#interacting_player.upgrade_sword()
			#interacting_player.coins -= 10
			#print("Espada mejorada!")
		#else:
			#print("No tienes suficientes monedas.")
