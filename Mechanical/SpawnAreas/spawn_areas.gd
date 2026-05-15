extends Node2D
class_name SpawnAreas

static var Spawn: SpawnAreas

@export var SpawnPoints : Array[Marker2D]

func _ready() -> void:
	Spawn = self
	for i in get_children():
		if i is Marker2D:
			SpawnPoints.append(i)

func spawnMe(p : PlayerScript):
	p.global_position = SpawnPoints.pick_random().global_position
	p.trapped = false
