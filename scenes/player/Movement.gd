extends CharacterBody2D

# --- STATISTIQUES ---
@export var max_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5
@export var rotate_flag: bool = true

@onready var anim: AnimatedSprite2D = $BodyRotate/AnimatedSprite2D

const PAUSE_MENU = preload("res://ui/screens/pause.tscn")

var is_dashing: bool = false
var can_dash: bool = true
var last_direction: Vector2 = Vector2.RIGHT

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
	update_animation()

func start_dash() -> void:
	is_dashing = true
	can_dash = false
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func update_animation() -> void:
	if velocity.length() > 0:
		anim.play("walk")
		if velocity.x != 0:
			anim.flip_h = velocity.x < 0
	else:
		anim.stop() 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		
		var pause_instance = PAUSE_MENU.instantiate()
		add_child(pause_instance)
		
