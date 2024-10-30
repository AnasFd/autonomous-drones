extends RigidBody3D

@export var sphere_center: Vector3 = Vector3(0, 0, 0)
@export var sphere_radius: float = 30.0
@export var base_min_distance: float = 5.0
@export var speed: float = 30.0
@export var radial_constraint_strength: float = 1.5  # Adjusts strength for keeping drones at sphere_radius

# Define possible states
enum State { MOVE, AVOID_OBSTACLES, IDLE }
var current_state: State = State.MOVE

func _ready():
	current_state = State.MOVE

func _process(delta):
	# Execute current state logic
	match current_state:
		State.MOVE:
			move_to_sphere_radius(delta)
		State.AVOID_OBSTACLES:
			avoid_obstacles(delta)
		State.IDLE:
			idle(delta)

# State Logic

# MOVE state: move towards target sphere radius and apply radial constraint
func move_to_sphere_radius(delta):
	# Calculate movement towards the center
	var direction = (sphere_center - global_transform.origin).normalized()
	
	# Apply radial constraint to stay at the desired sphere radius
	var radial_constraint = calculate_radial_constraint()

	# Calculate the final movement and apply impulse
	var movement = (direction * speed + radial_constraint) * delta
	apply_central_impulse(movement)

	# Check transitions to other states
	var avoidance_force = calculate_avoidance_force()
	if avoidance_force == Vector3.ZERO and is_in_sphere_radius():
		current_state = State.IDLE
	elif avoidance_force != Vector3.ZERO:
		current_state = State.AVOID_OBSTACLES


# AVOID_OBSTACLES state: apply repulsion force to avoid collisions
func avoid_obstacles(delta):
	var avoidance_force = calculate_avoidance_force()
	apply_central_impulse(avoidance_force * delta)

	# Transition to MOVE if no obstacles are nearby and drone is outside radius
	if avoidance_force == Vector3.ZERO and !is_in_sphere_radius():
		current_state = State.MOVE
	elif avoidance_force == Vector3.ZERO and is_in_sphere_radius():
		current_state = State.IDLE


# IDLE state: wait until repulsion is detected
func idle(_delta):
	if calculate_avoidance_force() != Vector3.ZERO:
		current_state = State.AVOID_OBSTACLES


# Helper functions

# Check if drone is in the sphere radius with a small tolerance
func is_in_sphere_radius() -> bool:
	var distance = global_transform.origin.distance_to(sphere_center)
	return abs(distance - sphere_radius) < 0.2  # Tolerance for slight deviations

# Calculate the radial constraint to keep drones at the target sphere radius
func calculate_radial_constraint() -> Vector3:
	var direction_to_center = (sphere_center - global_transform.origin).normalized()
	var distance_to_center = global_transform.origin.distance_to(sphere_center)

	# Only apply force if outside the target radius
	if abs(distance_to_center - sphere_radius) < 0.5:
		var force_magnitude = (distance_to_center - sphere_radius) * radial_constraint_strength
		return -direction_to_center * force_magnitude
	return Vector3.ZERO


# Calculate the repulsion force to avoid collisions with other drones for uniform distribution
func calculate_avoidance_force() -> Vector3:
	var avoidance_force = Vector3.ZERO
	var drones = get_parent().get_children()

	for drone in drones:
		if drone != self:
			var distance_to_drone = global_transform.origin.distance_to(drone.global_transform.origin)
			var min_distance = base_min_distance

			# Apply repulsion if too close to another drone
			if distance_to_drone < min_distance:
				var repulsion_direction = (global_transform.origin - drone.global_transform.origin).normalized()
				var repulsion_strength_scaled = (min_distance - distance_to_drone) / min_distance
				avoidance_force += repulsion_direction * repulsion_strength_scaled

	return avoidance_force
