extends Node

@export var animator : AnimationPlayer

func _on_start_game_pressed() -> void:
	animator.play("showPlayMenu")


func _on_exit_game_pressed() -> void:
	get_tree().quit(0)


func _on_back_game_pressed() -> void:
	animator.play_backwards("showPlayMenu")


func _on_host_game_pressed() -> void:
	LevelManager.Manager.loadNewScene(LevelManager.Manager.canal_dungeon)

func _on_host_back_button_pressed() -> void:
	animator.play_backwards("showHostMenu")


func _on_join_game_pressed() -> void:
	pass
