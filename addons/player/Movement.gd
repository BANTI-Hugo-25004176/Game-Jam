extends CharacterBody2D

# --- Mouvement Normal ---
@export var max_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# --- Paramètres du Dash ---
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5

var is_dashing: bool = false
var can_dash: bool = true
var last_direction: Vector2 = Vector2.RIGHT

const PAUSE_MENU = preload("res://ui/screens/pause.tscn")

# --- NOUVEAU : Récupérer le nœud d'animation ---
# Assure-toi que ton nœud s'appelle bien "AnimatedSprite2D" (respecte les majuscules)
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir != Vector2.ZERO:
		last_direction = input_dir.normalized()

	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

	if is_dashing:
		velocity = last_direction * dash_speed
	else:
		if input_dir != Vector2.ZERO:
			velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	
	# --- NOUVEAU : Mettre à jour l'animation à chaque frame ---
	update_animation()


func start_dash() -> void:
	is_dashing = true
	can_dash = false
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true


# --- NOUVEAU : La logique d'animation ---
func update_animation() -> void:
	# 1. Orienter le sprite dans la bonne direction (gauche ou droite)
	# On regarde si la vitesse va vers la gauche (< 0) ou la droite (> 0)
	if velocity.x != 0:
		anim.flip_h = velocity.x < 0
		
	# 2. Choisir l'animation à jouer selon l'action en cours
	if is_dashing:
		# Si tu n'as pas d'animation "dash", tu peux mettre "run" ici
		anim.play("walk") 
	elif velocity.length() > 0:
		# velocity.length() > 0 signifie que le personnage bouge (peu importe la direction)
		anim.play("walk")
<<<<<<< HEAD

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
			
			# 1. On fige complètement le jeu
		get_tree().paused = true
		
		# 2. On crée le menu et on l'affiche par-dessus le niveau
		var pause_instance = PAUSE_MENU.instantiate()
		add_child(pause_instance)
=======
>>>>>>> f7f087c (feat(Actor): better movements and dash)
