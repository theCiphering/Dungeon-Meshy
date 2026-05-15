extends Node 
class_name PlayerManager

static var Manager : PlayerManager
static var MAXPLAYERS : int = 1
static var NumberOfJoinedPlayers : int = 0

static var players: Array[PlayerSlot]

@export var playerCamera : Resource
@export var playerCharacter : Resource

###
# Player Slot Class
###

class PlayerSlot:
	var device_id: int = -1
	var type: String = ""
	var assigned := false
	
	var playerCharacter : PlayerScript
	
	var action_map := {
		"move_up": [],
		"move_down": [],
		"move_left": [],
		"move_right": [],
		"jump": []
	}


############
func _ready() -> void:
	Manager = self

static func clearPlayers() -> void:
	players.clear()
