extends Node3D

const drone: Resource = preload("res://scenes/drone.tscn")
@onready var light = $DirectionalLight3D  # Reference to the directional light
@onready var camera = $Camera3D  # Reference to the camera
@onready var drones = $Drones  # Reference to the node containing the drones

@export var num_drones: int = 50  # Number of drones to create
@export var area_size: float = 50  # Size of the area to randomly place drones in

func _ready():
	# Initialize light properties
	if light:  # Check if the node exists
		light.rotation_degrees = Vector3(-90, 0, 0)
		light.position = Vector3(0, 10, 0)
	else:
		print("DirectionalLight3D not found!")

	# Create drones dynamically and add them to the scene
	spawn_drones(num_drones)

	# Print the number of drones in the Drones node
	print("Number of drones in the scene: ", drones.get_child_count())

func spawn_drones(count: int):
	for i in range(count):
		var new_drone = drone.instantiate()  # Create a new instance of the drone scene
		drones.add_child(new_drone)  # Add the drone to the Drones node
		
		var random_position = Vector3(
			randf_range(-area_size, area_size),
			randf_range(1, area_size / 2),  # Keep drones above ground level
			randf_range(-area_size, area_size)
		)
		new_drone.global_transform.origin = random_position  # Set random position in the 3D space

	# Optionally, you can print the count here too after each spawn if needed:
	print("Drones after spawning: ", drones.get_child_count())
