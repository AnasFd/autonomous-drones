extends RigidBody3D

@export var base_min_distance: float = 15.0
@export var speed: float = 1.0
@export var attraction_strength: float = 1.0 * speed
@export var repulsion_strength: float = 1.0

enum State { MOVE, AVOID_OBSTACLES, IDLE }
var current_state: State = State.MOVE
var all_drones: Array
var sphere_center: Vector3
var sphere_radius: float

# Function to initialize shared parameters from Main.gd
func initialize(center: Vector3, radius: float, drones: Array) -> void:
	sphere_center = center
	sphere_radius = radius
	all_drones = drones

# Centralized state update function
func update_state(new_state: State) -> void:
	current_state = new_state

# Execute behavior based on the current state
func perform_behavior(delta):
	match current_state:
		State.MOVE:
			move_to_center()
		State.AVOID_OBSTACLES:
			avoid_obstacles()
		State.IDLE:
			idle()

# MOVE State: Move towards the sphere center until aligning with radius
func move_to_center():
	var movement = calculate_attraction_force()
	var avoidance = calculate_avoidance_force()
	apply_central_force(movement + avoidance)

	if avoidance != Vector3.ZERO:
		update_state(State.AVOID_OBSTACLES)
	elif movement == Vector3.ZERO:
		update_state(State.IDLE)

# AVOID_OBSTACLES State: Adjust position to avoid collision with other drones
func avoid_obstacles():
	var avoidance_force = calculate_avoidance_force()
	apply_central_force(avoidance_force)
	
	# Switch to MOVE if no repulsion is necessary
	if avoidance_force == Vector3.ZERO:
		update_state(State.MOVE)

# IDLE State: Maintain position on the sphere boundary, avoiding nearby obstacles
func idle():
	# Check if the drone has drifted out of the buffer zone and needs to realign
	if calculate_attraction_force() != Vector3.ZERO:
		update_state(State.MOVE)
	elif calculate_avoidance_force() != Vector3.ZERO:
		update_state(State.AVOID_OBSTACLES)

# Helper Functions

# Calculate attraction towards or away from the sphere center
func calculate_attraction_force() -> Vector3:
	var direction_to_center = (sphere_center - global_transform.origin)
	var distance_to_center = direction_to_center.length()
	var tolerance = 0.5  # Buffer zone around sphere_radius

	# Only apply attraction force if the drone is meaningfully outside the target boundary
	if distance_to_center > sphere_radius + tolerance:
		return direction_to_center.normalized() * attraction_strength
	elif distance_to_center < sphere_radius - tolerance:
		return -direction_to_center.normalized() * attraction_strength
	else:
		return Vector3.ZERO  # Inside the tolerance zone, no force

func calculate_avoidance_force() -> Vector3:
	var avoidance_force = Vector3.ZERO
	var min_distance = base_min_distance + (sphere_radius / all_drones.size())

	for drone in all_drones:
		if drone != self:
			var distance_to_drone = global_transform.origin.distance_to(drone.global_transform.origin)

			if distance_to_drone < min_distance:
				# Calculate a strong repulsion force directly away from nearby drone
				var repulsion_direction = (global_transform.origin - drone.global_transform.origin).normalized()

				# Calculate a strong repulsion magnitude that increases as drones get closer
				var repulsion_magnitude = repulsion_strength * (min_distance - distance_to_drone) / min_distance
				avoidance_force += repulsion_direction * repulsion_magnitude

	return avoidance_force
