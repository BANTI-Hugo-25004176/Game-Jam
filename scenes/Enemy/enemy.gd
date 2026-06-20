extends CharacterBody2D

enum State { IDLE, CHASE }
var current_state : State = State.IDLE

@export var speed : float = 100.0
@export var attack_damage : int = 10 
@export var max_health : int = 30

var current_health : int
var player_ref = null

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			
		State.CHASE:
			if player_ref:
				var distance = global_position.distance_to(player_ref.global_position)
				
				if distance > 40.0: 
					var direction = (player_ref.global_position - global_position).normalized()
					velocity = direction * speed
				else:
					velocity = Vector2.ZERO
					
	move_and_slide()

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
