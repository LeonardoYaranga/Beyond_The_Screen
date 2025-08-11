extends Node

# Variables globales
var death_counter: int = 0
var visited_rooms: Dictionary = {}  # Rastrear salas visitadas string -> bool
var last_room_visited: String = ""

# TavernMaid spicy food mission to obtain a clue of WarHammer with Blacksmith
var has_spicy_food: bool = false  # Indica si el jugador tiene comida picante
var unlocked_warhammer: bool = false  # Indica si el WarHammer está desbloqueado, con eso el Blacksmith te da esa opción de diálogo
var completed_spicy_food_quest: bool = false  # Indica si la misión de la comida picante está completada
var asked_about_warhammer: bool = false  # Indica si ya preguntaste por el WarHammer al herrero

# TavernMaid town interaction
var helped_ellen_in_town: bool = false  # Indica si ayudaste a Ellen en el pueblo
var talked_to_ellen_in_town: bool = false  # Indica si ya interactuaste con Ellen en el pueblo

const SAVE_PATH: String = "user://game_save.json"

func _ready() -> void:
	load_game()
	print("GameManager: Inicializado, death_counter:", death_counter, "visited_rooms:", visited_rooms, "last_room_visited:", last_room_visited, "has_spicy_food:", has_spicy_food, "unlocked_warhammer:", unlocked_warhammer, "completed_spicy_food_quest:", completed_spicy_food_quest, "helped_ellen_in_town:", helped_ellen_in_town, "talked_to_ellen_in_town:", talked_to_ellen_in_town, "asked_about_warhammer:", asked_about_warhammer)

func increment_death_counter() -> void:
	death_counter += 1
	save_game()
	print("GameManager: Jugador murió, death_counter:", death_counter)

func update_last_room(room_name: String) -> void:
	if room_name:
		last_room_visited = room_name
		save_game()

func add_visited_room(room_name: String) -> void:
	if not visited_rooms.has(room_name):
		visited_rooms[room_name] = true
		save_game()
		print("GameManager: Sala visitada añadida:", room_name, "visited_rooms:", visited_rooms)

func has_visited_room(room_name: String) -> bool:
	return visited_rooms.has(room_name) and visited_rooms[room_name]

func set_has_spicy_food(value: bool) -> void:
	has_spicy_food = value
	save_game()
	print("GameManager: has_spicy_food actualizado:", has_spicy_food)

func set_unlocked_warhammer(value: bool) -> void:
	unlocked_warhammer = value
	save_game()
	print("GameManager: unlocked_warhammer actualizado:", unlocked_warhammer)

func set_completed_spicy_food_quest(value: bool) -> void:
	completed_spicy_food_quest = value
	save_game()
	print("GameManager: completed_spicy_food_quest actualizado:", completed_spicy_food_quest)

func set_helped_ellen_in_town(value: bool) -> void:
	helped_ellen_in_town = value
	save_game()
	print("GameManager: helped_ellen_in_town actualizado:", helped_ellen_in_town)

func set_talked_to_ellen_in_town(value: bool) -> void:
	talked_to_ellen_in_town = value
	save_game()
	print("GameManager: talked_to_ellen_in_town actualizado:", talked_to_ellen_in_town)

func set_asked_about_warhammer(value: bool) -> void:
	asked_about_warhammer = value
	save_game()
	print("GameManager: asked_about_warhammer actualizado:", asked_about_warhammer)

func save_game() -> void:
	var save_data = {
		"death_counter": death_counter,
		"visited_rooms": visited_rooms,
		"last_room_visited": last_room_visited,
		"has_spicy_food": has_spicy_food,
		"unlocked_warhammer": unlocked_warhammer,
		"completed_spicy_food_quest": completed_spicy_food_quest,
		"helped_ellen_in_town": helped_ellen_in_town,
		"talked_to_ellen_in_town": talked_to_ellen_in_town,
		"asked_about_warhammer": asked_about_warhammer
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("GameManager: Juego guardado")
	else:
		printerr("GameManager: Error al guardar el juego")

func load_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			file.close()
			if text.is_empty():
				print("GameManager: Archivo de guardado vacío, inicializando valores")
				reset_game()
			else:
				var json = JSON.parse_string(text)
				if json and json is Dictionary:
					death_counter = json.get("death_counter", 0)
					visited_rooms = json.get("visited_rooms", {})
					last_room_visited = json.get("last_room_visited", "")
					has_spicy_food = json.get("has_spicy_food", false)
					unlocked_warhammer = json.get("unlocked_warhammer", false)
					completed_spicy_food_quest = json.get("completed_spicy_food_quest", false)
					helped_ellen_in_town = json.get("helped_ellen_in_town", false)
					talked_to_ellen_in_town = json.get("talked_to_ellen_in_town", false)
					asked_about_warhammer = json.get("asked_about_warhammer", false)
					print("GameManager: Juego cargado, death_counter:", death_counter, "visited_rooms:", visited_rooms, "last_room_visited:", last_room_visited, "has_spicy_food:", has_spicy_food, "unlocked_warhammer:", unlocked_warhammer, "completed_spicy_food_quest:", completed_spicy_food_quest, "helped_ellen_in_town:", helped_ellen_in_town, "talked_to_ellen_in_town:", talked_to_ellen_in_town, "asked_about_warhammer:", asked_about_warhammer)
				else:
					printerr("GameManager: Formato JSON inválido en", SAVE_PATH)
					reset_game()
		else:
			printerr("GameManager: Error al abrir el archivo de guardado")
			reset_game()
	else:
		reset_game()
		print("GameManager: No se encontró archivo de guardado, inicializando valores")

func reset_game() -> void:
	death_counter = 0
	visited_rooms = {}
	last_room_visited = ""
	has_spicy_food = false
	unlocked_warhammer = false
	completed_spicy_food_quest = false
	helped_ellen_in_town = false
	talked_to_ellen_in_town = false
	asked_about_warhammer = false
	save_game()
