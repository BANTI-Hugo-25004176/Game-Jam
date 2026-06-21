extends CharacterBody2D
enum State { IDLE, CHASE, SHOOT }

@export var speed : float = 100.0
@export var attack_damage : int = 10
@export var max_health : int = 30
@export var portee_tir : float = 150.0 # distance à partir de laquelle il tire au lieu de courir

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

		State.CHASE:
			if player_ref:
				var distance = global_position.distance_to(player_ref.global_position)

				if distance > portee_tir:
					var direction = (player_ref.global_position - global_position).normalized()
					velocity = direction * speed
				else:
					velocity = Vector2.ZERO
					current_state = State.SHOOT

		State.SHOOT:
			velocity = Vector2.ZERO
			if player_ref:
				var distance = global_position.distance_to(player_ref.global_position)

				if distance > portee_tir:
					current_state = State.CHASE
				else:
					var should_shoot = distance <= portee_tir
					gun.update_aim_and_shoot(player_ref.global_position, delta, should_shoot)

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
