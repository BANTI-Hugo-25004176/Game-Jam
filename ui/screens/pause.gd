extends CanvasLayer

## Pause overlay. The game adds this on the pause input to freeze the game and show
## the menu. Runs while the tree is paused (process_mode = Always, set in the scene).

const OPTIONS_SCENE = preload("res://ui/screens/options.tscn")

@onready var _menu:MenuScreen = %Menu

var _options:Control = null

func _ready()->void:
	get_tree().paused = true
	_menu.action_pressed.connect(_on_action)

func _on_action(action:String)->void:
	match action:
		"resume":
			get_tree().paused = false
			queue_free()
		"options":
			_open_options()
		"main_menu":
			get_tree().paused = false
			_go("res://ui/screens/main_menu.tscn")
		"quit":
			get_tree().quit()

## Ouvre les Options en superposition (la partie reste en pause dessous).
func _open_options()->void:
	if _options != null:
		return
	_menu.hide()
	_options = OPTIONS_SCENE.instantiate()
	_options.back_scene = ""  # mode superposition → "Retour" ferme sans changer de scène
	_options.closed.connect(_on_options_closed)
	add_child(_options)

func _on_options_closed()->void:
	_options = null
	_menu.show()
	_menu.grab_first_focus()  # rend le focus pour continuer à naviguer

func _unhandled_input(event: InputEvent) -> void:
	# "Pause" (Échap/Start) ou "ui_cancel" (Échap/B) = revenir en arrière.
	if not (event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel")):
		return
	get_viewport().set_input_as_handled()
	# Si les Options sont ouvertes, on les referme d'abord.
	if _options != null:
		_options.queue_free()
		_on_options_closed()
		return
	get_tree().paused = false
	queue_free()

func _go(path:String)->void:
	var _ui:Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("change_scene"):
		_ui.change_scene(path)
	else:
		get_tree().change_scene_to_file(path)
