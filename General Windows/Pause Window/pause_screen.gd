extends Control

class_name PauseScreen

static var Screen : PauseScreen

@export_category("Imports")
@export var animator : AnimationPlayer

static func getPauseScreenResource() -> Resource:
	return load("res://General Windows/Pause Window/pause_screen.tscn")

func _ready() -> void:
	Screen = self
	
func pauseGame():
	animator.play("showMenu")
	
func resumeGame():
	animator.play_backwards("showMenu")


func resume_button_pressed() -> void:
	resumeGame()


func _on_exit_pressed() -> void:
	get_tree().quit(0)
