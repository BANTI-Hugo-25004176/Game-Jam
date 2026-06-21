extends CharacterBody2D


var bullet_path = preload("res://scenes/bullet/bullet.tscn")
var ammo = 30
var reloading = false
var cadence_de_tir : float = 7.0
var delai_entre_tirs : float = 1.0 / cadence_de_tir # Donne 0.2 seconde
var temps_depuis_dernier_tir : float = 0.0

## Zone morte du stick droit pour la visée manette.
const AIM_DEADZONE : float = 0.3

@onready var timer: Timer = $Timer

func _physics_process(delta: float) -> void:

	temps_depuis_dernier_tir += delta

	if Input.is_action_pressed("shoot") and temps_depuis_dernier_tir >= delai_entre_tirs:
		fire()
		temps_depuis_dernier_tir = 0.0

	_viser()

## Oriente l'arme : stick droit en priorité (manette), sinon la souris.
func _viser() -> void:
	var stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))

	# Sensibilité réglable depuis le menu Contrôles (sinon valeur par défaut).
	var deadzone := AIM_DEADZONE
	var cfg := get_node_or_null("/root/InputConfig")
	if cfg != null:
		deadzone = cfg.aim_deadzone

	var direction : Vector2
	if stick.length() >= deadzone:
		# Visée à la manette : on pointe dans le sens du stick droit.
		rotation = stick.angle()
		direction = stick
	else:
		# Repli souris (clavier/souris).
		look_at(get_global_mouse_position())
		direction = get_global_mouse_position() - global_position

	$Gun.flip_v = direction.x < 0

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
