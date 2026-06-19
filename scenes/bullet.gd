extends Area2D

@export var speed: float = 800.0
var direction: Vector2 = Vector2.ZERO

# Cette fonction est appelée par le script principal juste après avoir créé la balle
func set_direction(dir: Vector2) -> void:
	direction = dir
	# Optionnel : oriente visuellement la balle dans la direction du tir
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# On déplace la balle manuellement à chaque frame
	position += direction * speed * delta

func _on_body_entered(_body: Node2D) -> void:
	# Plus tard, tu pourras vérifier si "body" est un ennemi pour lui faire perdre des PV
	
	# Détruit la balle immédiatement
	queue_free()
