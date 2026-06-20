class_name DamageFlash
extends CanvasLayer

## Red edge-vignette flashed when the player takes damage. Self-contained overlay —
## drop it into the game scene and call flash() from the player's damage code, e.g.:
##   $DamageFlash.flash()            # full hit
##   $DamageFlash.flash(0.4)         # light hit
## Optionally call set_low_health(true) to keep a faint red pulse when HP is low.

## Seconds to reach peak red, then to fade back out.
@export var rise:float = 0.05
@export var fade:float = 0.35
## Peak opacity of the red vignette (0..1).
@export var max_amount:float = 0.7

@onready var _rect:ColorRect = $Rect
var _tween:Tween

func flash(strength:float = 1.0)->void:
	var _target:float = clampf(strength, 0.0, 1.0) * max_amount
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_amount, _get_amount(), _target, rise)
	_tween.tween_method(_set_amount, _target, 0.0, fade)

func _set_amount(value:float)->void:
	(_rect.material as ShaderMaterial).set_shader_parameter("amount", value)

func _get_amount()->float:
	return (_rect.material as ShaderMaterial).get_shader_parameter("amount")
