extends Node3D

@export var circle_center: Vector3  # Center of the circle
@export var circle_radius: float = 30.0  # Desired radius of the circle
@export var base_min_distance: float = 15
@export var speed: float = 1.0  # Movement speed
@export var repulsion_strength: float = 15.0  # Strength of repulsion between drones

func _ready():
	pass # Nothing to do in _ready since the initial placement is now done in main.gd

func _process(delta):
	# Move the drone towards the target circle and avoid other drones
	var steering = calculate_steering()
	move(steering * delta)

# Calculate the steering force to move towards the center and avoid other drones
func calculate_steering() -> Vector3:
	var desired_direction = (circle_center - global_transform.origin).normalized()
	var desired_velocity = desired_direction * speed
	
	# Calculate repulsion from nearby drones to avoid collisions
	var avoidance_force = calculate_avoidance_force()

	# Combine the desired movement towards the center and the repulsion force
	var steering = desired_velocity + avoidance_force
	
	return steering.normalized()

# Calculate the repulsion force to avoid collisions with other drones
func calculate_avoidance_force() -> Vector3:
	var avoidance_force = Vector3.ZERO
	var drones = get_parent().get_children()  # Get all drones
	
	for drone in drones:
		if drone != self:  # Avoid self-comparison
			var distance_to_drone = global_transform.origin.distance_to(drone.global_transform.origin)
			var min_distance = base_min_distance + (circle_radius / drones.size())

			# If the drone is too close, calculate a repulsion force
			if distance_to_drone < min_distance:
				var repulsion_direction = (global_transform.origin - drone.global_transform.origin).normalized()
				var repulsion_strength_scaled = (min_distance - distance_to_drone) / min_distance
				avoidance_force += repulsion_direction * repulsion_strength_scaled * repulsion_strength

	return avoidance_force

# Apply movement to the drone
func move(steering: Vector3):
	var new_position = global_transform.origin + steering
	# Ensure the drone stays near the dynamically shrinking radius by adjusting distance from the center
	var to_center = (new_position - circle_center).normalized() * circle_radius
	new_position = circle_center + to_center

	global_transform.origin = new_position  # Apply the new position
