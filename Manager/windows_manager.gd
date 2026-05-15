extends Node
class_name WindowsManager

# Instantiate Screens
func _ready() -> void:
	var pauseScreen = PauseScreen.getPauseScreenResource().instantiate()
	call_deferred("addScreen",pauseScreen)
	

func addScreen(res : Node):
	GameUI.mainLayer.add_child(res)


# Windows Calls Functions
func _process(_delta: float) -> void:
	return
	if Input.is_action_just_pressed("ui_cancel"):
		if PauseScreen.Screen:
			if PauseScreen.Screen.visible:
				PauseScreen.Screen.resumeGame()
			else:
				PauseScreen.Screen.pauseGame()
