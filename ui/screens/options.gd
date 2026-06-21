extends Control

## Options screen: volume, fullscreen, language. Built bespoke (not from MenuScreen)
## because it uses sliders/toggles instead of a plain button list — a good example
## of a custom screen that still shares the theme + localization.
##
## Deux modes :
##  - plein écran : "Retour" change de scène vers `back_scene` (depuis le menu principal).
##  - superposition : si `back_scene` est vide, "Retour" émet `closed` sans changer de
##    scène (utilisé par le menu pause pour garder la partie en cours dessous).

signal closed

@export_file("*.tscn") var back_scene:String = "res://ui/screens/main_menu.tscn"

const CONTROLS_SCENE := preload("res://ui/screens/controls.tscn")

@onready var _volume:HSlider = %VolumeSlider
@onready var _fullscreen:CheckButton = %FullscreenCheck
@onready var _language:OptionButton = %LanguageOption
@onready var _controls_btn:Button = %ControlsButton
@onready var _back:Button = %BackButton
@onready var _center:Control = $Center

var _controls:Control = null

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

	_controls_btn.pressed.connect(_open_controls)
	_back.pressed.connect(_on_back)
	_back.grab_focus.call_deferred()

## Ouvre l'écran Contrôles en superposition (revient ici à la fermeture).
func _open_controls()->void:
	if _controls != null:
		return
	_center.hide()  # masque les options derrière → plus de navigation parasite
	_controls = CONTROLS_SCENE.instantiate()
	_controls.back_scene = ""  # mode superposition → "Retour" ferme et revient ici
	_controls.closed.connect(_on_controls_closed)
	add_child(_controls)

func _on_controls_closed()->void:
	_controls = null
	_center.show()
	_controls_btn.grab_focus()  # rend le focus pour continuer à naviguer

## Échap / B (manette) = retour (sauf si l'écran Contrôles est ouvert : il gère lui-même).
func _unhandled_input(event:InputEvent)->void:
	if _controls != null:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back()

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
	# Mode superposition (menu pause) : on ferme sans changer de scène.
	if back_scene == "":
		closed.emit()
		queue_free()
		return
	var _ui:Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("change_scene"):
		_ui.change_scene(back_scene)
	else:
		get_tree().change_scene_to_file(back_scene)
