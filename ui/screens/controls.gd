extends Control

## Écran de configuration des contrôles (issue #43).
## Liste les actions de jeu et permet de réassigner la touche **clavier** et le
## bouton **manette** de chacune, plus un réglage de sensibilité de visée, un reset
## et la sauvegarde (via l'autoload InputConfig).
##
## Deux modes, comme l'écran Options :
##  - plein écran : "Retour" change de scène vers `back_scene`.
##  - superposition : si `back_scene` est vide, "Retour" émet `closed`.

signal closed

@export_file("*.tscn") var back_scene: String = "res://ui/screens/main_menu.tscn"

const ACTION_KEYS := {
	"move_up": "CTRL_UP", "move_down": "CTRL_DOWN",
	"move_left": "CTRL_LEFT", "move_right": "CTRL_RIGHT",
	"dash": "CTRL_DASH", "shoot": "CTRL_SHOOT", "reload": "CTRL_RELOAD", "pause": "CTRL_PAUSE",
}

var _listening_action: String = ""
var _listening_kind: String = ""
var _rows: Dictionary = {}  # action -> {"key": Button, "pad": Button}

@onready var _list: VBoxContainer = %ActionList
@onready var _sens: HSlider = %SensSlider
@onready var _reset: Button = %ResetButton
@onready var _back: Button = %BackButton

func _ready() -> void:
	_build_rows()
	_sens.min_value = 2.0
	_sens.max_value = 20.0
	_sens.step = 1.0
	_sens.value = InputConfig.aim_sensitivity
	_sens.value_changed.connect(_on_sens_changed)
	_reset.pressed.connect(_on_reset)
	_back.pressed.connect(_on_back)
	_back.grab_focus.call_deferred()

func _build_rows() -> void:
	for action in InputConfig.ACTIONS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var lbl := Label.new()
		lbl.text = tr(ACTION_KEYS.get(action, action))
		lbl.custom_minimum_size.x = 180
		var kb := Button.new()
		kb.custom_minimum_size.x = 170
		kb.pressed.connect(_start_listen.bind(action, "key"))
		var pad := Button.new()
		pad.custom_minimum_size.x = 170
		pad.pressed.connect(_start_listen.bind(action, "pad"))
		row.add_child(lbl)
		row.add_child(kb)
		row.add_child(pad)
		_list.add_child(row)
		_rows[action] = {"key": kb, "pad": pad}
	_refresh_labels()

func _refresh_labels() -> void:
	for action in _rows:
		_rows[action]["key"].text = _event_text(InputConfig.first_event_of(action, "key"))
		_rows[action]["pad"].text = _event_text(InputConfig.first_event_of(action, "pad"))

func _event_text(ev: InputEvent) -> String:
	if ev == null:
		return "—"
	if ev is InputEventKey:
		return InputConfig.key_label(ev)
	if ev is InputEventJoypadButton:
		return InputConfig.pad_button_label(ev.button_index)
	if ev is InputEventJoypadMotion:
		return InputConfig.pad_axis_label(ev.axis, ev.axis_value)
	return "?"

func _start_listen(action: String, kind: String) -> void:
	if _listening_action != "":
		_refresh_labels()  # annule une écoute précédente
	_listening_action = action
	_listening_kind = kind
	_rows[action][kind].text = "..."

func _input(event: InputEvent) -> void:
	if _listening_action == "":
		# Pas en écoute : Échap / B (manette) = retour.
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			_on_back()
		return
	# En écoute : Échap / B annule la réassignation (sans rien lier).
	if event.is_action_pressed("ui_cancel"):
		_listening_action = ""
		_listening_kind = ""
		_refresh_labels()
		get_viewport().set_input_as_handled()
		return
	var new_ev: InputEvent = null
	if _listening_kind == "key" and event is InputEventKey and event.pressed and not event.echo:
		var e := InputEventKey.new()
		e.physical_keycode = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		new_ev = e
	elif _listening_kind == "pad":
		if event is InputEventJoypadButton and event.pressed:
			var e := InputEventJoypadButton.new()
			e.button_index = event.button_index
			new_ev = e
		elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
			var e := InputEventJoypadMotion.new()
			e.axis = event.axis
			e.axis_value = signf(event.axis_value)
			new_ev = e
	if new_ev != null:
		InputConfig.rebind(_listening_action, _listening_kind, new_ev)
		InputConfig.save_config()
		_listening_action = ""
		_listening_kind = ""
		_refresh_labels()
		get_viewport().set_input_as_handled()

func _on_sens_changed(value: float) -> void:
	InputConfig.aim_sensitivity = value
	InputConfig.save_config()

func _on_reset() -> void:
	InputConfig.reset_defaults()
	_sens.value = InputConfig.aim_sensitivity
	_refresh_labels()

func _on_back() -> void:
	if back_scene == "":
		closed.emit()
		queue_free()
		return
	var _ui: Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("change_scene"):
		_ui.change_scene(back_scene)
	else:
		get_tree().change_scene_to_file(back_scene)
