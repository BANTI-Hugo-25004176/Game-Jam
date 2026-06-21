extends Node

## Autoload "InputConfig" : remaps de contrôles (clavier + manette) et sensibilité
## de visée, persistés dans user://controls.cfg. Chargé au démarrage et appliqué à
## l'InputMap, de sorte que les réglages survivent entre deux sessions.

const PATH := "user://controls.cfg"

## Actions de jeu remappables (dans l'ordre d'affichage).
const ACTIONS: Array[String] = [
	"move_up", "move_down", "move_left", "move_right", "dash", "shoot", "reload", "pause",
]

## Sensibilité de visée manette = vitesse de rotation de l'arme vers le stick droit
## (radians/seconde environ ; plus haut = visée plus vive). Lue par le gun.
var aim_sensitivity: float = 8.0

var _defaults: Dictionary = {}  # action -> Array[InputEvent] (snapshot des défauts projet)

func _ready() -> void:
	_snapshot_defaults()
	load_config()

func _snapshot_defaults() -> void:
	for action in ACTIONS:
		if InputMap.has_action(action):
			_defaults[action] = InputMap.action_get_events(action).duplicate()

# --- Lecture / écriture InputMap ---

## Premier event "key" (clavier) ou "pad" (manette) d'une action, ou null.
func first_event_of(action: String, kind: String) -> InputEvent:
	if not InputMap.has_action(action):
		return null
	for ev in InputMap.action_get_events(action):
		if kind == "key" and ev is InputEventKey:
			return ev
		if kind == "pad" and (ev is InputEventJoypadButton or ev is InputEventJoypadMotion):
			return ev
	return null

## Remplace l'event clavier (kind="key") ou manette (kind="pad") d'une action,
## en conservant l'autre type.
func rebind(action: String, kind: String, new_ev: InputEvent) -> void:
	if new_ev == null or not InputMap.has_action(action):
		return
	for ev in InputMap.action_get_events(action):
		var is_key := ev is InputEventKey
		var is_pad := ev is InputEventJoypadButton or ev is InputEventJoypadMotion
		if (kind == "key" and is_key) or (kind == "pad" and is_pad):
			InputMap.action_erase_event(action, ev)
	InputMap.action_add_event(action, new_ev)

func reset_defaults() -> void:
	for action in ACTIONS:
		if _defaults.has(action):
			InputMap.action_erase_events(action)
			for ev in _defaults[action]:
				InputMap.action_add_event(action, ev)
	aim_sensitivity = 8.0
	save_config()

# --- Persistance ---

func save_config() -> void:
	var cfg := ConfigFile.new()
	for action in ACTIONS:
		var kb := first_event_of(action, "key")
		var pad := first_event_of(action, "pad")
		if kb != null:
			cfg.set_value("keyboard", action, _encode(kb))
		if pad != null:
			cfg.set_value("controller", action, _encode(pad))
	cfg.set_value("aim", "sensitivity", aim_sensitivity)
	cfg.save(PATH)

func load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	for action in ACTIONS:
		if cfg.has_section_key("keyboard", action):
			rebind(action, "key", _decode(cfg.get_value("keyboard", action)))
		if cfg.has_section_key("controller", action):
			rebind(action, "pad", _decode(cfg.get_value("controller", action)))
	aim_sensitivity = cfg.get_value("aim", "sensitivity", aim_sensitivity)

func _encode(ev: InputEvent) -> Dictionary:
	if ev is InputEventKey:
		return {"t": "key", "physical": ev.physical_keycode, "keycode": ev.keycode}
	elif ev is InputEventJoypadButton:
		return {"t": "pad_btn", "button": ev.button_index}
	elif ev is InputEventJoypadMotion:
		return {"t": "pad_axis", "axis": ev.axis, "value": ev.axis_value}
	return {}

func _decode(d: Dictionary) -> InputEvent:
	match d.get("t", ""):
		"key":
			var e := InputEventKey.new()
			e.physical_keycode = d.get("physical", 0)
			e.keycode = d.get("keycode", 0)
			return e
		"pad_btn":
			var e := InputEventJoypadButton.new()
			e.button_index = d.get("button", 0)
			return e
		"pad_axis":
			var e := InputEventJoypadMotion.new()
			e.axis = d.get("axis", 0)
			e.axis_value = d.get("value", 0.0)
			return e
	return null

## Libellé lisible (touche/bouton) de la 1re entrée d'une action — pour les
## menus et le tutoriel. Reflète les remaps en cours (lit l'InputMap).
func display_label(action: String, kind: String) -> String:
	var ev := first_event_of(action, kind)
	if ev == null:
		return "—"
	if ev is InputEventKey:
		var code: int = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
		return OS.get_keycode_string(code)
	if ev is InputEventJoypadButton:
		return "Bouton %d" % ev.button_index
	if ev is InputEventJoypadMotion:
		return "Axe %d %s" % [ev.axis, "+" if ev.axis_value > 0.0 else "-"]
	return "?"
