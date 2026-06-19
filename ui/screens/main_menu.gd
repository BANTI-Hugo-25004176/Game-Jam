extends Control

## Example screen built on the GUI template. Shows how to handle custom button
## actions (here: Quit). Buttons that simply open another scene don't need any of
## this — just set their MenuItem.target_scene in the Inspector.

@onready var _menu:MenuScreen = $MenuScreen

func _ready()->void:
	_menu.action_pressed.connect(_on_action)

func _on_action(action:String)->void:
	match action:
		"quit":
			get_tree().quit()
		"play":
			print("[MainMenu] 'Play' pressed — wire this to the game scene when it exists.")
		"options":
			print("[MainMenu] 'Options' pressed — wire this to the Options screen.")
		_:
			print("[MainMenu] Unhandled action: %s" % action)
