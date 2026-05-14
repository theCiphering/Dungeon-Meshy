extends Area2D

@export var sprite_animator : AnimatedSprite2D

func on_player_land(p : CharacterBody2D):
	p.trapped = true
	sprite_animator.play("default")
	if p is PlayerScript:
		p.animator.play("Fall")
		p.collidor.disabled = true
