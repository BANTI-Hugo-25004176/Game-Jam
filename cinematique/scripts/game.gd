extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var player = $Actor

func _ready():
	jouer_cinematique()

func jouer_cinematique():
	player.controles_actifs = false
	player.jouer_animation("walk")
	
	animation_player.play("intro")
	await animation_player.animation_finished
	
	player.jouer_animation("idle")
	player.controles_actifs = true
