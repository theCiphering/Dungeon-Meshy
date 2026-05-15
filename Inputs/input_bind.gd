class_name InputBind

var type: String = ""   # "key", "button", "axis_pos", "axis_neg"
var code: int = 0
var device: int = -1

var _was_pressed: bool = false
var _pressed: bool = false
var _just_pressed: bool = false
var _just_released: bool = false

# ---- builders ----
func set_key(k: int) -> InputBind:
	type = "key"
	code = k
	return self

func set_button(b: int, device_id: int) -> InputBind:
	type = "button"
	code = b
	device = device_id
	return self

func set_axis_positive(axis: int, device_id: int) -> InputBind:
	type = "axis_pos"
	code = axis
	device = device_id
	return self

func set_axis_negative(axis: int, device_id: int) -> InputBind:
	type = "axis_neg"
	code = axis
	device = device_id
	return self

func update():
	var current = _get_current_pressed()

	_just_pressed = current and not _was_pressed
	_just_released = not current and _was_pressed

	_pressed = current
	_was_pressed = current

# ---- raw state ----
func _get_current_pressed() -> bool:
	match type:
		"key":
			return Input.is_key_pressed(code)

		"button":
			return Input.is_joy_button_pressed(device, code)

		"axis_pos":
			return Input.get_joy_axis(device, code) > 0.5

		"axis_neg":
			return Input.get_joy_axis(device, code) < -0.5

	return false

# ---- public API ----
func is_pressed() -> bool:
	return _pressed

func is_just_pressed() -> bool:
	return _just_pressed

func is_just_released() -> bool:
	return _just_released
