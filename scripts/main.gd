extends Node3D

const drone: Resource = preload("res://scenes/drone.tscn")
@onready var drones = $Drones  # Reference to the node containing the drones
@export var num_drones: int = 50  # Number of drones to create
@export var area_size: float = 100  # Size of the area to randomly place drones in

func _ready():
	spawn_drones(num_drones)

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
