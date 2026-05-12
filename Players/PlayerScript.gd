extends CharacterBody2D
class_name PlayerScript

const TILE_SIZE := 16
const MOVE_SPEED := 120.0 # fluid feel (NOT 8)

var moving := false
var target_position := Vector2.ZERO

@export var testing = false

var facing : Vector2
var held_dirs: Array[Vector2] = []

var busyActions: Array[String] = ["Swing_Down","Swing_Up","Swing_Right","Swing_Left"]

@export_category("Component Inports")
@export var animator : AnimatedSprite2D

func _ready():
	target_position = global_position


func _physics_process(delta):

	if not testing:
		update_input()
	
	# FLUID MOVEMENT TOWARD TARGET TILE
	if moving:
		global_position = global_position.move_toward(
			target_position,
			MOVE_SPEED * delta
		)

		if global_position.distance_to(target_position) < 0.5:
			global_position = target_position
			moving = false

		return

	# PICK NEXT TILE (LAST INPUT WINS)
	if held_dirs.size() > 0 and not isBusy():
		var dir = held_dirs[-1]
		facing = dir
		set_input_animation(dir)

		var next_pos = target_position + dir * TILE_SIZE

		# collision check using real physics query
		var space = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(target_position, next_pos)

		var hit = space.intersect_ray(query)

		if hit.is_empty():
			target_position = next_pos
			moving = true
	else:
		set_input_animation(Vector2.ZERO)

func update_input():
	if Input.is_action_just_pressed("Basic_Attack"):
		handleAttack()
		return
	handle("ui_right", Vector2.RIGHT)
	handle("ui_left", Vector2.LEFT)
	handle("ui_down", Vector2.DOWN)
	handle("ui_up", Vector2.UP)

func isBusy() -> bool:
	if busyActions.find(animator.animation) != -1:
		return true
	return false

func set_input_animation(dir):	
	if isBusy():
		return
	if dir == Vector2.ZERO:
		if facing == Vector2.DOWN:
			animator.play("Idle_Down")
		if facing == Vector2.UP:
			animator.play("Idle_Up")
		if facing == Vector2.RIGHT:
			animator.play("Idle_Right")
		if facing == Vector2.LEFT:
			animator.play("Idle_Left")
	if dir == Vector2.UP:
		animator.play("Move_Up")
	if dir == Vector2.RIGHT:
		animator.play("Move_Right")
	if dir == Vector2.LEFT:
		animator.play("Move_Left")
	if dir == Vector2.DOWN:
		animator.play("Move_Down")

func handle(action: String, dir: Vector2):
	if Input.is_action_just_pressed(action):
		held_dirs.erase(dir)
		held_dirs.append(dir)

	if Input.is_action_just_released(action):
		held_dirs.erase(dir) 	

func handleAttack():
	if facing == Vector2.DOWN:
		animator.play("Swing_Down")
	if facing == Vector2.UP:
		animator.play("Swing_Up")
	if facing == Vector2.RIGHT:
		animator.play("Swing_Right")
	if facing == Vector2.LEFT:
		animator.play("Swing_Left")

func attack():
	var attack_pos = global_position + facing * TILE_SIZE

	var shape = RectangleShape2D.new()
	shape.extents = Vector2(4, 4) # half tile size

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, attack_pos)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.exclude = [self]
	var space = get_world_2d().direct_space_state
	var results = space.intersect_shape(query)

	for result in results:
		var body = result.collider
		print("Hit: ", body.name)

		# optional
		if body.has_method("get_hit"):
			body.get_hit(1)


func _on_knight_animated_sprite_2d_animation_finished() -> void:
	if facing == Vector2.DOWN:
		animator.play("Idle_Down")
	if facing == Vector2.UP:
		animator.play("Idle_Up")
	if facing == Vector2.RIGHT:
		animator.play("Idle_Right")
	if facing == Vector2.LEFT:
		animator.play("Idle_Left")

func get_hit(s : float):
	pass

func _on_knight_animated_sprite_2d_frame_changed() -> void:
	if animator.animation.contains("Swing") and animator.frame == 3:
		attack()
