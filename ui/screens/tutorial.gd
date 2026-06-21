extends Control

## Écran « Comment jouer » : tableau des contrôles (clavier + manette).
## Les colonnes Clavier/Manette sont lues EN DIRECT depuis l'InputMap, donc
## elles reflètent les touches réassignées dans le menu Contrôles.
##
## ╔══════════════════════════════════════════════════════════════════╗
## ║  POUR MODIFIER : édite le tableau ROWS ci-dessous. Chaque ligne :  ║
## ║   "label"   = intitulé affiché                                     ║
## ║   "actions" = actions lues en direct (clavier + manette)           ║
## ║   "key"/"pad" = texte fixe (ce qui n'est pas remappable, ex viser) ║
## ╚══════════════════════════════════════════════════════════════════╝

signal closed

@export_file("*.tscn") var back_scene: String = "res://ui/screens/main_menu.tscn"

const ROWS := [
	{"label": "Se déplacer", "actions": ["move_up", "move_left", "move_down", "move_right"], "pad": "Stick gauche"},
	{"label": "Viser", "key": "Souris", "pad": "Stick droit"},
	{"label": "Tirer", "actions": ["shoot"]},
	{"label": "Dash", "actions": ["dash"]},
	{"label": "Recharger", "actions": ["reload"]},
	{"label": "Pause", "actions": ["pause"]},
]

@onready var _grid: GridContainer = %Grid
@onready var _back: Button = %BackButton

func _ready() -> void:
	_build_table()
	_back.text = tr("OPT_BACK")
	_back.pressed.connect(_on_back)
	_back.grab_focus.call_deferred()

func _build_table() -> void:
	_add_cell("ACTION", true)
	_add_cell("CLAVIER", true)
	_add_cell("MANETTE", true)
	for row in ROWS:
		_add_cell(row["label"], false)
		_add_cell(_col(row, "key"), false)
		_add_cell(_col(row, "pad"), false)

## Texte d'une colonne (kind = "key" clavier / "pad" manette) : texte fixe si
## fourni dans la ligne, sinon lu en direct depuis l'InputMap pour ses actions.
func _col(row: Dictionary, kind: String) -> String:
	if row.has(kind):
		return row[kind]
	var cfg: Node = get_node_or_null("/root/InputConfig")
	if cfg == null or not row.has("actions"):
		return "—"
	var parts: Array[String] = []
	for action in row["actions"]:
		var lbl: String = cfg.display_label(action, kind)
		if lbl != "—" and lbl not in parts:
			parts.append(lbl)
	return " ".join(parts) if not parts.is_empty() else "—"

func _add_cell(text: String, header: bool) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 26 if header else 20)
	if not header:
		lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.88))
	_grid.add_child(lbl)

## Échap (clavier) / B (manette) = Retour.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back()

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
