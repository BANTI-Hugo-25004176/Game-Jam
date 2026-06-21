extends Node2D

const HUD_SCENE = preload("res://ui/hud/hud.tscn")

@onready var animation_player = $Actor/AnimationPlayer
@onready var player = $Actor
@onready var gun = $Actor/Gun
@onready var anim: AnimatedSprite2D = $Actor/BodyRotate/AnimatedSprite2D

var _hud: GameHud

func _ready():
	Stats.reset()
	_hud = HUD_SCENE.instantiate()
	add_child(_hud)
	jouer_cinematique()
	$AudioStreamPlayer2D.play()

	# Fin de démo : à la mort du boss, on ouvre le trou de sortie.
	var _boss := get_node_or_null("Boss")
	var _hole := get_node_or_null("ExitHole")
	if _boss != null and _hole != null and _boss.has_signal("died"):
		_boss.died.connect(_hole.activate)

func _process(_delta: float) -> void:
	if animation_player.is_playing():
		var nom_anim = player.etat_initial
		if anim.animation != nom_anim:
			anim.play(nom_anim)
	_maj_hud()

## Alimente le HUD avec les données live (vie joueur + munitions du gun).
func _maj_hud() -> void:
	if _hud == null:
		return
	if is_instance_valid(player):
		_hud.set_health(player.current_health, player.max_health)
	if is_instance_valid(gun):
		_hud.set_ammo(gun.ammo, gun.reloading)

func jouer_cinematique():
	animation_player.play("intro")
	player.can_move = false

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	player.can_move = true
	animation_player.clear_queue()
