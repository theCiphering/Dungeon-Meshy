extends Node2D
class_name PlayerPouch

@export_category("Player Score")
@export var coins : int = 0
@export var coin_prefab : Resource

func addToPouch(n: int):
	coins += n

func throwOutCoints(value,position,prev):
	var escape_dir = (prev - position).normalized()
	var halfpouch = value
	coins -= value
	for i in range(value):
		var instance = coin_prefab.instantiate()
		LevelManager.CurrentScene.add_child(instance)
		instance.global_position = position

		var spread = Vector2(
			randf_range(-0.5, 0.5),
			randf_range(-0.5, 0.5)
		)

		var launch_dir = (escape_dir + spread).normalized()

		instance.velocity = launch_dir * randf_range(40.0, 90.0)
