extends Node
class_name LevelManager

@export var intro_scene : Resource
@export var main_menu : Resource
@export var canal_dungeon : Resource

static var CurrentScene : Node
static var Manager : LevelManager

func loadNewScene(scene : Resource):
	if CurrentScene:
		CurrentScene.queue_free()
	var newSceneInstance = scene.instantiate()
	CurrentScene = newSceneInstance
	get_tree().current_scene.add_child(newSceneInstance)

func _ready() -> void:
	Manager = self
