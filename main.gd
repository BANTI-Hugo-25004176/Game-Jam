extends Node2D

# Précharge la scène de ta balle
const BULLET_SCENE = preload("res://scenes/bullet.tscn")

# La fonction générée automatiquement par Godot quand tu as connecté le signal
func _on_player_shoot_fired(pos: Vector2, dir: Vector2) -> void:
	var bullet_instance = BULLET_SCENE.instantiate()
	
	bullet_instance.position = pos
	
	bullet_instance.set_direction(dir)
	
	add_child(bullet_instance)
