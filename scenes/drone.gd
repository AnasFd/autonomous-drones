extends Node3D

var speed = 5.0
var direction = Vector3.ZERO

func _ready():
	randomize()
	# Le drone va choisir une direction au hasard
	direction = Vector3(randf(), randf(), randf()).normalized()

func _process(delta):
	# Déplacement du drone dans une direction choisie
	position += direction * speed * delta
	
	# Faire tourner le drone légèrement
	rotate_y(0.01)

	# Si le drone sort de la zone, choisir une nouvelle direction
	if position.length() > 10.0:
		direction = Vector3(randf(), randf(), randf()).normalized()
		position = Vector3.ZERO
