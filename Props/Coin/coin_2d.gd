extends Area2D

@export var animator : AnimationPlayer 

func on_player_land(p):
	animator.play("Collect")
	if p is PlayerScript:
		p.coins += 1

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Collect":
		queue_free()
