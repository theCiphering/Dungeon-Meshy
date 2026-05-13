extends Area2D

func on_player_land(p : CharacterBody2D):
	p.trapped = true
