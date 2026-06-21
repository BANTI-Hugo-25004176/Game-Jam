extends CharacterBody2D

enum State { IDLE, CHASE, SHOOT }
@export var speed : float = 75.0
@export var attack_damage : int = 10
@export var max_health : int = 30
@export var portee_tir : float = 200.0 # Distance idéale de combat

var current_state : State = State.IDLE
var current_health : int
var player_ref : Node2D = null

var bullet_path = preload("res://scenes/bullet/bullet.tscn")
var cadence_de_tir : float = 2.0
var delai_entre_tirs : float = 1.0 / cadence_de_tir
var temps_depuis_dernier_tir : float = 0.0

@onready var marker: Marker2D = $Egun/Marker2D
@onready var gun = $Egun

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	temps_depuis_dernier_tir += delta

	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO

		State.CHASE, State.SHOOT:
			if player_ref:
				var distance = global_position.distance_to(player_ref.global_position)
				var direction = (player_ref.global_position - global_position).normalized()
				
				# Zone de confort d'un tireur (ex: entre 120 et 150 pixels)
				var marge_recul = 30.0 
				
				# CAS 1 : Le joueur est trop loin -> L'ennemi avance
				if distance > portee_tir:
					current_state = State.CHASE
					velocity = direction * speed
					# Il peut quand même tenter de tirer s'il est presque à portée
					gun.update_aim_and_shoot(player_ref.global_position, delta, false)
					
				# CAS 2 : Le joueur est trop près -> L'ennemi recule en tirant !
				elif distance < (portee_tir - marge_recul):
					current_state = State.SHOOT
					velocity = -direction * (speed * 0.8) # Recule un poil plus lentement qu'il n'avance
					gun.update_aim_and_shoot(player_ref.global_position, delta, true)
					
				# CAS 3 : Distance parfaite -> Il s'immobilise et sulfate le joueur
				else:
					current_state = State.SHOOT
					velocity = Vector2.ZERO
					gun.update_aim_and_shoot(player_ref.global_position, delta, true)
			else:
				velocity = Vector2.ZERO

	move_and_slide()

func fire() -> void:
	var bullet = bullet_path.instantiate()
	bullet.pos = marker.global_position
	bullet.rota = global_rotation
	bullet.dir = global_rotation
	get_tree().current_scene.add_child(bullet)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Actor":
		player_ref = body
		current_state = State.CHASE

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		current_state = State.IDLE

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	current_health -= amount
	print("L'ennemi a pris ", amount, " dégâts ! Santé restante : ", current_health)

	if current_health <= 0:
		print("L'ennemi est détruit !")
		Stats.add_kill()
		queue_free()
