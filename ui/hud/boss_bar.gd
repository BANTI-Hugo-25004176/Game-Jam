class_name BossBar
extends CanvasLayer

## Miniboss health bar, shown at the top of the screen during the fight.
## Self-contained — drop it into the game scene and drive it from the boss:
##   boss_bar.show_boss("Miniboss", 200)   # at fight start
##   boss_bar.set_health(hp)               # on each hit
##   boss_bar.hide_boss()                  # on death / fight end
## Hidden by default.

@onready var _root:Control = %Root
@onready var _name:Label = %BossName
@onready var _bar:ProgressBar = %BossBar

func _ready()->void:
	_root.visible = false

func show_boss(boss_name:String, max_hp:int)->void:
	_name.text = boss_name
	_bar.max_value = max_hp
	_bar.value = max_hp
	_root.visible = true

func set_health(hp:int)->void:
	_bar.value = clampi(hp, 0, int(_bar.max_value))
	if _bar.value <= 0:
		hide_boss()

func hide_boss()->void:
	_root.visible = false
