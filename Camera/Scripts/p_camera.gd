extends Camera2D

@export var target: CharacterBody2D

@export var follow_speed := 6.0
@export var look_ahead_distance := 24.0
@export var look_ahead_smooth := 8.0

var current_offset := Vector2.ZERO

func _process(delta):

	if target == null:
		return

	# Player movement direction
	var move_dir := Vector2.ZERO

	# Uses velocity if available
	if target.velocity.length() > 0.1:
		move_dir = target.velocity.normalized()

	# fallback for your custom movement system
	elif "facing" in target and target.moving:
		move_dir = target.facing.normalized()

	# Desired camera look-ahead
	var desired_offset = move_dir * look_ahead_distance

	# Smooth offset movement
	current_offset = current_offset.lerp(
		desired_offset,
		look_ahead_smooth * delta
	)

	# Final camera position
	var desired_position = target.global_position + current_offset

	global_position = global_position.lerp(
		desired_position,
		follow_speed * delta
	)
	
func setTarget(p):
	target = p
