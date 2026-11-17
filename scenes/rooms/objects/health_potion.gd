extends Area2D

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")

func _on_body_entered(player: Node2D) -> void:
	if not player or not player.is_in_group("player"):
		return
	print("health_potion.gd: ", typeof(player), " - ", player)
	collision_shape.set_deferred("disabled", true)
	if "hp" in player:
		player.hp += 1

	var tween: Tween = create_tween().set_parallel()
	modulate.a = 1
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", position.y - 16, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
