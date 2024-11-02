extends RigidBody3D

@export var sphere_center: Vector3 = Vector3(0, 0, 0)
@export var sphere_radius: float = 10.0
@export var base_min_distance: float = 5
@export var speed: float = 1.0
#@onready var drones = self.get_parent().get_children()
var local_drones_size = 20
@export var attraction_strength: float = 3.0 * speed  # Starting value;
# Fine-Tuning Tips for attraction_strength:
# Start with a low value and increase gradually until drones maintain
# a stable position at the boundary without overshooting.
# Monitor if drones reach the boundary smoothly; if they oscillate, 
# reduce attraction_strength. If they lag or never reach the boundary, 
# increase it slightly.
@export var repulsion_strength: float = 3.0
var drones
# Define possible states, including ALIGN_TO_RADIUS
enum State { MOVE, AVOID_OBSTACLES, IDLE }
var current_state: State = State.MOVE

func _ready():
	drones = get_parent().get_children()
	current_state = State.MOVE

func _process(delta):
	# Execute logic based on the current state
	match current_state:
		State.MOVE:
			move_to_center(delta)
			#print("in move")
		State.AVOID_OBSTACLES:
			avoid_obstacles(delta)
			#print("in avoid")
		State.IDLE:
			idle(delta)
			print("in idle")

# State Logic

# MOVE State: Drone moves towards the sphere center until close enough to align with radius
func move_to_center(_delta):
	var movement = calculate_attraction_force()
	apply_central_force(movement)
	
	var avoidance_force = calculate_avoidance_force()
	
	if avoidance_force != Vector3.ZERO: # If obstacle near by
		current_state = State.AVOID_OBSTACLES
	elif movement == Vector3.ZERO: # no obstacles and in sphere radius
		current_state = State.IDLE
	else:
		current_state = State.MOVE # Continue moving towards the center

# AVOID_OBSTACLES State: Adjust position to avoid collision with other drones
func avoid_obstacles(_delta):
	var avoidance_force = calculate_avoidance_force()
	apply_central_force(avoidance_force)
	
	if avoidance_force == Vector3.ZERO: # no obstacles nearby
		if calculate_attraction_force() != Vector3.ZERO: # not in sphere radius
			current_state = State.MOVE
		else:
			current_state = State.IDLE
	else:
		current_state = State.AVOID_OBSTACLES

# IDLE State: Maintain position on the sphere boundary and ensure even spacing
func idle(_delta):
	if calculate_avoidance_force() != Vector3.ZERO: # Obstacles nearby
		current_state = State.AVOID_OBSTACLES
	elif calculate_attraction_force() != Vector3.ZERO: # not in sphere radius
		current_state = State.MOVE
	else:
		current_state = State.IDLE

# Helper functions

func calculate_attraction_force() -> Vector3:
	# Get the direction and distance to the center
	var direction_to_center = (sphere_center - global_transform.origin)
	var distance_to_center = direction_to_center.length()

	# Determine the direction of the force: toward or away from the center
	if distance_to_center > sphere_radius:
		# If outside the sphere, pull towards center
		return direction_to_center.normalized() * attraction_strength
	elif distance_to_center < sphere_radius:
		# If inside the sphere, push away from center
		return -direction_to_center.normalized() * attraction_strength
	else:
		return Vector3.ZERO

# Calculate avoidance force to keep drones at a minimum distance from each other
func calculate_avoidance_force() -> Vector3:
	var avoidance_force = Vector3.ZERO

	for drone in drones:
		if drone != self:
			var distance_to_drone = global_transform.origin.distance_to(drone.global_transform.origin)
			var min_distance = base_min_distance

			if distance_to_drone < min_distance:
				# Calculate the repulsion direction away from the other drone
				var repulsion_direction = (global_transform.origin - drone.global_transform.origin).normalized()

				# Calculate a tangential direction based on the sphere center
				var to_center = (sphere_center - global_transform.origin).normalized()
				var tangential_direction = to_center.cross(repulsion_direction).normalized()

				# Blend repulsion and tangential movement, using a balance factor
				var balance_factor = 0.1  # Adjust this to control tangential influence
				var adjusted_direction = (repulsion_direction * (1 - balance_factor)) + (tangential_direction * balance_factor)

				var repulsion_strength_scaled = (min_distance - distance_to_drone) / min_distance
				avoidance_force += adjusted_direction * repulsion_strength_scaled * repulsion_strength

	return avoidance_force
