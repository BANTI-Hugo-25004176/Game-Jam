class_name MenuScreen
extends Control

## Data-driven menu screen — the heart of the GUI template.
##
## To make a menu: set `title_key` and fill `items` in the Inspector. No code needed.
##  - A button that just opens another scene: set that item's `target_scene`.
##  - A button with custom behaviour (resume, quit, ...): leave `target_scene`
##    empty, set `action`, and handle the `action_pressed` signal from a small
##    controller script (see ui/screens/main_menu.gd for an example).
##
## All labels are translation keys, so the menu is automatically FR/EN.

signal action_pressed(action:String)

## Translation key shown as the screen title (see ui/localization/ui_text.csv).
@export var title_key:String = ""

## The buttons, top to bottom.
@export var items:Array[MenuItem] = []

## Button scene spawned per item (defaults to menu_button.tscn in the template).
@export var button_scene:PackedScene

@onready var _title:Label = %Title
@onready var _buttons:VBoxContainer = %Buttons

func _ready()->void:
	_title.text = title_key
	_title.visible = title_key != ""
	rebuild()

## (Re)build the buttons from `items`. Public so a screen can change items at runtime.
func rebuild()->void:
	for _child:Node in _buttons.get_children():
		_child.queue_free()
	var _first:Control = null
	for _item:MenuItem in items:
		if _item == null:
			continue
		var _btn:Button = button_scene.instantiate()
		_btn.text = _item.text_key
		_btn.pressed.connect(_on_pressed.bind(_item))
		_buttons.add_child(_btn)
		if _first == null:
			_first = _btn
	# Focus the first button so keyboard/gamepad can navigate immediately.
	if _first != null:
		_first.grab_focus.call_deferred()

func _on_pressed(item:MenuItem)->void:
	if item.target_scene != "":
		_change_scene(item.target_scene)
		return
	action_pressed.emit(item.action)

## Use the UI autoload's fade transition if present, else change scene directly.
func _change_scene(path:String)->void:
	var _ui:Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("change_scene"):
		_ui.change_scene(path)
	else:
		get_tree().change_scene_to_file(path)
