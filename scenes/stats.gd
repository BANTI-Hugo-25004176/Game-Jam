extends Node

## État de partie partagé (autoload "Stats").
## Pour l'instant : le compteur de kills, alimenté à la mort d'un ennemi
## (voir scenes/Enemy/enemy.gd) et lu par le HUD (ui/hud/hud.gd).

signal kills_changed(total: int)

var kills: int = 0

func add_kill() -> void:
	kills += 1
	kills_changed.emit(kills)

## À appeler au début d'une nouvelle partie pour repartir de zéro.
func reset() -> void:
	kills = 0
	kills_changed.emit(kills)
