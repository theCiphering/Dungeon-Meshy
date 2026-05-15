extends Area2D

@export var animator : AnimationPlayer 

var velocity := Vector2.ZERO
var friction := 200.0
var collected = false

func on_player_land(p,prev = Vector2.ZERO):
	if not collected:
		collected = true
		animator.play("Collect")
		if p is PlayerScript:
			p.pouch.addToPouch(1)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Collect":
		queue_free()

func _physics_process(delta):

	position += velocity * delta

	velocity = velocity.move_toward(
		Vector2.ZERO,
		friction * delta
	)
