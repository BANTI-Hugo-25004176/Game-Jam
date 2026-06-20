extends CharacterBody2D

const SPEED = 1000.0
var pos: Vector2
var rota: float
var dir: float

func _ready():
	global_position = pos
	global_rotation = rota
	
	velocity = Vector2(SPEED, 0).rotated(dir)

func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		queue_free()
