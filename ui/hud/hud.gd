class_name GameHud
extends CanvasLayer

## In-game HUD — Fallout 4 power-armor inspired (amber gauges + visor vignette).
## Self-contained overlay: drop it into the game scene. Gameplay code feeds it via
## the public setters below. Exported values let it preview in the editor before the
## gameplay data exists.
##
## NOTE (integration): this is the base. Timéo's shooting/weapon + health data get
## wired INTO these setters once they land — the HUD is not rebuilt around them.

@export var max_health:int = 100
@export var health:int = 100
## Up to 3 weapon labels; "" = empty slot.
@export var weapons:Array[String] = ["Pistolet", "", ""]
@export var current_weapon:int = 0
@export var kills:int = 0
## Infinite ammo for now → shows the ∞ symbol. Set false + use set_ammo() later.
@export var infinite_ammo:bool = true

@onready var _health_bar:ProgressBar = %HealthBar
@onready var _health_label:Label = %HealthLabel
@onready var _kills_label:Label = %KillsLabel
@onready var _ammo_label:Label = %AmmoLabel
@onready var _weapon_slots:HBoxContainer = %WeaponSlots
@onready var _ammo_count:int = -1  # -1 = infinite

func _ready()->void:
	_refresh()

func _refresh()->void:
	_refresh_health()
	_refresh_kills()
	_refresh_weapons()
	_refresh_ammo()

# --- Public API (gameplay calls these) ---

func set_health(current:int, maximum:int = -1)->void:
	if maximum >= 0:
		max_health = maximum
	health = clampi(current, 0, max_health)
	_refresh_health()

func set_kills(value:int)->void:
	kills = max(0, value)
	_refresh_kills()

func add_kill()->void:
	set_kills(kills + 1)

## names: up to 3 weapon labels; current: highlighted slot index.
func set_weapons(names:Array, current:int)->void:
	weapons = []
	for i in 3:
		weapons.append(str(names[i]) if i < names.size() else "")
	current_weapon = clampi(current, 0, 2)
	_refresh_weapons()

## Switch to finite ammo display (use when guns get limited ammo later).
func set_ammo(count:int)->void:
	infinite_ammo = false
	_ammo_count = max(0, count)
	_refresh_ammo()

# --- Rendering ---

func _refresh_health()->void:
	_health_bar.max_value = max_health
	_health_bar.value = health
	_health_label.text = "%d / %d" % [health, max_health]

func _refresh_kills()->void:
	_kills_label.text = str(kills)

func _refresh_ammo()->void:
	_ammo_label.text = "∞" if infinite_ammo else str(_ammo_count)

func _refresh_weapons()->void:
	var _slots:Array[Node] = _weapon_slots.get_children()
	for i in _slots.size():
		var _slot:Control = _slots[i]
		var _name:String = weapons[i] if i < weapons.size() else ""
		var _label:Label = _slot.get_node_or_null("Name")
		if _label != null:
			_label.text = _name
		# highlight the current weapon slot
		_slot.modulate = Color(1, 1, 1, 1) if i == current_weapon else Color(0.55, 0.55, 0.55, 0.7)
