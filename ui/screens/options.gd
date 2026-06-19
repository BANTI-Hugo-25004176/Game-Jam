extends Control

## Options screen: volume, fullscreen, language. Built bespoke (not from MenuScreen)
## because it uses sliders/toggles instead of a plain button list — a good example
## of a custom screen that still shares the theme + localization.

@export_file("*.tscn") var back_scene:String = "res://ui/screens/main_menu.tscn"

@onready var _volume:HSlider = %VolumeSlider
@onready var _fullscreen:CheckButton = %FullscreenCheck
@onready var _language:OptionButton = %LanguageOption
@onready var _back:Button = %BackButton

func _ready()->void:
	var _bus:int = AudioServer.get_bus_index("Master")
	_volume.value = db_to_linear(AudioServer.get_bus_volume_db(_bus))
	_volume.value_changed.connect(_on_volume_changed)

	_fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_fullscreen.toggled.connect(_on_fullscreen_toggled)

	# 0 = Français, 1 = English (shown in each language's own name, untranslated).
	_language.clear()
	_language.add_item("Français", 0)
	_language.add_item("English", 1)
	_language.selected = 1 if TranslationServer.get_locale().begins_with("en") else 0
	_language.item_selected.connect(_on_language_selected)

	_back.pressed.connect(_on_back)
	_back.grab_focus.call_deferred()

func _on_volume_changed(value:float)->void:
	var _bus:int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))

func _on_fullscreen_toggled(on:bool)->void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_language_selected(index:int)->void:
	var _locale:String = "en" if index == 1 else "fr"
	var _ui:Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("set_language"):
		_ui.set_language(_locale)
	else:
		TranslationServer.set_locale(_locale)

func _on_back()->void:
	var _ui:Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("change_scene"):
		_ui.change_scene(back_scene)
	else:
		get_tree().change_scene_to_file(back_scene)
