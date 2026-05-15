extends Node
class_name InputManager

var isSettingRemotes = false
static var manager: InputManager
signal device_assigned(player_index: int,event : InputEvent)

# ----------------------------
# DEFAULT MAPPING
# ----------------------------

func _create_default_map(device_id: int, is_keyboard: bool) -> Dictionary:
	var map = {}

	# ----------------------------
	# MOVEMENT
	# ----------------------------
	if is_keyboard:
		map["move_up"] = [InputBind.new().set_key(KEY_W)]
		map["move_down"] = [InputBind.new().set_key(KEY_S)]
		map["move_left"] = [InputBind.new().set_key(KEY_A)]
		map["move_right"] = [InputBind.new().set_key(KEY_D)]
	else:
		map["move_up"] = [InputBind.new().set_axis_negative(JOY_AXIS_LEFT_Y, device_id)]
		map["move_down"] = [InputBind.new().set_axis_positive(JOY_AXIS_LEFT_Y, device_id)]
		map["move_left"] = [InputBind.new().set_axis_negative(JOY_AXIS_LEFT_X, device_id)]
		map["move_right"] = [InputBind.new().set_axis_positive(JOY_AXIS_LEFT_X, device_id)]

	# ----------------------------
	# ACTIONS
	# ----------------------------
	if is_keyboard:
		map["jump"] = [InputBind.new().set_key(KEY_SPACE)]
	else:
		map["jump"] = [InputBind.new().set_button(JOY_BUTTON_A, device_id)]

	return map

# ----------------------------
# READY
# ----------------------------

func _ready():
	PlayerManager.players.clear()
	manager = self
	for i in range(PlayerManager.MAXPLAYERS):
		var p = PlayerManager.PlayerSlot.new()
		p.assigned = false
		p.device_id = -99 # or any invalid default
		p.type = ""
		p.action_map = {} # empty until assigned
		
		PlayerManager.players.append(p)
		
func _physics_process(_delta):
	update()

func update():
	for player in PlayerManager.players:
		if not player.assigned:
			continue
			
		for action in player.action_map.values():
			for bind in action:
				bind.update()

# ----------------------------
# DEVICE ASSIGNMENT
# ----------------------------

func _input(event):
	var device = null

	if event is InputEventKey:
		device = {"id": -1, "type": "keyboard"}

	elif event is InputEventJoypadButton:
		device = {"id": event.device, "type": "controller"}

	if device == null:
		return

	_try_assign_device(device,event)


func _try_assign_device(device,event):
	if PlayerManager.players.all(func(p): return p.assigned):
		device_assigned.emit(-1,event)
		return
	elif not isSettingRemotes:
		device_assigned.emit(-10,event)
		return
	
	# prevent duplicates
	for p in PlayerManager.players:
		if p.assigned and p.device_id == device.id and p.type == device.type:
			return

	for i in range(PlayerManager.players.size()):
		var p = PlayerManager.players[i]

		if not p.assigned:
			p.device_id = device.id
			p.type = device.type
			p.assigned = true

			var is_keyboard = device.type == "keyboard"
			p.action_map = _create_default_map(device.id, is_keyboard)

			device_assigned.emit(i, event)
			return

func _force_assign_device(device) -> PlayerManager.PlayerSlot:
	# prevent duplicates
	for p in PlayerManager.players:
		if p.assigned and p.device_id == device.id and p.type == device.type:
			return null

	for i in range(PlayerManager.players.size()):
		var p = PlayerManager.players[i]

		if not p.assigned:
			p.device_id = device.id
			p.type = device.type
			p.assigned = true

			var is_keyboard = device.type == "keyboard"
			p.action_map = _create_default_map(device.id, is_keyboard)
			
			return p
	return null
# ----------------------------
# ACTION CHECKING
# ----------------------------

func is_action_pressed(player_index: int, action: String) -> bool:
	var p = PlayerManager.players[player_index]
	if not p.assigned or not p.action_map.has(action):
		return false

	for bind in p.action_map[action]:
		if bind.is_pressed():
			return true

	return false


func is_action_just_pressed(player_index: int, action: String) -> bool:
	if PlayerManager.players.is_empty():
		return false
		
	var p = PlayerManager.players[player_index]
	if not p.assigned or not p.action_map.has(action):
		return false

	for bind in p.action_map[action]:
		if bind.is_just_pressed():
			return true

	return false


func is_action_just_released(player_index: int, action: String) -> bool:
	if PlayerManager.players.is_empty():
		return false
		
	var p = PlayerManager.players[player_index]
	if not p.assigned or not p.action_map.has(action):
		return false

	for bind in p.action_map[action]:
		if bind.is_just_released():
			return true

	return false
	
func get_axis(player_index: int, negative_action: String, positive_action: String) -> float:
	if PlayerManager.players.is_empty():
		return false

	var neg = is_action_pressed(player_index, negative_action)
	var pos = is_action_pressed(player_index, positive_action)

	return float(pos) - float(neg)
	
