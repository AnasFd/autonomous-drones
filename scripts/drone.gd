extends RigidBody3D

@export var base_min_distance: float = 10.0
@export var speed: float = 1.0
@export var attraction_strength: float = 1.0 * speed
@export var repulsion_strength: float = 100.0

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
func perform_behavior():
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
	apply_central_force(movement)
	
	if calculate_avoidance_force() != Vector3.ZERO:
		update_state(State.AVOID_OBSTACLES)
	elif movement == Vector3.ZERO:
		update_state(State.IDLE)

# AVOID_OBSTACLES State: Adjust position to avoid collision with other drones
func avoid_obstacles():
	var avoidance_force = calculate_avoidance_force()
	apply_central_force(avoidance_force)
	
	if avoidance_force == Vector3.ZERO:
		update_state(State.MOVE)

# IDLE State: Maintain position on the sphere boundary, avoiding nearby obstacles
func idle():
	#if calculate_attraction_force() != Vector3.ZERO:
		#update_state(State.MOVE)
	if calculate_avoidance_force() != Vector3.ZERO:
		update_state(State.AVOID_OBSTACLES)

# Helper Functions

# Calculate attraction towards or away from the sphere center
func calculate_attraction_force() -> Vector3:
	var direction_to_center = (sphere_center - global_transform.origin)
	var distance_to_center = direction_to_center.length()

	if distance_to_center > sphere_radius:
		return direction_to_center.normalized() * attraction_strength
	elif distance_to_center < sphere_radius:
		return -direction_to_center.normalized() * attraction_strength
	else:
		return Vector3.ZERO

func calculate_avoidance_force() -> Vector3:
	var avoidance_force = Vector3.ZERO
	var min_distance = base_min_distance + (sphere_radius / all_drones.size())

	for drone in all_drones:
		if drone != self:
			var distance_to_drone = global_transform.origin.distance_to(drone.global_transform.origin)

			if distance_to_drone < min_distance:
				# Calculate the repulsion direction away from the other drone
				var repulsion_direction = (global_transform.origin - drone.global_transform.origin).normalized()

				# Make the repulsion stronger the closer the drones get
				var repulsion_magnitude = repulsion_strength * ((min_distance - distance_to_drone) / min_distance)

				# Add the calculated force in the repulsion direction
				avoidance_force += repulsion_direction * repulsion_magnitude

	return avoidance_force
