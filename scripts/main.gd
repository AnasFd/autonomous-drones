extends Node3D

const drone: Resource = preload("res://scenes/drone.tscn")  # Chemin vers la scène du drone
@onready var light = $DirectionalLight3D  # Référence à la lumière directionnelle
@onready var camera = $Camera3D  # Référence à la caméra
@onready var drones = $Drones  # Référence au nœud contenant les drones

var time_since_last_add: float = 0.0  # Timer pour l'ajout de drones
var add_interval: float = 1.0  # Intervalle d'ajout en secondes
var circle_radius: float = 20.0  # Rayon du cercle
var max_num_drones: int = 10  # Nombre maximum de drones à instancier
var drones_ready: int = 0  # Compteur des drones prêts
var all_drones_ready: bool = false  # Indicateur si tous les drones sont prêts

func _ready():
	# Initialiser les propriétés de la lumière
	if light:  # Vérifier si le nœud existe
		light.rotation_degrees = Vector3(-90, 0, 0)
		light.position = Vector3(0, 10, 0)
	else:
		print("DirectionalLight3D not found!")

	# Vérifier si le nœud drones est valide
	if drones:
		print("Drones node found.")
	else:
		print("Drones node not found!")

func _process(delta):
	time_since_last_add += delta
	if time_since_last_add >= add_interval:  # Ajouter un drone à chaque intervalle
		if randf() < 0.1 and drones and drones.get_child_count() < max_num_drones:  # Vérifier si drones n'est nul
			var d: Node3D = drone.instantiate()
			drones.add_child(d)  # Ajouter le drone à la scène

			# Initialiser la position au sol (aléatoire)
			d.position = Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
			d.circle_center = Vector3(0, 0, 0)  # Définir le centre du cercle
			d.circle_radius = circle_radius  # Définir le rayon du cercle
		
		time_since_last_add = 0.0  # Réinitialiser le timer

func notify_drone_ready():
	drones_ready += 1
	print("Drone ready: ", drones_ready, "/", max_num_drones)

	# Vérifier si tous les drones sont prêts
	if drones_ready == max_num_drones:
		print("All drones are ready. Starting.")
		all_drones_ready = true  # Indiquer que tous les drones sont prêts

func are_all_drones_ready() -> bool:
	return all_drones_ready  # Renvoie si tous les drones sont prêts
