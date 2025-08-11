extends Enemy

@onready var hitbox: Hitbox = %Hitbox

func _process(_delta: float) -> void:
	if is_instance_valid(hitbox):
		#print("skeletonSeeker.gd: valid hitbox")
		hitbox.knockback_direction = velocity.normalized()
	else:
		print("skeletonSeeker.gd: Not valid hitbox")
