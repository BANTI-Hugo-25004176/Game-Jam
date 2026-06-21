extends Area2D

## Trou de sortie de la démo. Caché et inactif tant que le boss n'est pas mort.
## La scène de jeu appelle `activate()` quand le boss meurt → le trou apparaît.
## Quand le joueur (Actor) entre dedans → fin de démo (écran de victoire).

@export_file("*.tscn") var end_scene: String = "res://ui/screens/victory.tscn"

var _active := false

func _ready() -> void:
	visible = false
	monitoring = false
	body_entered.connect(_on_body_entered)

## Appelée par game.gd à la mort du boss.
func activate() -> void:
	_active = true
	visible = true
	monitoring = true

func _on_body_entered(body: Node) -> void:
	if not _active or body.name != "Actor":
		return
	var _ui: Node = get_node_or_null("/root/UI")
	if _ui != null and _ui.has_method("change_scene"):
		_ui.change_scene(end_scene)
	else:
		get_tree().change_scene_to_file(end_scene)
