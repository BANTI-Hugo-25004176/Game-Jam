extends Control

## Écran de crédits.
##
## ╔══════════════════════════════════════════════════════════════════╗
## ║  POUR MODIFIER LES CRÉDITS : édite UNIQUEMENT la constante         ║
## ║  CREDITS ci-dessous. C'est du BBCode (balises entre crochets).     ║
## ║  Exemples : [b]gras[/b], [i]italique[/i], [font_size=40]gros[/...] ║
## ║  Une ligne vide = un saut de ligne. Rien d'autre à toucher.        ║
## ╚══════════════════════════════════════════════════════════════════╝
##
## Ouvert depuis le menu principal (bouton Crédits) ou en fin de démo.
## "Retour" / Échap / B (manette) reviennent à `back_scene` (ou ferment en
## superposition si `back_scene` est vide).

signal closed

@export_file("*.tscn") var back_scene: String = "res://ui/screens/main_menu.tscn"

const CREDITS := "[center][font_size=56]AXEL[/font_size]
[i]— démo —[/i]

Game Jam « Pixels en Provence » · juin 2026


[font_size=30]ÉQUIPE[/font_size]
[b]Timothée Beghin[/b] — UI · menus · HUD · contrôles
[b]Timéo Morsilli[/b] — joueur · armes · manette · sons
[b]Enrique Ruiz[/b] — ennemis · combat · boss
[b]Hugo Banti[/b] — cinématique d'intro
[b]Vladislav Dumont[/b] — map · combat


[font_size=30]ASSETS[/font_size]
Police « DIESELPUNK » — Dan Zadorozny / Iconian Fonts
[i]iconian.com — gratuite pour usage académique[/i]
Sprite du joueur — Nicolas Zoppi
Sprite de l'arme — Vladislav Dumont
Sons — Timéo Morsilli
[i][autres assets : à compléter][/i]


[font_size=30]OUTILS[/font_size]
Godot Engine 4.7


[font_size=30]CLAUDE CODE[/font_size]
[i]Assistant IA de Timothée[/i]
Revues de PR + validation Godot (headless),
HUD & écran Game Over, menu de configuration des
contrôles (remap clavier/manette, sensibilité),
correctifs de flux menu, localisation FR/EN,
configuration d'export (Windows/Web), cet écran.


[font_size=40]Merci d'avoir joué ![/font_size][/center]"

@onready var _body: RichTextLabel = %Body
@onready var _back: Button = %BackButton

func _ready() -> void:
	_body.text = CREDITS
	_back.text = tr("OPT_BACK")
	_back.pressed.connect(_on_back)
	_back.grab_focus.call_deferred()

## Échap (clavier) / B (manette) = Retour.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back()

func _on_back() -> void:
	# Mode superposition (back_scene vide) : on ferme sans changer de scène.
	if back_scene == "":
		closed.emit()
		queue_free()
		return
	var _ui: Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("change_scene"):
		_ui.change_scene(back_scene)
	else:
		get_tree().change_scene_to_file(back_scene)
