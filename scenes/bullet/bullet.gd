extends CharacterBody2D

@export var damage : int = 10
const SPEED = 1000.0

var pos: Vector2
var rota: float
var dir: float

func _ready() -> void:
	global_position = pos
	global_rotation = rota
	velocity = Vector2(SPEED, 0).rotated(dir)

func _physics_process(delta: float) -> void:
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var collider = collision.get_collider()
		
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
			
		queue_free()
