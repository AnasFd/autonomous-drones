extends Node3D

const drone: Resource = preload("res://scenes/drone.tscn")
@onready var light = $DirectionalLight3D
@onready var camera = $Camera3D
@onready var drones = $Drones
var time_since_last_add: float = 0.0
var add_interval: float = 1.0  # Intervalle d'ajout en secondes
var circle_radius: float = 20.0  # Rayon du cercle
var max_num_drones: int = 3  # Nombre total de drones à instancier

func _ready():
	# Light properties
	light.rotation_degrees = Vector3(-90, 0, 0)
	light.position = Vector3(0, 10, 0)

func _process(delta):
	time_since_last_add += delta
	if time_since_last_add >= add_interval:  # Ajouter un drone à chaque intervalle
		if randf() < 0.1 and drones.get_child_count() < max_num_drones:  # Ajouter un drone de temps en temps
			var d: Node3D = drone.instantiate()
			add_child(d)  # Ajouter le drone à la scène

			# Initialiser la position en cercle
			var angle: float = (2.0 * PI / max_num_drones) * get_child_count()
			d.position.x = circle_radius * cos(angle)
			d.position.z = circle_radius * sin(angle)

		time_since_last_add = 0.0  # Réinitialiser le timer
