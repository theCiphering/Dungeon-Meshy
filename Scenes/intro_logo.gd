extends Node

var skipped = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if !skipped:
		await get_tree().create_timer(1).timeout
		LevelManager.Manager.loadNewScene(LevelManager.Manager.main_menu)
		queue_free()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		var device = {"id": -1, "type": "keyboard"}
		var p : PlayerManager.PlayerSlot = InputManager.manager._force_assign_device(device)
		skipped = true
		LevelManager.Manager.loadNewScene(LevelManager.Manager.canal_dungeon)
		var player = PlayerManager.Manager.playerCharacter.instantiate()
		player.global_position = Vector2(0,-8)
		LevelManager.CurrentScene.add_child(player)
		var camera = PlayerManager.Manager.playerCamera.instantiate()
		LevelManager.CurrentScene.add_child(camera)
		camera.setTarget(player)
		p.playerCharacter = player
		queue_free()
