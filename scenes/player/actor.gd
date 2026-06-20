extends CharacterBody2D

# --- STATISTIQUES ---
@export var max_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

@export var max_health: int = 100
var current_health: int

@export var dash_speed: float = 450.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5
@export var rotate_flag: bool = true
@export_enum("right", "dash_right", "left") var etat_initial: String = "right"

@onready var anim: AnimatedSprite2D = $BodyRotate/AnimatedSprite2D

const PAUSE_MENU = preload("res://ui/screens/pause.tscn")

var is_dashing: bool = false
var can_dash: bool = true
var last_direction: Vector2 = Vector2.RIGHT
var can_move = true

func _physics_process(delta: float) -> void:
	if can_move:
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

		if input_dir != Vector2.ZERO:
			last_direction = input_dir.normalized()

		if is_dashing:
			velocity = last_direction * dash_speed
		else:
			if input_dir != Vector2.ZERO:
				velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

		move_and_slide()
		update_animation()

func _ready() -> void:
	current_health = max_health
func take_damage(amount: int) -> void:
	current_health -= amount
	print("Le joueur a pris ", amount, " dégâts ! Santé restante : ", current_health)
	
	if current_health <= 0:
		die()
func die() -> void:
	print("Game Over : Le joueur est mort !")
	queue_free()
func start_dash() -> void:
	is_dashing = true
	can_dash = false
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			anim.play("dash_right")
			anim.flip_h = false
		else:
			anim.play("dash_left")
	else:
		if velocity.y > 0:
			anim.play("dash_down")
		else:
			anim.play("dash_up")
	
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func update_animation() -> void:
	if not is_dashing:
		if velocity.length() > 0:
			if Input.is_action_just_pressed("dash") and can_dash:
				start_dash()
				return
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x > 0:
					anim.play("right")
					anim.flip_h = false
				else:
					anim.play("left") 
			else:
				if velocity.y > 0:
					anim.play("down")
				else:
					anim.play("up")
		else:
			anim.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		
		var pause_instance = PAUSE_MENU.instantiate()
		add_child(pause_instance)
		
