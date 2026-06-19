extends Control

## Shared controller for the Game Over and Victory screens. Handles the "retry"
## action; the "Main Menu" button uses a target_scene, so it needs no code.

@onready var _menu:MenuScreen = $Menu

func _ready()->void:
	_menu.action_pressed.connect(_on_action)

func _on_action(action:String)->void:
	match action:
		"retry":
			# TODO: when the game scene exists, restart it, e.g.:
			#   get_node_or_null("/root/UI").change_scene("res://path/to/game.tscn")
			print("[EndScreen] 'Retry' pressed — wire to the game scene when it exists.")
		_:
			pass
