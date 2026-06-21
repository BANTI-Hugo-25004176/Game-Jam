extends Node2D  # ou CharacterBody2D selon ce que "Egun"/"Gun" est réellement dans ta scène

var bullet_path = preload("res://scenes/enemy_bullet/bullet.tscn")
var ammo = 30
var reloading = false
var cadence_de_tir : float = 0.75
var delai_entre_tirs : float = 1.0 / cadence_de_tir
var temps_depuis_dernier_tir : float = 0.0

@onready var timer: Timer = $Timer
@onready var marker: Marker2D = $Marker2D

## Le parent (Enemy) appelle cette fonction à chaque frame en lui passant
## la position du joueur. Elle gère à la fois la visée et le tir.
func update_aim_and_shoot(target_position: Vector2, delta: float, should_shoot: bool) -> void:
	temps_depuis_dernier_tir += delta
	_viser(target_position)

	if should_shoot and temps_depuis_dernier_tir >= delai_entre_tirs:
		fire()
		temps_depuis_dernier_tir = 0.0

## Oriente l'arme directement vers la cible (le joueur), pas de souris/stick.
func _viser(target_position: Vector2) -> void:
	look_at(target_position)
	var direction = target_position - global_position
	# Si le sprite de l'arme a besoin d'un flip vertical comme côté joueur
	if has_node("Gun"):
		$Gun.flip_v = direction.x < 0

func fire() -> void:
	if !reloading:
		var bullet = bullet_path.instantiate()
		if has_node("shootsound"):
			$shootsound.play()
		bullet.pos = marker.global_position
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
