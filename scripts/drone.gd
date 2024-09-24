extends RigidBody3D

var speed: float = 2.0
var angle: float = 0.0  # Angle pour le mouvement circulaire
var radius: float = 5.0  # Rayon du cercle

func _ready():
	pass

func _process(_delta):
	pass
	#move_in_circle(delta)

func move_in_circle(delta):
	# Calculer la nouvelle position en fonction de l'angle
	angle += speed * delta  # Ajuster l'angle en fonction de la vitesse
	position.x = radius * cos(angle)  # Calculer la position x
	position.z = radius * sin(angle)  # Calculer la position z
