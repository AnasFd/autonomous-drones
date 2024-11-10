extends Node3D

const DroneScene: Resource = preload("res://scenes/drone.tscn")

@onready var drone_container = $Drones
@export var area_size: float = 100.0
@export var sphere_center: Vector3 = Vector3(0, 0, 0)
@export var sphere_radius: float = 40.0 # 40/15 (performance) 40/10 awesome view
@export var base_min_distance: float = 15

enum State { MOVE, AVOID_OBSTACLES }
var global_state: State = State.MOVE
var all_drones = []
var num_drones: int

func _ready():
	num_drones = drones_per_radius(sphere_radius, base_min_distance)
	print(num_drones)
	spawn_drones(num_drones)
	for drone in all_drones:
		drone.initialize(sphere_center, sphere_radius, all_drones, base_min_distance)

func _process(delta):
	update_states(delta)

func spawn_drones(count: int) -> void:
	for i in range(count):
		var new_drone = DroneScene.instantiate()
		drone_container.add_child(new_drone)
		
		var random_position = Vector3(
			randf_range(-area_size, area_size),
			randf_range(-area_size, area_size),
			randf_range(-area_size, area_size)
		)
		new_drone.global_transform.origin = random_position
		all_drones.append(new_drone)

# Centralized state update logic for all drones
func update_states(delta) -> void:
	for drone in all_drones:
		drone.update_state(global_state)
		drone.perform_behavior(delta)

func drones_per_radius(radius: float, bmd: float) -> int:
	@warning_ignore("narrowing_conversion")
	return (8 * pow(radius,3) * 0.75) / (pow(bmd,3))
