class_name UiMenuButton
extends Button

## Reusable menu button: consistent focus behaviour + optional hover/click sound.
## The MenuScreen sets `text` to a translation key; Godot auto-translates it and
## re-translates automatically when the locale changes.

@export var hover_sound:AudioStream
@export var press_sound:AudioStream

@onready var _sfx:AudioStreamPlayer = $Sfx

func _ready()->void:
	focus_mode = Control.FOCUS_ALL
	# Hovering with the mouse moves keyboard/gamepad focus too, so both stay in sync.
	if not mouse_entered.is_connected(grab_focus):
		mouse_entered.connect(grab_focus)
	focus_entered.connect(_play.bind(true))
	pressed.connect(_play.bind(false))

func _play(is_hover:bool)->void:
	var _stream:AudioStream = hover_sound if is_hover else press_sound
	if _stream != null:
		_sfx.stream = _stream
		_sfx.play()
