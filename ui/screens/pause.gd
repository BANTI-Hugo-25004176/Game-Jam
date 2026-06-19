extends CanvasLayer

## Pause overlay. The game adds this on the pause input to freeze the game and show
## the menu. Runs while the tree is paused (process_mode = Always, set in the scene).

@onready var _menu:MenuScreen = %Menu

func _ready()->void:
	get_tree().paused = true
	_menu.action_pressed.connect(_on_action)

func _on_action(action:String)->void:
	match action:
		"resume":
			get_tree().paused = false
			queue_free()
		"main_menu":
			get_tree().paused = false
			_go("res://ui/screens/main_menu.tscn")
		"quit":
			get_tree().quit()

func _go(path:String)->void:
	var _ui:Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("change_scene"):
		_ui.change_scene(path)
	else:
		get_tree().change_scene_to_file(path)
