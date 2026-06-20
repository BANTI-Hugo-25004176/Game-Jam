extends CharacterBody2D


var bullet_path = preload("res://scenes/bullet/bullet.tscn")
var ammo = 30
var reloading = false
var cadence_de_tir : float = 7.0
var delai_entre_tirs : float = 1.0 / cadence_de_tir # Donne 0.2 seconde
var temps_depuis_dernier_tir : float = 0.0
@onready var timer: Timer = $Timer

func _physics_process(delta: float) -> void:
	
	temps_depuis_dernier_tir += delta
	
	if Input.is_action_pressed("shoot") and temps_depuis_dernier_tir >= delai_entre_tirs:
		fire()
		temps_depuis_dernier_tir = 0.0
	
	look_at(get_global_mouse_position())
	
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()

	if direction.x < 0:
		$Gun.flip_v = true   
	else:
		$Gun.flip_v = false 

func fire():
	if !reloading:
		
		var bullet = bullet_path.instantiate()
	
		bullet.pos = $Marker2D.global_position
		bullet.rota = global_rotation
		bullet.dir = global_rotation
	
		get_tree().current_scene.add_child(bullet)
		ammo -= 1
		if ammo == 0:
			reloading = true
			timer.start()


func _on_timer_timeout() -> void:
	ammo = 30
	reloading = false
