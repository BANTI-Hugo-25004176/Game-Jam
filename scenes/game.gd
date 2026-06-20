extends Node2D

@onready var animation_player = $Actor/AnimationPlayer
@onready var player = $Actor
@onready var anim: AnimatedSprite2D = $Actor/BodyRotate/AnimatedSprite2D

func _ready():
	jouer_cinematique()
	
func _process(delta: float) -> void:
	if animation_player.is_playing():
		var nom_anim = player.etat_initial
		if anim.animation != nom_anim:
			anim.play(nom_anim)
		
func jouer_cinematique():
	animation_player.play("intro")
	player.can_move = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	player.can_move = true
	animation_player.clear_queue()
