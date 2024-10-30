# Drone.gd
extends RigidBody3D

# Constants and properties for the drone behavior
@export var circle_center: Vector3 = Vector3(0, 0, 0)
@export var circle_radius: float = 10.0  # Desired radius of the sphere
@export var base_min_distance: float = 5.0  # Minimum distance between drones
@export var speed: float = 10.0  # Base movement speed
@export var repulsion_strength: float = 1.0  # Strength of repulsion between drones
@export var radial_constraint_strength: float = 1.0  # Strength of the force to keep drones at circle_radius

# Class properties for the forces
var steering_force: Vector3
var radial_constraint_force: Vector3
var avoidance_force: Vector3

# Main processing function to update movement each frame
func _process(delta):
	# Update forces and combine them for final application
	steering_force = calculate_steering()
	radial_constraint_force = calculate_radial_constraint()
	avoidance_force = calculate_avoidance_force()

	# Combine all forces and apply as a central impulse
	var combined_force = (steering_force + radial_constraint_force + avoidance_force).normalized() * speed * delta
	apply_central_impulse(combined_force)

# Collision detection
func _on_body_entered(body: Node) -> void:
	print("collision happened")
	print("self position: " + str(self.position))
	print("body position: " + str(body.position))
	queue_free()  # Optional: remove the drone upon collision

# Calculations for the various forces
# Steering force to move towards the center and avoid other drones
func calculate_steering() -> Vector3:
	var desired_direction = (circle_center - global_transform.origin).normalized()
	return desired_direction

# Radial constraint force to maintain a position at circle_radius
func calculate_radial_constraint() -> Vector3:
	var direction_to_center = (global_transform.origin - circle_center).normalized()
	var distance_to_center = global_transform.origin.distance_to(circle_center)
	var distance_from_radius = distance_to_center - circle_radius
	
	# Only apply constraint if the drone is outside the target radius
	if abs(distance_from_radius) > 0.0:  # Small threshold for stability
		return -direction_to_center * distance_from_radius * radial_constraint_strength
	else:
		return Vector3.ZERO

# Avoidance force to prevent drones from clustering too closely
func calculate_avoidance_force() -> Vector3:
	var force = Vector3.ZERO
	var drones = get_parent().get_children()

	for drone in drones:
		if drone != self:  # Avoid self-comparison
			var distance_to_drone = global_transform.origin.distance_to(drone.global_transform.origin)
			var min_distance = base_min_distance + (circle_radius / drones.size())

			# Apply repulsion if too close
			if distance_to_drone < min_distance:
				var repulsion_direction = (global_transform.origin - drone.global_transform.origin).normalized()
				var repulsion_strength_scaled = (min_distance - distance_to_drone) / min_distance
				force += repulsion_direction * repulsion_strength_scaled * repulsion_strength

	return force

# Optional function for drone orientation facing the center of the sphere
func _integrate_forces(_state):
	look_at(circle_center, Vector3.UP)
