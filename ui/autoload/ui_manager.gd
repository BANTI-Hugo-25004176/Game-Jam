extends CanvasLayer

## Autoload "UI": fade transitions between scenes + game-wide UI language.
##  - UI.change_scene("res://path/to/scene.tscn"): fade out, swap, fade in.
##    MenuScreen uses this automatically when the autoload is present.
##  - UI.set_language("fr" | "en"): switch the UI language at runtime.

@export var fade_time:float = 0.3

## Language at startup — French-first. The Options screen can switch via
## set_language() at runtime; persisting the choice across launches is a TODO.
@export var default_locale:String = "fr"

@onready var _fade:ColorRect = $Fade

func _ready()->void:
	set_language(default_locale)

## Switch the UI language. `locale` is "fr" or "en".
func set_language(locale:String)->void:
	TranslationServer.set_locale(locale)

func change_scene(path:String)->void:
	var _tween:Tween = create_tween()
	_tween.tween_property(_fade, "color:a", 1.0, fade_time)
	_tween.tween_callback(_do_change.bind(path))
	_tween.tween_property(_fade, "color:a", 0.0, fade_time)

func _do_change(path:String)->void:
	get_tree().change_scene_to_file(path)
