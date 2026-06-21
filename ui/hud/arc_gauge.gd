@tool
class_name HudArcGauge
extends Control

## Jauge circulaire dessinée (style cadran de HUD power-armor Fallout).
## Dessine un anneau de fond + un anneau de valeur (3/4 de cercle, ouverture en bas),
## avec le nombre au centre et une légende en dessous. Tout est tracé dans _draw()
## → aucun nœud enfant, fonctionne en aperçu éditeur (@tool).

@export var caption: String = "" : set = _set_caption
@export var max_value: float = 100.0 : set = _set_max
@export var value: float = 100.0 : set = _set_value
## Anneau toujours plein (badge) — pour un compteur sans maximum (ex. kills).
@export var full_ring: bool = false : set = _set_full
@export var arc_color: Color = Color(1.0, 0.72, 0.22)
@export var track_color: Color = Color(0.35, 0.2, 0.05, 0.85)
@export var arc_width: float = 9.0

const START := deg_to_rad(135.0)
const SWEEP := deg_to_rad(270.0)

func _set_caption(v: String) -> void:
	caption = v
	queue_redraw()

func _set_max(v: float) -> void:
	max_value = v
	queue_redraw()

func _set_value(v: float) -> void:
	value = v
	queue_redraw()

func _set_full(v: bool) -> void:
	full_ring = v
	queue_redraw()

## Met à jour la jauge ; maximum < 0 = inchangé.
func set_value(v: float, maximum: float = -1.0) -> void:
	if maximum >= 0.0:
		max_value = maximum
	value = v

func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.5 - arc_width
	if r <= 0.0:
		return
	# anneau de fond
	draw_arc(c, r, START, START + SWEEP, 48, track_color, arc_width, true)
	# anneau de valeur
	var frac := 1.0
	if not full_ring and max_value > 0.0:
		frac = clampf(value / max_value, 0.0, 1.0)
	if frac > 0.0:
		draw_arc(c, r, START, START + SWEEP * frac, 48, arc_color, arc_width, true)

	var font := get_theme_default_font()
	# nombre centré
	var num := str(int(round(value)))
	var nfs := int(r * 0.8)
	var nsz := font.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, nfs)
	var baseline := c.y - nsz.y * 0.5 + font.get_ascent(nfs)
	draw_string(font, Vector2(c.x - nsz.x * 0.5, baseline), num,
		HORIZONTAL_ALIGNMENT_LEFT, -1, nfs, arc_color)
	# légende sous le cadran
	if caption != "":
		var cfs := int(maxf(r * 0.36, 10.0))
		var csz := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, cfs)
		draw_string(font, Vector2(c.x - csz.x * 0.5, size.y - 2.0), caption,
			HORIZONTAL_ALIGNMENT_LEFT, -1, cfs, arc_color.lerp(track_color, 0.35))
