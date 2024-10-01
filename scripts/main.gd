extends Node3D

const drone: Resource = preload("res://scenes/drone.tscn")
@onready var light = $DirectionalLight3D
@onready var camera = $Camera3D
@onready var drones = $Drones
var time_since_last_add: float = 0.0
var add_interval: float = 1.0  # Intervalle d'ajout en secondes
var circle_radius: float = 20.0  # Rayon du cercle
var max_num_drones: int = 6  # Nombre total de drones à instancier
var drones_ready: int = 0  # Compteur des drones prêts
var all_drones_ready: bool = false  # Indicateur si tous les drones sont prêts

func _ready():
	# Light properties
	light.rotation_degrees = Vector3(-90, 0, 0)
	light.position = Vector3(0, 10, 0)

func _process(delta):
	time_since_last_add += delta
	if time_since_last_add >= add_interval:  # Ajouter un drone à chaque intervalle
		if randf() < 0.1 and drones.get_child_count() < max_num_drones:  # Ajouter un drone de temps en temps
			var d: Node3D = drone.instantiate()
			drones.add_child(d)  # Ajouter le drone à la scène

			# Initialiser la position au sol (aléatoire)
			d.position = Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
		
		time_since_last_add = 0.0  # Réinitialiser le timer

func notify_drone_ready():
	drones_ready += 1
	print("Drone ready: ", drones_ready, "/", max_num_drones)

	# Vérifier si tous les drones sont prêts
	if drones_ready == max_num_drones:
		print("All drones are ready. Starting circular motion.")
		all_drones_ready = true  # Indiquer que tous les drones sont prêts
		# Envoyer un signal à tous les drones pour commencer la phase circulaire
		for drone in drones.get_children():
			drone.start_circle_phase()

func are_all_drones_ready() -> bool:
	return all_drones_ready  # Renvoie si tous les drones sont prêts
