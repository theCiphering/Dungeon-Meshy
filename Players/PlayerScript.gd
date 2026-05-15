extends CharacterBody2D
class_name PlayerScript

const TILE_SIZE := 8
const MOVE_SPEED := 60.0 # fluid feel (NOT 8)

var knockback = false
var trapped = false
var moving := false
var target_position := Vector2.ZERO
var previous_position := Vector2.ZERO

var movement_interrupt: Callable = Callable()

@export_category("Player Properties")
@export var testing = false
@export var trap_immune = false

var move_queue: Array[Vector2] = []
var facing : Vector2
var held_dirs: Array[Vector2] = []

var busyActions: Array[String] = ["Swing_Down","Swing_Up","Swing_Right","Swing_Left"]

@export_category("Component Inports")
@export var sprite_animator : AnimatedSprite2D
@export var animator : AnimationPlayer
@export var collidor : CollisionShape2D
@export var pouch : PlayerPouch

func _ready():
	target_position = global_position
	previous_position = global_position
	
func _physics_process(delta):
	if not testing:
		update_input()
	if moving:
		if not can_continue_movement():
			return
		global_position = global_position.move_toward(
			target_position,
			MOVE_SPEED * delta
		)
		if global_position.distance_to(target_position) < 0.5:
			global_position = target_position
			moving = false
			check_areas_at(global_position, previous_position)
			if not move_queue.is_empty():
				start_next_move()
			elif held_dirs.size() > 0 and not isBusy():
				var dir = held_dirs[-1]
				facing = dir
				set_input_animation(dir)
				try_move(dir)
		return
	# Start movement
	if held_dirs.size() > 0 and not isBusy():
		var dir = held_dirs[-1]
		facing = dir
		set_input_animation(dir)
		try_move(dir)
	else:
		knockback = false
		set_input_animation(Vector2.ZERO)

func update_input():
	if Input.is_action_just_pressed("Basic_Attack"):
		handleAttack()
		return
	handle("Move_Right", Vector2.RIGHT)
	handle("Move_Left", Vector2.LEFT)
	handle("Move_Down", Vector2.DOWN)
	handle("Move_Up", Vector2.UP)

func isBusy() -> bool:
	if busyActions.find(sprite_animator.animation) != -1:
		return true
	if trapped:
		return true
	return false

func set_input_animation(dir):	
	if isBusy():
		return
	if dir == Vector2.ZERO:
		if facing == Vector2.DOWN:
			sprite_animator.play("Idle_Down")
		if facing == Vector2.UP:
			sprite_animator.play("Idle_Up")
		if facing == Vector2.RIGHT:
			sprite_animator.play("Idle_Right")
		if facing == Vector2.LEFT:
			sprite_animator.play("Idle_Left")
	if dir == Vector2.UP:
		sprite_animator.play("Move_Up")
	if dir == Vector2.RIGHT:
		sprite_animator.play("Move_Right")
	if dir == Vector2.LEFT:
		sprite_animator.play("Move_Left")
	if dir == Vector2.DOWN:
		sprite_animator.play("Move_Down")

func handle(action: String, dir: Vector2):
	if Input.is_action_just_pressed(action):
		held_dirs.erase(dir)
		held_dirs.append(dir)

	if Input.is_action_just_released(action):
		held_dirs.erase(dir) 	

func handleAttack():
	if facing == Vector2.DOWN:
		sprite_animator.play("Swing_Down")
	if facing == Vector2.UP:
		sprite_animator.play("Swing_Up")
	if facing == Vector2.RIGHT:
		sprite_animator.play("Swing_Right")
	if facing == Vector2.LEFT:
		sprite_animator.play("Swing_Left")

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
			body.get_hit(2,global_position)

func try_move(dir: Vector2):
	if moving:
		return
	move_queue.clear()
	var steps = int(max(abs(dir.x), abs(dir.y)))
	if steps == 0:
		return
	var step_dir = dir.normalized().round()
	var current = global_position
	for i in range(steps):
		var next = current + step_dir * TILE_SIZE
		if movement_interrupt.is_valid() and not movement_interrupt.call():
			break
		if can_move_to(next):
			move_queue.append(next)
			current = next
		else:
			break
	start_next_move()

func start_next_move():
	if move_queue.is_empty():
		return
	previous_position = global_position
	target_position = move_queue.pop_front()
	moving = true

func start_move(pos: Vector2):
	target_position = pos
	moving = true

func can_continue_movement() -> bool:
	return not trapped

func can_move_to(pos: Vector2) -> bool:

	var space = get_world_2d().direct_space_state

	# BODY CHECK
	var ray = PhysicsRayQueryParameters2D.create(
		global_position,
		pos
	)

	ray.collide_with_bodies = true
	ray.collide_with_areas = false
	ray.collision_mask = 1
	var wall_hit = space.intersect_ray(ray)

	if not wall_hit.is_empty():
		

		var shape = CircleShape2D.new()
		shape.radius = 6

		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, pos)

		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.collision_mask = 2

		var results = space.intersect_shape(query)

		for r in results:

			var area = r.collider

			print(area.name)

			if area.has_method("on_player_move"):
				area.on_player_move(self)
				return false
		return false
	return true

func check_areas_at(pos: Vector2,prev: Vector2):
	var space = get_world_2d().direct_space_state

	var shape = CircleShape2D.new()
	shape.radius = 2

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results = space.intersect_shape(query)
	print(results)
	for r in results:
		var area = r.collider
		if area.has_method("on_player_land"):
			area.on_player_land(self, prev)

func get_hit(s : float, p : Vector2):
	var dir = (global_position - p).normalized().round() * s
	try_move(dir)

func awaitRespawn():
	await get_tree().create_timer(5).timeout
	SpawnAreas.Spawn.spawnMe(self)
	animator.play("RESET")

func _on_knight_animated_sprite_2d_animation_finished() -> void:
	if facing == Vector2.DOWN:
		sprite_animator.play("Idle_Down")
	if facing == Vector2.UP:
		sprite_animator.play("Idle_Up")
	if facing == Vector2.RIGHT:
		sprite_animator.play("Idle_Right")
	if facing == Vector2.LEFT:
		sprite_animator.play("Idle_Left")

func _on_knight_animated_sprite_2d_frame_changed() -> void:
	if sprite_animator.animation.contains("Swing") and sprite_animator.frame == 3:
		attack()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Door_Leave":
		trapped = false
