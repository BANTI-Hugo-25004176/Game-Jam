extends CharacterBody2D

enum State { IDLE, CHASE }
var current_state : State = State.IDLE

@export var speed : float = 75.0
@export var attack_damage : int = 10 
@export var max_health : int = 30

var atk_cool = 1.0
var atk_timer = 1.0

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
				var dist_x = abs(global_position.x - player_ref.global_position.x)
				var dist_y = abs(global_position.y - player_ref.global_position.y)
				
				# Tes seuils cibles (la distance idéale)
				var seuil_x = 20.0
				var seuil_y = 30.0
				
				# La marge de tolérance pour éviter qu'il vibre au moindre pixel
				var marge = 2.0 
				
				var direction = (player_ref.global_position - global_position).normalized()
				
				# CAS 1 : Il est VRAIMENT trop près (en dessous du seuil moins la marge) -> Il recule
				if dist_x < (seuil_x - marge) and dist_y < (seuil_y - marge):
					velocity = -direction * speed
					atk_timer -= delta
					if atk_timer <= 0:
						player_ref.take_damage(attack_damage)
						atk_timer = atk_cool
					
				# CAS 2 : Il est un peu trop loin (au-dessus du seuil) -> Il avance
				elif dist_x > seuil_x or dist_y > seuil_y:
					velocity = direction * speed
					
				# CAS 3 : Il est pile dans la zone de confort (entre la marge et le seuil) -> Il s'arrête
				else:
					velocity = Vector2.ZERO
					atk_timer -= delta
					if atk_timer <= 0:
						player_ref.take_damage(attack_damage)
						atk_timer = atk_cool
					
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Actor":
		player_ref = body
		current_state = State.CHASE

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		current_state = State.IDLE

func take_damage(amount: int) -> void:
	current_health -= amount
	print("L'ennemi a pris ", amount, " dégâts ! Santé restante : ", current_health)
	
	if current_health <= 0:
		print("L'ennemi est détruit !")
		Stats.add_kill()
		queue_free()
