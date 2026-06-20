extends CharacterBody2D

var bullet_path = preload("res://scenes/bullet/bullet.tscn")

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("shoot"):
		fire()
	
	look_at(get_global_mouse_position())

func fire():
	var bullet = bullet_path.instantiate()
	
	bullet.pos = $Marker2D.global_position
	bullet.rota = global_rotation
	bullet.dir = global_rotation
	
	get_tree().current_scene.add_child(bullet)
