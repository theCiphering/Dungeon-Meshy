extends CharacterBody2D

var held_dirs: Array[Vector2] = []
var moving := false
var trapped := false
const TILE_SIZE := 16
const MOVE_SPEED := 60.0 # fluid feel (NOT 8)
var target_position := Vector2.ZERO
var move_queue: Array[Vector2] = []
var facing : Vector2

func _physics_process(delta: float) -> void:
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
			check_areas_at(global_position)
			if not move_queue.is_empty():
				start_next_move()
			elif held_dirs.size() > 0 and not isBusy():
				var dir = held_dirs[-1]
				facing = dir
				rotation = facing.angle()
				try_move(dir)
		return
	# Start movement
	if held_dirs.size() > 0 and not isBusy():
		var dir = held_dirs[-1]
		facing = dir
		rotation = facing.angle()
		try_move(dir)
	

func update_input():
	handle("Move_Right", Vector2.RIGHT)
	handle("Move_Left", Vector2.LEFT)
	handle("Move_Down", Vector2.DOWN)
	handle("Move_Up", Vector2.UP)


func handle(action: String, dir: Vector2):
	if Input.is_action_just_pressed(action):
		held_dirs.erase(dir)
		held_dirs.append(dir)

	if Input.is_action_just_released(action):
		held_dirs.erase(dir) 

func can_continue_movement() -> bool:
	return not trapped

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
		if can_move_to(next):
			move_queue.append(next)
			current = next
		else:
			break
	start_next_move()

func start_next_move():
	if move_queue.is_empty():
		return
	target_position = move_queue.pop_front()
	moving = true

func start_move(pos: Vector2):
	target_position = pos
	moving = true
	
func check_areas_at(pos: Vector2):
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
		if area.has_method("on_vehicle_land"):
			area.on_player_land(self)	
	
var debug_query_pos := Vector2.ZERO
var debug_radius := 32.0
	
func can_move_to(pos: Vector2) -> bool:

	var space = get_world_2d().direct_space_state

	# BODY CHECK
	var ray = PhysicsRayQueryParameters2D.create(
		global_position,
		pos
	)

	ray.collide_with_bodies = true
	ray.collide_with_areas = false
	ray.collision_mask = 1 << 8
	var wall_hit = space.intersect_ray(ray)

	if not wall_hit.is_empty():
		

		var shape = CircleShape2D.new()
		shape.radius = 6

		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, pos)
		debug_query_pos = pos
		debug_radius = 6
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.collision_mask = 1 << 8

		var results = space.intersect_shape(query)
		queue_redraw()
		for r in results:

			var area = r.collider

			print(area.name)

			if area.has_method("on_player_move"):
				area.on_player_move(self)
				return false
		return false
	return true

func isBusy() -> bool:
	if trapped:
		return true
	return false

func _draw():
	draw_circle(to_local(debug_query_pos), debug_radius, Color.RED)
