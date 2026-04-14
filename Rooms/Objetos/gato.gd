extends "res://Rooms/Objetos/objeto.gd"
@export_enum("idle", "sleep", "lick")
var start_anim: String = "idle"       # podrás elegirla en el Inspector

func _ready() -> void:
	super._ready()                         # deja que el padre haga lo suyo
	if animation_player.has_animation(start_anim):
		animation_player.play(start_anim)   # y luego cambia a la deseada
