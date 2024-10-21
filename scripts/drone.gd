extends Node3D

@export var sphere_center: Vector3  # Center of the sphere
@export var sphere_radius: float = 20.0  # Desired radius of the sphere
@export var speed: float = 5.0  # Movement speed
@export var repulsion_strength: float = 15.0  # Strength of repulsion between drones
@export var base_min_distance: float = 15.0  # Minimum distance between drones

var target_position: Vector3  # Final position of the drone on the sphere

func _ready():
	# Position initiale aléatoire au sol
	global_transform.origin = random_position_on_ground()
	# Générer une position cible sur la sphère
	target_position = random_position_on_sphere()

func _process(delta):
	# Calculer la force de déplacement vers la position cible sur la sphère
	var steering = calculate_steering(delta)
	move(steering * delta)

# Génère une position aléatoire au sol
func random_position_on_ground() -> Vector3:
	var x = randf_range(-sphere_radius - 50, sphere_radius + 50)
	var z = randf_range(-sphere_radius, sphere_radius)
	return Vector3(x, 0, z)  # Position aléatoire avec y = 0 (au sol)

# Génère une position aléatoire sur la surface de la sphère
func random_position_on_sphere() -> Vector3:
	var theta = randf_range(0.0, PI * 2)  # Angle autour de l'axe Y
	var phi = randf_range(0.0, PI)  # Angle du pôle
	var x = sphere_radius * sin(phi) * cos(theta)
	var y = sphere_radius * cos(phi)
	var z = sphere_radius * sin(phi) * sin(theta)
	return sphere_center + Vector3(x, y, z)

# Calculer la force de déplacement vers la sphère
func calculate_steering(delta: float) -> Vector3:
	var desired_direction = (target_position - global_transform.origin).normalized()
	var desired_velocity = desired_direction * speed

	# Éviter les collisions avec les autres drones
	var avoidance_force = calculate_avoidance_force()

	# Combiner le mouvement vers la sphère et l'évitement
	var steering = desired_velocity + avoidance_force
	
	return steering.normalized()

# Calculer la force d'évitement pour éviter les collisions
func calculate_avoidance_force() -> Vector3:
	var avoidance_force = Vector3.ZERO
	var drones = get_parent().get_children()  # Récupère tous les drones
	
	for drone in drones:
		if drone != self:  # Éviter la comparaison avec soi-même
			var distance_to_drone = global_transform.origin.distance_to(drone.global_transform.origin)
			var min_distance = base_min_distance + (sphere_radius / drones.size())

			# Si le drone est trop proche, calculer une force de répulsion
			if distance_to_drone < min_distance:
				var repulsion_direction = (global_transform.origin - drone.global_transform.origin).normalized()
				var repulsion_strength_scaled = (min_distance - distance_to_drone) / min_distance
				avoidance_force += repulsion_direction * repulsion_strength_scaled * repulsion_strength

	return avoidance_force

# Appliquer le mouvement au drone
func move(steering: Vector3):
	var new_position = global_transform.origin + steering
	global_transform.origin = new_position  # Appliquer la nouvelle position
