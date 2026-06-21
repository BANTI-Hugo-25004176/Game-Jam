class_name GameHud
extends CanvasLayer

## HUD en jeu — inspiré du HUD power-armor de Fallout 4 : cadrans ambrés dessinés
## (VIE + KILLS) en bas à gauche, munitions en bas à droite, et un fort vignettage
## de visière de casque sur les bords. Le code de jeu l'alimente via les setters
## publics ci-dessous (voir scenes/game.gd).

@export var max_health: int = 100
@export var health: int = 100
@export var kills: int = 0
## Munitions infinies → "∞" seul (aperçu). En jeu, set_ammo() passe en "count/∞".
@export var infinite_ammo: bool = true

@onready var _hp_gauge: HudArcGauge = %HpGauge
@onready var _kills_gauge: HudArcGauge = %KillsGauge
@onready var _ammo_label: Label = %AmmoLabel

var _ammo_count: int = -1
var _reloading: bool = false

func _ready() -> void:
	# Compteur de kills alimenté par l'autoload Stats (incrémenté à la mort d'un ennemi).
	var _stats: Node = get_node_or_null("/root/Stats")
	if _stats != null:
		_stats.kills_changed.connect(set_kills)
		kills = _stats.kills
	_refresh()

func _refresh() -> void:
	set_health(health, max_health)
	set_kills(kills)
	_refresh_ammo()

# --- API publique (le jeu appelle ces fonctions) ---

func set_health(current: int, maximum: int = -1) -> void:
	if maximum >= 0:
		max_health = maximum
	health = clampi(current, 0, max_health)
	if _hp_gauge != null:
		_hp_gauge.set_value(health, max_health)

func set_kills(value: int) -> void:
	kills = max(0, value)
	if _kills_gauge != null:
		_kills_gauge.set_value(kills)

func add_kill() -> void:
	set_kills(kills + 1)

## Munitions : chargeur fini (count) sur réserve infinie → "count/∞".
## `reloading` affiche un état de rechargement à la place du compteur.
func set_ammo(count: int, reloading: bool = false) -> void:
	infinite_ammo = false
	_ammo_count = max(0, count)
	_reloading = reloading
	_refresh_ammo()

# --- Rendu ---

func _refresh_ammo() -> void:
	if _ammo_label == null:
		return
	if infinite_ammo:
		_ammo_label.text = "∞"
	elif _reloading:
		_ammo_label.text = tr("HUD_RELOADING")
	else:
		_ammo_label.text = "%d/∞" % _ammo_count
