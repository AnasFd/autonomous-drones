extends Node3D

const DroneScene: Resource = preload("res://scenes/drone.tscn")

@onready var drone_container = $Drones
@export var area_size: float = 50.0
@export var sphere_center: Vector3 = Vector3(0, 0, 0)
@export var num_drones: int = 50
@export var sphere_radius: float = 20.0

enum State { MOVE, AVOID_OBSTACLES, IDLE }
var global_state: State = State.MOVE
var all_drones = []

func _ready():
	spawn_drones(num_drones)
	for drone in all_drones:
		drone.initialize(sphere_center, sphere_radius, all_drones)

func _process(delta):
	update_states(delta)

func spawn_drones(count: int):
	for i in range(count):
		var new_drone = DroneScene.instantiate()
		drone_container.add_child(new_drone)
		
		var random_position = Vector3(
			randf_range(-area_size, area_size),
			randf_range(1, area_size / 2),
			randf_range(-area_size, area_size)
		)
		new_drone.global_transform.origin = random_position
		all_drones.append(new_drone)

# Centralized state update logic for all drones
func update_states(delta):
	for drone in all_drones:
		drone.update_state(global_state)
		drone.perform_behavior(delta)
