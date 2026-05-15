extends Area2D

@export var sprite_animator : AnimatedSprite2D

func on_player_land(p : CharacterBody2D, prev: Vector2):
	if p is PlayerScript:
		if not p.trap_immune:
			p.trapped = true
			p.global_position = global_position + Vector2(0,0.5)
			if sprite_animator.frame == 0:
				sprite_animator.play("default")
			p.animator.play("Fall")
			p.collidor.disabled = true
			p.awaitRespawn()
			p.pouch.throwOutCoints(p.pouch.coins/2,global_position,prev)
