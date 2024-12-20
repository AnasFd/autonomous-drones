extends RigidBody3D

@export var speed: float = 1.0

enum State { MOVE }
var current_state: State = State.MOVE
var all_drones: Array
var sphere_center: Vector3
var sphere_radius: float
var base_min_distance: float
var sphere_volume: float

# Function to initialize shared parameters from main.gd
func initialize(center: Vector3, radius: float, drones: Array, bmd: float, sv: float) -> void:
	# Each drone should know these values
	self.sphere_center = center
	self.sphere_radius = radius
	self.all_drones = drones
	self.base_min_distance = bmd
	self.sphere_volume = sv
	
	# Collision properties
	self.contact_monitor = true
	self.max_contacts_reported = all_drones.size()
	
	# Physics properties
	self.gravity_scale = 0
	self.mass = 0.01 # affects speed
	self.linear_damp = 4
	self.angular_damp = 4

# Centralized state update function
func update_state(new_state: State) -> void:
	current_state = new_state

# Execute behavior based on the current state
func perform_behavior(_delta) -> void:
	match current_state:
		State.MOVE:
			movement()

# MOVE State: Move towards the sphere center until aligning with radius
func movement() -> void:
	var attraction = calculate_attraction_force()
	var avoidance = calculate_avoidance_force()
	apply_central_force((attraction + avoidance) * speed)

# Helper Functions
# Calculate attraction towards or away from the sphere center
func calculate_attraction_force() -> Vector3:
	var direction_to_center = (sphere_center - global_transform.origin)
	var distance_to_center = direction_to_center.length()
	var tolerance = 0.1  # Buffer zone around sphere_radius

	# Only apply attraction force if the drone is meaningfully outside the target boundary
	if distance_to_center > sphere_radius + tolerance:
		return direction_to_center.normalized()
	elif distance_to_center < sphere_radius - tolerance:
		return -direction_to_center.normalized()
	else:
		return Vector3.ZERO  # Inside the tolerance zone, no force

func calculate_avoidance_force() -> Vector3:
	var avoidance_force = Vector3.ZERO
	var min_distance = base_min_distance + (sphere_volume / all_drones.size())

	for drone in all_drones:
		if drone != self:
			var distance_to_drone = global_transform.origin.distance_to(drone.global_transform.origin)

			if distance_to_drone < min_distance:
				# Calculate a strong repulsion force directly away from nearby drone
				var repulsion_direction = (global_transform.origin - drone.global_transform.origin).normalized()

				# Calculate a strong repulsion magnitude that increases as drones get closer
				var repulsion_magnitude = (min_distance - distance_to_drone) / min_distance
				avoidance_force += repulsion_direction * repulsion_magnitude

	return avoidance_force

func _on_body_entered(body: Node) -> void:
	print("collision happened")
	all_drones.erase(body)
	queue_free()
