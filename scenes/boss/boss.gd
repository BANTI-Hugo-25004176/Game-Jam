extends CharacterBody2D

## Boss de fin de démo — 2 phases.
##   Phase 1 (PV pleins → 50 %) : garde ses distances et tire (dégâts = ranged_damage, 20).
##   Phase 2 (< 50 % PV)        : fonce au corps-à-corps (dégâts = melee_damage, 40).
## À sa mort, émet `died` → la scène ouvre le trou de sortie (fin de démo).
##
## Réglages exposés dans l'inspecteur (PV, vitesse, dégâts, AoE optionnelle).

signal died

@export var max_health: int = 1000
@export var speed: float = 90.0
@export var ranged_damage: int = 20
@export var melee_damage: int = 40
## Fraction de PV sous laquelle le boss passe en phase corps-à-corps.
@export var phase2_threshold: float = 0.5

## AoE optionnelle (désactivée par défaut) : pulse de zone autour du boss.
@export var enable_aoe: bool = false
@export var aoe_damage: int = 15
@export var aoe_interval: float = 4.0
@export var aoe_radius: float = 180.0

const BULLET := preload("res://scenes/enemy_bullet/bullet.tscn")
const RANGED_KEEP := 260.0   # distance visée en phase 1
const MELEE_REACH := 48.0

var current_health: int
var phase: int = 1
var player_ref: Node = null

var _fire_interval := 1.1
var _fire_t := 0.0
var _melee_cd := 1.0
var _melee_t := 0.0
var _aoe_t := 0.0

func _ready() -> void:
	current_health = max_health
	add_to_group("boss")
	_acquire_player()

func _acquire_player() -> void:
	player_ref = get_tree().current_scene.find_child("Actor", true, false)

func _physics_process(delta: float) -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		_acquire_player()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player: Vector2 = player_ref.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized()

	if phase == 1:
		_phase1(delta, dir, dist)
	else:
		_phase2(delta, dir, dist)

	if enable_aoe:
		_aoe(delta)

	move_and_slide()

## Phase 1 : garde ~RANGED_KEEP de distance et tire à intervalle régulier.
func _phase1(delta: float, dir: Vector2, dist: float) -> void:
	if dist < RANGED_KEEP - 20.0:
		velocity = -dir * speed
	elif dist > RANGED_KEEP + 20.0:
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO
	_fire_t -= delta
	if _fire_t <= 0.0:
		_shoot(dir)
		_fire_t = _fire_interval

## Phase 2 : fonce au contact et frappe au corps-à-corps (cooldown).
func _phase2(delta: float, dir: Vector2, dist: float) -> void:
	velocity = dir * speed if dist > MELEE_REACH else Vector2.ZERO
	_melee_t -= delta
	if dist <= MELEE_REACH and _melee_t <= 0.0:
		if player_ref.has_method("take_damage"):
			player_ref.take_damage(melee_damage)
		_melee_t = _melee_cd

func _shoot(dir: Vector2) -> void:
	var b := BULLET.instantiate()
	b.damage = ranged_damage
	b.pos = global_position + dir * 36.0
	b.rota = dir.angle()
	b.dir = dir.angle()
	get_tree().current_scene.add_child(b)

func _aoe(delta: float) -> void:
	_aoe_t -= delta
	if _aoe_t <= 0.0:
		_aoe_t = aoe_interval
		if is_instance_valid(player_ref) \
		and global_position.distance_to(player_ref.global_position) <= aoe_radius \
		and player_ref.has_method("take_damage"):
			player_ref.take_damage(aoe_damage)

## Reçoit les dégâts des balles du joueur (même contrat que les ennemis).
func take_damage(amount: int) -> void:
	current_health -= amount
	if phase == 1 and current_health <= int(max_health * phase2_threshold):
		_enter_phase2()
	if current_health <= 0:
		_die()

func _enter_phase2() -> void:
	phase = 2
	modulate = Color(1.0, 0.5, 0.5)  # vire au rouge en phase corps-à-corps

func _die() -> void:
	Stats.add_kill()
	died.emit()
	queue_free()
