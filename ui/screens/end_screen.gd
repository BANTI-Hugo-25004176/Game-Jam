extends Control

## Shared controller for the Game Over and Victory screens. Handles the "retry"
## action; the "Main Menu" button uses a target_scene, so it needs no code.

@onready var _menu:MenuScreen = $Menu

func _ready()->void:
	_menu.action_pressed.connect(_on_action)

func _on_action(action:String)->void:
	match action:
		"retry":
			UI.change_scene("res://scenes/game.tscn")
		_:
			pass
