extends Area2D
class_name DoorScript

@export var destinationDoor : DoorScript
var destination : Vector2
@export var sprite_animator : AnimatedSprite2D
@export var exit : Marker2D
var usingPlayer : PlayerScript
var isBusy = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	destination = destinationDoor.exit.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_player_move(p):
	if not isBusy:
		if p is PlayerScript:
			isBusy = true
			usingPlayer = p
			p.trapped = true
			p.animator.play("Door_Enter")
			destinationDoor.sprite_animator.play("default_fake")
			destinationDoor.isBusy = true
			sprite_animator.play("default")


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite_animator.animation == "default":
		if sprite_animator.frame == 4:
			usingPlayer.global_position = destination
			usingPlayer.animator.play("Door_Leave")
			usingPlayer.facing = Vector2.DOWN
			usingPlayer.move_queue.clear()
			usingPlayer.moving = false
			sprite_animator.play_backwards("default")
		if sprite_animator.frame == 0:
			isBusy = false
	if sprite_animator.animation == "default_fake":
		if sprite_animator.frame == 4:
			sprite_animator.play_backwards("default_fake")
		if sprite_animator.frame == 0:
			isBusy = false
