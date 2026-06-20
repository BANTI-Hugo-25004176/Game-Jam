extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var player = $Actor

func _ready():
	jouer_cinematique()

func jouer_cinematique():
	player.controles_actifs = false
	player.jouer_animation("right")
	
	animation_player.play("left")
	await animation_player.animation_finished
	
	player.jouer_animation("right")
	animation_player.play("jump")
	await  animation_player.animation_finished
	
	player.jouer_animation("right")
	player.controles_actifs = true
